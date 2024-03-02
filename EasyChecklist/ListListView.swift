//
//  ContentView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 07.10.22.
//

import SwiftUI
import SwiftData
import InlineColorPicker

struct ListListView: View {
    
    @Query private var lists: [CustomList]
    @Environment(\.modelContext) private var context
    
    @Binding private var selectedList: CustomList?
    @State private var editCustomList: Bool = false
    
    @AppStorage("showListDetails") private var showListDetails: Bool = true
    
    @State private var searchString: String = ""
    var filteredLists: [CustomList] {
        if searchString.isEmpty {
            return lists
        } else {
            return lists.filter{ $0.name.localizedCaseInsensitiveContains(searchString) }
        }
    }
    
    init(sortOrder: ListSort, isAscendingSort: Bool, selectedList: Binding<CustomList?>) {
        let sortDescriptors: [SortDescriptor<CustomList>] = switch sortOrder {
        case .alphabetically:
            [SortDescriptor(\CustomList.name, order: isAscendingSort ? .forward : .reverse)]
        case .creationDate:
            [SortDescriptor(\CustomList.creationDate, order: isAscendingSort ? .reverse : .forward)]
        case .modified:
            [SortDescriptor(\CustomList.editDate, order: isAscendingSort ? .reverse : .forward)]
        }
        
        _lists = Query(sort: sortDescriptors)
        _selectedList = selectedList
    }
    
    var body: some View {
        List(selection: $selectedList){
            ForEach(filteredLists) { list in
                NavigationLink(value: list) {
                    Label {
                        VStack(alignment: .leading) {
                            Text(list.name)
                            if showListDetails {
                                if let listEntries = list.listEntries {
                                    Text("^[\(listEntries.count) Entry](inflect: true) - \(getDoneItems(listEntries: listEntries)) Done - \(getToDoItems(listEntries: listEntries)) ToDo")
                                        .font(.footnote)
                                        .foregroundStyle(Color.secondary)
                                }
                            }
                        }
                    } icon: {
                        Image(systemName: availibleIcons[list.image])
                            .foregroundStyle(GetColorByID(list.color))
                    }
                    .labelStyle(CenteredImageLabelStyle())
                }
                .sheet(isPresented: $editCustomList) { EditListView(list: list) }
                .swipeActions(edge: .leading) {
                    Button("Edit") { editCustomList.toggle() }
                }
                .contextMenu {
                    Button {
                        editCustomList.toggle()
                    } label: {
                        Label("Edit", systemImage: "slider.horizontal.3")
                    }
                    
                    Button(role: .destructive){
                        deleteListContextMenu(list)
                    } label: {
                        Label("Delete List", systemImage: "trash")
                    }
                }
            }
            .onDelete(perform: deleteList)
        }
        .searchable(text: $searchString)
        .overlay {
            if filteredLists.isEmpty {
                ContentUnavailableView.search(text: searchString)
            }
        }
    }
    
    func deleteList(at indexSet: IndexSet) {
        indexSet.forEach { index in
            let book = lists[index]
            context.delete(book)
        }
    }
        
    func deleteListContextMenu(_ deleteList: CustomList) {
        withAnimation {
            context.delete(deleteList)
        }
    }
    
    func getDoneItems(listEntries: [ListEntry]) -> Int {
        return listEntries.filter { $0.checked == true }.count
    }
    
    func getToDoItems(listEntries: [ListEntry]) -> Int {
        return listEntries.filter { $0.checked == false }.count
    }
}

struct CenteredImageLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center) {
            configuration.icon
                .frame(width: 25)
            configuration.title
                .padding(.leading, 5)
        }
    }
}
