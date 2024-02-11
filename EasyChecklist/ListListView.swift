//
//  ContentView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 07.10.22.
//

import SwiftUI
import SwiftData

struct ListListView: View {
    
    //@Environment(\.managedObjectContext) var moc
    @Environment(\.modelContext) private var context
    
    @AppStorage("accentColor") private var accentColor: String = "147efb"
    let componentsData = MyComponentData()
    
    @Query(sort: \CustomList.name) private var lists: [CustomList]
    @AppStorage("sortListsBy") private var sortListsBy: Int = 0   // 0 = alphabetial, 1 = newest, 2 = recently edited
    
    //For Sheet to create new List to edit List and to open Settings
    @State private var newCustomList: Bool = false
    @State private var editCustomList: Bool = false
    @State private var showSettings: Bool = false
    
    //Binding Selection of List to show in detail view
    @State private var selectedList: CustomList?
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedList){
                ForEach(lists) { list in
                    NavigationLink(value: list) {
                        Label {
                            Text(list.name)
                        } icon: {
                            Image(systemName: componentsData.availibleIcons[list.image])
                                .foregroundColor(Color(hex: componentsData.availibleColors[list.color]))
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
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if !lists.isEmpty {
                        EditButton()
                    }
                    
                    Button {
                        newCustomList.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $newCustomList) {
                AddListView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .navigationTitle("Checklists")
        } detail: {
            if let list = selectedList {
                ListView(list: list)
            } else {
                ContentUnavailableView("Add a new List", image: "plus")
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
}
