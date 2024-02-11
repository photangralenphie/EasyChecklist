//
//  ListView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 11.02.24.
//

import SwiftUI

struct ListView: View {
    
    @Environment(\.modelContext) private var context
    let componentsData = MyComponentData()
    let list: CustomList
    
    // For focusing on Textfield for new ListEntry
    @FocusState var newEntryInFocus: Bool
    @State private var newEntryName: String = ""
    
    var body: some View {
        Group {
            if let entries = list.listEntries {
                if entries.isEmpty {
                    ContentUnavailableView("No Entries", image: "plus")
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
                    .onTapGesture {
                        newEntryInFocus = true
                    }
                    .onSubmit(addNewEntry)
                Button {
                    addNewEntry()
                } label: {
                    Image(systemName: "plus")
                        .padding(.horizontal, 2)
                        .padding(.vertical, 4)
                        .font(.headline)
                }
                .buttonStyle(.bordered)
                .tint(Color(hex: componentsData.availibleColors[list.color]))
            }
            .padding()
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle(list.name)
    }
    
    func addNewEntry() {
        let newEntry = ListEntry(name: newEntryName)
        newEntry.list = list
        list.editDate = Date.now
        newEntryName = ""
    }
}
