//
//  ContentView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 16.02.24.
//

import SwiftUI
import SwiftData
import PrintingKit
import AwesomeSwiftyComponents

struct ContentView: View {
    
    // Init
    @Query private var lists: [CustomList]
    @Binding private var sortOrder: ListSort
    @Binding private var isAscendingSort: Bool
    
    init(sortOrder: Binding<ListSort>, isAscendingSort: Binding<Bool>) {
        let sortDescriptors: [SortDescriptor<CustomList>] = switch sortOrder.wrappedValue {
        case .alphabetically:
            [SortDescriptor(\CustomList.name, order: isAscendingSort.wrappedValue ? .forward : .reverse)]
        case .creationDate:
            [SortDescriptor(\CustomList.creationDate, order: isAscendingSort.wrappedValue ? .reverse : .forward)]
        case .modified:
            [SortDescriptor(\CustomList.editDate, order: isAscendingSort.wrappedValue ? .reverse : .forward)]
        }
        
        _isAscendingSort = isAscendingSort
        _sortOrder = sortOrder
        _lists = Query(sort: sortDescriptors, animation: .snappy)
    }
    
    // Functional
    @Environment(\.modelContext) private var context
    @State private var selectedList: CustomList?
    @State private var searchString: String = ""
    
    // Sheets
    @State private var showSettings: Bool = false
    @State private var newCustomList: Bool = false
    
    // Empty List printing
    @State private var showEmptyPrintOptions: Bool = false
    @State private var emptyPrintListName: String = ""
    @State private var emptyPrintListNumEntries: Int?
    
    var filteredLists: [CustomList] {
        searchString.isEmpty ? lists : lists.filter{ $0.name.localizedCaseInsensitiveContains(searchString) }
    }
    
    var body: some View {
        NavigationSplitView {
            List(filteredLists, selection: $selectedList) { list in
                ChecklistCellView(list: list)
            }
			#if os(iOS)
			.listRowSpacing(10)
			#endif
			.navigationTitle("Checklists")
            .overlay {
                if searchString.isEmpty && filteredLists.isEmpty {
                    ContentUnavailableView {
                        Label("Add a List", systemImage: "plus")
                    } description: {
                        Text("Get started by adding a list with the button below.")
                    } actions: {
                        Button("Add List", systemImage: "plus") { newCustomList.toggle() }
                            .buttonStyle(.bordered)
                    }
                } else if filteredLists.isEmpty {
                    ContentUnavailableView.search(text: searchString)
                }
            }
            .toolbar {
				#if os(iOS)
				ToolbarItem(placement: .navigation) {
					Button("Settings", systemImage: "gear") { showSettings.toggle() }
				}
				#endif
				
                ToolbarItem(placement: .primaryAction) {
                    Button("Add List", systemImage: "plus") { newCustomList.toggle() }
                }
                
                ToolbarItem(placement: .secondaryAction) {
                    Menu("Sort by", systemImage: "arrow.up.arrow.down") {
                        Picker(selection: $sortOrder.animation()) {
                            Label("Alphabetically", systemImage: "textformat.abc")
                                .tag(ListSort.alphabetically)
                            Label("Newest", systemImage: "calendar")
                                .tag(ListSort.creationDate)
                            Label("Modified", systemImage: "eraser.line.dashed.fill")
                                .tag(ListSort.modified)
                        } label: {
                            Text("Sort")
                        }
                        
                        ControlGroup("Order") {
                            Button {
                                withAnimation { isAscendingSort = true }
                            } label: {
                                Label("Ascending", image: isAscendingSort ? "arrow.up.badge.checkmark" : "arrow.up")
                            }
                            Button {
                                withAnimation { isAscendingSort = false }
                            } label: {
                                Label("Descending", image: isAscendingSort ? "arrow.down" : "arrow.down.badge.checkmark")
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        showEmptyPrintOptions.toggle()
                    } label: {
                        Label("Print Empty Checklist", systemImage: "printer")
                    }
                }
            }
        } detail: {
            if lists.isEmpty {
                ContentUnavailableView("No Checklists", systemImage: "plus", description: Text("Get Started by adding a new Checklist with the plus button"))
            } else if let list = selectedList {
                ListView(list: list)
            } else {
                ContentUnavailableView("Nothing Selected", systemImage: "filemenu.and.selection", description: Text("Select a Checklist in the Sidebar"))
            }
        }
		.searchable(text: $searchString, placement: .sidebar)
		.sheet(isPresented: $newCustomList) {
			ListDetailEditor(navigationTitle: "Add New List", buttonTitle: "Add New List", action: addNewList)
		}
		#if os(iOS)
        .inspector(isPresented: $showSettings) {
            SettingsView()
                .presentationDetents([.large])
                .presentationBackground(.ultraThinMaterial)
        }
		.alert("Print Empty Checklist", isPresented: $showEmptyPrintOptions) {
			TextField("Name", text: $emptyPrintListName)
			TextField("Number Empty Items", value: $emptyPrintListNumEntries, format: .number)
				.keyboardType(.numberPad)
			Button("Cancel", role: .cancel, action: resetEmptyPrintList)
			Button("Print", action: printEmptyList)
				.disabled(emptyPrintListNumEntries == nil || emptyPrintListName == "")
		}
		#endif
    }
    
    func addNewList(listName: String, listIcon: Int, listColor: AvailableColors) {
        let newList = CustomList(name: listName, color: listColor, image: listIcon)
        context.insert(newList)
        selectedList = newList
    }
    
	#if os(iOS)
    func printEmptyList() {
        guard let num = emptyPrintListNumEntries else { return }
        Task {
            let printer = Printer()
            let pdf = PdfMaker(name: emptyPrintListName, numEmptyItems: num).makePDF()
            try? printer.print(.pdfData(pdf))
        }
        resetEmptyPrintList()
    }
	#endif
    
    func resetEmptyPrintList() {
        emptyPrintListName = ""
        emptyPrintListNumEntries = nil
        showEmptyPrintOptions.toggle()
    }
}
