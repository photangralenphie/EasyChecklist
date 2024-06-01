//
//  TransferablePDF.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 31.05.24.
//
import SwiftUI
import TPPDF
import CoreTransferable

public struct TransferablePDF {
    
    let list: CustomList
    
    public func makePDF() -> Data {
        let document = PDFDocument(format: .a4)
        let title = NSMutableAttributedString(string: list.name, attributes: [
            .font: UIFont.systemFont(ofSize: 28)
        ])
        document.add(attributedText: title)
        document.addLineSeparator(style: .init())
        document.add(space: 14)
        if let entries = list.listEntries {
            let table = PDFTable(rows: entries.count * 2, columns: 2)
            let style = PDFTableStyleDefaults.none
            style.contentStyle = PDFTableCellStyle(borders: PDFTableCellBorders.none)
            style.columnHeaderCount = 0
            style.footerCount = 0
            
            table.widths = [0.05, 0.95]
            table.style = style
            table.rows.allRowsAlignment = [.left, .left]

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
        
        document.add(.footerCenter, text: "Created with EasyChecklist for iOS.")
        
        let generator = PDFGenerator(document: document)
        let pdfData = try? generator.generateData()
        return pdfData ?? Data()
    }
}

extension TransferablePDF: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .pdf) { pdfData in
            pdfData.makePDF()
        }
    }
}
