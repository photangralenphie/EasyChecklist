//
//  ListView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 11.02.24.
//

import SwiftUI
import PDFKit
import InlineColorPicker
import PrintingKit
import TPPDF
import UniformTypeIdentifiers

struct ListView: View {
    
    // Init
    let list: CustomList
    @Binding public var selectedList: CustomList?
    
    // Data
    @Environment(\.modelContext) private var context
    
    // Functional
    @FocusState private var newEntryInFocus: Bool
    @State private var newEntryName: String = ""
    @State private var searchString: String = ""
    @State private var isSearching: Bool = false
    @State private var isEditing: Bool = false
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    // Settings
    @AppStorage("moveToBottom") private var moveToBottom: Bool = true
    
    var filteredListEntries: [ListEntry] {
        if let entries = list.listEntries {
            if searchString.isEmpty {
                return entries
            } else {
                return entries.filter{ $0.name.localizedCaseInsensitiveContains(searchString) }
            }
        } else {
            return []
        }
    }
    
    var body: some View {
        List {
            if moveToBottom {
                ForEach(filteredListEntries) { listEntry in
                    if !listEntry.checked {
                        ListEntryView(listEntry: listEntry)
                    }
                }
                if filteredListEntries.contains(where: \.checked) {
                    Section("Completed", isExpanded: Bindable(list).isCompletedSectionExpanded) {
                        ForEach(filteredListEntries) { listEntry in
                            if listEntry.checked {
                                ListEntryView(listEntry: listEntry)
                            }
                        }
                    }
                }
            } else {
                ForEach(filteredListEntries) { listEntry in
                    ListEntryView(listEntry: listEntry)
                }
            }
        }
        .toolbarRole(sizeClass==UserInterfaceSizeClass.compact ? .automatic : .editor)
        .navigationTitle(Bindable(list).name)
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar(id: "listToolbar") {
            ToolbarItem(id: "search", placement: .primaryAction) {
                if sizeClass == .compact {
                    Button {
                        isSearching.toggle()
                    } label: {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                }
            }
            
            ToolbarItem(id: "sort", placement: .secondaryAction) {
                Picker(selection: .constant(0)) {
                    Label("Alphabetical", systemImage: "abc")
                        .tag(0)
                    Label("Newest", systemImage: "clock")
                        .tag(1)
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
            
            ToolbarItem(id: "edit", placement: .secondaryAction) {
                Button(action: editList){
                    Label("Edit List", systemImage: "square.and.pencil")
                }
            }

            ToolbarItem(id: "share", placement: .secondaryAction) {
                ShareLink("Share", item: makePDF() ?? URL(fileURLWithPath: ""))
            }
            
            ToolbarItem(id: "print", placement: .secondaryAction) {
                Button(action: printList) {
                    Label("Print", systemImage: "printer")
                }
            }
            
            ToolbarItem(id: "delete", placement: .secondaryAction) {
                Button(role: .destructive, action: deleteList) {
                    Label("Delete List", systemImage: "trash")
                }
            }
        }
        .searchable(text: $searchString, isPresented: $isSearching.animation(), placement: .toolbar, prompt: Text("Search \(list.name)"))
        .overlay {
            if filteredListEntries.isEmpty && isSearching {
                ContentUnavailableView.search(text: searchString)
            }
            if let entries = list.listEntries {
                if entries.isEmpty && !isSearching {
                    ContentUnavailableView("No Entries", systemImage: "plus")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !isSearching {
                HStack {
                    TextField("Add an Item", text: $newEntryName)
                        .padding()
                        .padding(.trailing)
                        .background(Color(.tertiarySystemBackground).cornerRadius(10))
                        .focused($newEntryInFocus)
                        .onTapGesture { newEntryInFocus = true }
                        .onSubmit(addNewEntry)
                    
                    Button(action: addNewEntry) {
                        Image(systemName: "plus")
                            .padding(.horizontal, 2)
                            .padding(.vertical, 4)
                            .font(.headline)
                    }
                    .buttonStyle(.bordered)
                    .disabled(newEntryName.isEmpty)
                }
                .padding()
                .background(Color(.systemGroupedBackground))
            }
        }
        .tint(GetColorByID(list.color))
        .sheet(isPresented: $isEditing) {
            EditListView(list: list)
        }
    }
    
    func addNewEntry() {
        let newEntry = ListEntry(name: newEntryName)
        newEntry.list = list
        list.editDate = Date.now
        newEntryName = ""
        newEntryInFocus = true
    }
    
    func editList() {
        isEditing.toggle()
    }
    
    func deleteList() {
        context.delete(list)
        selectedList = nil
    }
    
    func printList() {
        let printer = Printer()
        try? printer.print(.pdfFile(at: makePDF()))
    }
    
    func makePDF() -> URL?{
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
            //let entriesSorted = entries.sorted { $0.name.prefix(1) < $1.name.prefix(1) }
            //entries.sort { $0.name.prefix(1) < $1.name.prefix(1) }.indices.forEach { i in
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
        return try? generator.generateURL(filename: "Example.pdf")
    }
}
