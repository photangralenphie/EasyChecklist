//
//  ListView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 11.02.24.
//

import SwiftUI
import InlineColorPicker

struct ListView: View {
    
    // Init
    let list: CustomList
    
    // Data
    @Environment(\.modelContext) private var context
    
    // Functional
    @FocusState private var newEntryInFocus: Bool
    @State private var newEntryName: String = ""
    
    // Settings
    @AppStorage("moveToBottom") private var moveToBottom: Bool = true
    
    var body: some View {
        Group {
            if let entries = list.listEntries {
                if entries.isEmpty {
                    ContentUnavailableView("No Entries", image: "plus")
                } else if moveToBottom {
                    List {
                        ForEach(entries) { listEntry in
                            if !listEntry.checked {
                                ListEntryView(listEntry: listEntry)
                            }
                        }
                        if entries.contains(where: \.checked) {
                            Section("Completed", isExpanded: Bindable(list).isCompletedSectionExpanded) {
                                ForEach(entries) { listEntry in
                                    if listEntry.checked {
                                        ListEntryView(listEntry: listEntry)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.sidebar)
                } else {
                    List {
                        ForEach(entries) { listEntry in
                            ListEntryView(listEntry: listEntry)
                        }
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
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
        .tint(GetColorByID(list.color))
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: editList){
                        Label("Edit", systemImage: "square.and.pencil")
                    }
                    Button(role: .destructive, action: deleteList) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image("ellipses.circle")
                }
            }
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
        
    }
    
    func deleteList() {
        
    }
}
