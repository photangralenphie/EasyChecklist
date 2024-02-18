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
    
    
    init(sortOrder: ListSort, isReverseSort: Bool, selectedList: Binding<CustomList?>) {
        let sortDescriptors: [SortDescriptor<CustomList>] = switch sortOrder {
        case .alphabetically:
            [SortDescriptor(\CustomList.name, order: !isReverseSort ? .forward : .reverse)]
        case .creationDate:
            [SortDescriptor(\CustomList.creationDate, order: isReverseSort ? .forward : .reverse)]
        case .modified:
            [SortDescriptor(\CustomList.editDate, order: isReverseSort ? .forward : .reverse)]
        }
        
        _lists = Query(sort: sortDescriptors)
        _selectedList = selectedList
    }
    
    var body: some View {
        List(selection: $selectedList){
            ForEach(lists) { list in
                NavigationLink(value: list) {
                    Label {
                        Text(list.name)
                    } icon: {
                        Image(systemName: availibleIcons[list.image])
                            .foregroundStyle(GetColorByID(list.color))
                    }
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
}
