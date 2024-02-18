//
//  EditListView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 13.10.22.
//

import SwiftUI
import InlineColorPicker

struct EditListView: View {
    @Environment(\.dismiss) var dismiss
    
    let list: CustomList
    
    @State public var newListName: String = ""
    @State public var newListColor: Int = 0
    @State public var newListIcon: Int = 0
    
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
                
            Button(action: editList) {
                Label("Save Changes", systemImage: availibleIcons[newListIcon])
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .padding(.bottom, 5)
            .disabled(newListName.isEmpty)
        }
        .onAppear(){
            newListName = list.name
            newListIcon = list.image
            newListColor = list.color
        }
    }
    
    func editList() {
        if (list.name != newListName || list.color != newListColor || list.image != newListIcon) {
            list.name = newListName
            list.color = newListColor
            list.image = newListIcon
            list.editDate = Date.now
            dismiss()
        }
    }
}
