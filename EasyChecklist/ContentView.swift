//
//  ContentView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 16.02.24.
//

import SwiftUI
import SwiftData
import InlineColorPicker
import LocalAuthentication

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
    
    // Sheets
    @State private var showSettings: Bool = false
    @State private var newCustomList: Bool = false
    
    @State private var selectedList: CustomList?
    
    @State private var searchString: String = ""
    
    @Environment(\.modelContext) private var context
    
    var filteredLists: [CustomList] {
        searchString.isEmpty ? lists : lists.filter{ $0.name.localizedCaseInsensitiveContains(searchString) }
    }
    
    var body: some View {
        NavigationSplitView {
            List(filteredLists, selection: $selectedList.animation()) { list in
                ChecklistCellView(list: list)
            }
            .listSectionSpacing(10)
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
                ToolbarItem(placement: .navigation) {
                    Button("Settings", systemImage: "gear") { showSettings.toggle() }
                }
                
                ToolbarItemGroup(placement: .primaryAction) {
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
                    
                    Button("Add List", systemImage: "plus") { newCustomList.toggle() }
                }
            }
            .sheet(isPresented: $newCustomList) {
                ListDetailEditor(navigationTitle: "Add New List", buttonTitle: "Add New List", action: addNewList)
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .navigationTitle("Checklists")
        } detail: {
            if let list = selectedList {
                ListView(list: list, selectedList: $selectedList)
            } else {
                ContentUnavailableView("No Checklists", image: "plus", description: Text("Get Started by adding a new Checklist with the plus button"))
            }
        }
        .searchable(text: $searchString)
    }
    
    func addNewList(listName: String, listIcon: Int, listColor: Int) {
        let newList = CustomList(name: listName, color: listColor, image: listIcon)
        context.insert(newList)
        selectedList = newList
    }
}
