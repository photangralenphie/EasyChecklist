//
//  AddListView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 07.10.22.
//

import SwiftUI
import InlineColorPicker

struct AddListView: View {
    
    @Binding public var selectedList: CustomList?
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    
    // List attributes for creation
    @State private var newListName: String = ""
    @State private var newListIcon: Int = 0
    @State private var newListColor: Int = 0
    
    @FocusState private var listNameFocused: Bool
    
    var body: some View {
        NavigationStack{
            Form {
                Section("Name") {
                    TextField("Name", text: $newListName)
                        .focused($listNameFocused)
                }
                
                Section("Accent Color") {
                    InlineColorPicker(colorIndex: $newListColor, pickerStyle: .slim)
                }
                
                Section("Icon") {
                    IconPicker(newIcon: $newListIcon)
                }
            }
            .navigationTitle("Add New List")
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
                
            Button(action: addNewList) {
                Label("Add New List", systemImage: availibleIcons[newListIcon])
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .padding(.bottom, 15)
            .disabled(newListName.isEmpty)
        }
    }
    
    func addNewList() {
        let newList = CustomList(name: newListName, color: newListColor, image: newListIcon)
        context.insert(newList)
        selectedList = newList
        dismiss()
    }
}
