//
//  TransferablePDF.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 31.05.24.
//
import SwiftUI
import TPPDF
import CoreTransferable

#if os(iOS)
public class PdfMaker {
    
    init(list: CustomList) {
        self.list = list
        self.name = list.name
        self.numEmptyItems = 0
    }
    
    init(name: String, numEmptyItems: Int) {
        self.name = name
        self.numEmptyItems = numEmptyItems
        self.list = nil
    }
    
    private let list: CustomList?
    private let name: String
    private let numEmptyItems: Int
    
    public func makePDF() -> Data {
        let document: PDFDocument
        
        if let checklist = list {
            document = makePdfFromList(checkList: checklist)
        } else {
            document = makeEmptyPdf()
        }
        
        document.add(.footerCenter, text: "Created with EasyChecklist for iOS.")
        
        let generator = PDFGenerator(document: document)
        let pdfData = try? generator.generateData()
        return pdfData ?? Data()
    }
    
    private func makePdfFromList(checkList: CustomList) -> PDFDocument {
        let document = createEmptyDocument(title: checkList.name)
        if let entries = checkList.listEntries {
            let table = createTable(numEntries: entries.count)

            entries.indices.forEach { i in
                let image = UIImage(systemName: entries[i].checked ? "checkmark.circle" : "circle")
                let text = NSMutableAttributedString(string: entries[i].name, attributes: [
                    .font: UIFont.systemFont(ofSize: image?.size.height ?? 16)
                ])
                
                let row = table.rows.rows[i * 2]
                row.content = [image, text]
                
                let emptyRow = table.rows.rows[i * 2 + 1]
                emptyRow.content = [" ", " "]
                emptyRow.allCellsStyle = PDFTableCellStyle(font: UIFont.systemFont(ofSize: 5))
            }
            
            document.add(table: table)
        }
        return document
    }
    
    private func makeEmptyPdf() -> PDFDocument {
        let document = createEmptyDocument(title: name)
        let table = createTable(numEntries: numEmptyItems)
        
        for i in 0..<numEmptyItems {
            let image = UIImage(systemName: "circle")
            
            let row = table.rows.rows[i * 2]
            row.content = [image, " "]
            
            let emptyRow = table.rows.rows[i * 2 + 1]
            emptyRow.content = [" ", " "]
            emptyRow.allCellsStyle = PDFTableCellStyle(font: UIFont.systemFont(ofSize: 5))
        }
        return document
    }
    
    private func createEmptyDocument(title: String) -> PDFDocument {
        let document = PDFDocument(format: .a4)
        let title = NSMutableAttributedString(string: title, attributes: [
            .font: UIFont.systemFont(ofSize: 28)
        ])
        document.add(attributedText: title)
        document.addLineSeparator(style: .init())
        document.add(space: 14)
        return document
    }
    
    private func createTable(numEntries: Int) -> PDFTable {
        let table = PDFTable(rows: numEntries * 2, columns: 2)
        let style = PDFTableStyleDefaults.none
        style.contentStyle = PDFTableCellStyle(borders: PDFTableCellBorders.none)
        style.columnHeaderCount = 0
        style.footerCount = 0
        
        table.widths = [0.05, 0.95]
        table.style = style
        table.rows.allRowsAlignment = [.left, .left]
        
        return table
    }
}

extension PdfMaker: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .pdf) { pdfData in
            pdfData.makePDF()
        }
    }
}
#endif
