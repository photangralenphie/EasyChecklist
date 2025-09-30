//
//  ListView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 11.02.24.
//

import Foundation
import SwiftUI
import AwesomeSwiftyComponents
import TPPDF
import PrintingKit
import UniformTypeIdentifiers

struct ListView: View {
    
    // Init
    @Bindable public var list: CustomList
    @Binding public var selectedList: CustomList?
    
    // Data
    @Environment(\.modelContext) private var context
    @State private var document: PDFDocument?
    
    // Functional
    @FocusState private var newEntryInFocus: Bool
    @State private var newEntryName: String = ""
    @State private var searchString: String = ""
    @State private var isSearching: Bool = false
    @State private var isEditing: Bool = false
    @State private var showBusyIndicator: Bool = false
    @State private var showNoEntriesAlert: Bool = false
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    // Settings
    @AppStorage("accentColorID") private var accentColorID: Int = 0
    @AppStorage("moveToBottom") private var moveToBottom: Bool = true
    
    var filteredListEntries: [ListEntry] {
        guard let entries = list.listEntries else { return [] }
        let filteredEntries = searchString.isEmpty ? entries : entries.filter{ $0.name.localizedCaseInsensitiveContains(searchString) }
        switch list.sortBy {
            case .date:
                return filteredEntries.sorted { $0.dateAdded > $1.dateAdded }
            case .alphabetically:
                return filteredEntries.sorted { $0.name < $1.name }
        }
    }
    
    var filteredUncheckedItems: [ListEntry] { filteredListEntries.filter { !$0.checked } }
    var filteredCheckedItems: [ListEntry] { filteredListEntries.filter{ $0.checked } }
    
    var body: some View {
        List {
            if moveToBottom {
                ForEach(filteredUncheckedItems) { listEntry in
                    ListEntryView(listEntry: listEntry)
                }
                if !filteredCheckedItems.isEmpty {
                    Section("Completed (\(filteredCheckedItems.count))", isExpanded: Bindable(list).isCompletedSectionExpanded) {
                        ForEach(filteredCheckedItems) { listEntry in
                            ListEntryView(listEntry: listEntry)
                        }
                    }
                }
            } else {
                ForEach(filteredListEntries) { listEntry in
                    ListEntryView(listEntry: listEntry)
                }
            }
        }
        .tint(list.color.SwiftUIColor)
        .listStyle(.sidebar)
        .toolbarRole(sizeClass==UserInterfaceSizeClass.compact ? .automatic : .editor)
        .navigationTitle(list.name)
        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
        .toolbar(id: "listToolbar") {
            ToolbarItem(id: "search", placement: .primaryAction) {
                if sizeClass == .compact {
                    Button("Search", systemImage: "magnifyingglass") { isSearching.toggle() }
                }
            }
            
            ToolbarItem(id: "sort", placement: .secondaryAction) {
                Picker(selection: $list.sortBy.animation()) {
                    Label("Alphabetical", systemImage: "abc")
                        .tag(EntrySort.alphabetically)
                    Label("Newest", systemImage: "clock")
                        .tag(EntrySort.date)
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
            
            ToolbarItem(id: "edit", placement: .secondaryAction) {
                Button("Edit List", systemImage: "square.and.pencil", action: editList)
            }
            
			#if os(iOS)
            ToolbarItem(id: "share", placement: .secondaryAction) {
                ShareLink(item: PdfMaker(list: list), preview: SharePreview(list.name))
            }
			
            ToolbarItem(id: "print", placement: .secondaryAction) {
                Button("Print", systemImage: "printer", action: printList)
            }
			#endif
            
            ToolbarItem(id: "delete", placement: .secondaryAction) {
                Button("Delete List", systemImage: "trash", role: .destructive, action: deleteList)
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
            if showBusyIndicator {
                GroupBox {
                    ProgressView()
                } label: {
                    Label("Generating PDF", systemImage: "doc")
                }
                .padding(0)
                .contentShape(RoundedRectangle(cornerRadius: 10))
                .frame(width: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(list.color.SwiftUIColor)
                )
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !isSearching {
                HStack {
                    TextField("Add an Item", text: $newEntryName.animation())
                        .padding()
                        .padding(.trailing)
						#if os(iOS)
                        .background(Color(.tertiarySystemBackground).cornerRadius(10))
						#endif
                        .focused($newEntryInFocus)
                        .onTapGesture { newEntryInFocus = true }
                        .onSubmit(addNewEntry)
                        .submitLabel(.continue)
                    
                    Button(action: addNewEntry) {
                        Image(systemName: "plus")
                            .padding(.horizontal, 2)
                            .padding(.vertical, 4)
                            .font(.headline)
                    }
                    .buttonStyle(.bordered)
                    .disabled(newEntryName.isEmpty)
                    .tint(list.color.SwiftUIColor)
                }
                .padding()
				#if os(iOS)
                .background(Color(.systemGroupedBackground))
				#endif
                .transition(.move(edge: .bottom))
                .gesture(DragGesture(minimumDistance: 10).onEnded(tryDisableKeyboard))
            }
        }
        .sheet(isPresented: $isEditing) {
            ListDetailEditor(navigationTitle: "Edit List", buttonTitle: "Save Changes", listName: list.name, listIcon: list.image, listColor: list.color, action: saveEdits)
        }
        .alert("No Entries to print in checklist.", isPresented: $showNoEntriesAlert) {
            Button("OK") { }
        }
    }
    
    func saveEdits(listName: String, listIcon: Int, listColor: AvailableColors) {
        if (list.name != listName || list.color != listColor || list.image != listIcon) {
            list.name = listName
            list.color = listColor
            list.image = listIcon
            list.editDate = Date.now
        }
    }
    
    func tryDisableKeyboard(dragInfo: DragGesture.Value) {
        if dragInfo.translation.height > 20 {
            newEntryInFocus = false
        }
    }
    
    func addNewEntry() {
        if newEntryName.isEmpty {
            return
        }
        
        let newEntry = ListEntry(name: newEntryName)
        
        withAnimation {
            newEntry.list = list
            list.editDate = Date.now
        }
        
        newEntryName = ""
        newEntryInFocus = true
    }
    
    func editList() {
        isEditing.toggle()
    }
    
    func deleteList() {
        selectedList = nil
        context.delete(list)
    }
    
	#if os(iOS)
    func printList() {
        guard let entries = list.listEntries else { return  }
        
        if entries.count <= 0 {
            showNoEntriesAlert.toggle()
            return
        }
        
        Task {
            withAnimation {
                showBusyIndicator = true
            }
            
            let printer = Printer()
            
            // I added an overlay for this now I also want to see it.
            try await Task.sleep(for: .milliseconds(750 + Int.random(in: 0...500)))
            
            let pdf = PdfMaker(list: list).makePDF()
            
            try? printer.print(.pdfData(pdf))
            showBusyIndicator = false
        }
    }
	#endif
}
