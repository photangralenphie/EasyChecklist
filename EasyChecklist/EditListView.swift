//
//  EditListView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 13.10.22.
//

import SwiftUI

struct EditListView: View {
    @Environment(\.dismiss) var dismiss
    
    // List attributes for creation
    let componentsData = MyComponentData()
    
    let list: CustomList
    
    @State public var newListName: String = ""
    @State public var newListColor: Int = 0
    @State public var newListIcon: Int = 0
    
    @FocusState private var listNameFocused: Bool
    
    var body: some View {
        NavigationStack{
            Form {
                Section {
                    TextField("Name", text: $newListName)
                        .focused($listNameFocused)
                } header: {
                    Text("Name")
                }
                
                Section {
                    MyColorPicker(newColor: $newListColor)
                } header: {
                    Text("Accent Color")
                }
                
                Section {
                    MyIconPicker(newIcon: $newListIcon, newColor: $newListColor)
                } header: {
                    Text("Icon")
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
                
            Button {
                if (list.name != newListName || list.color != newListColor || list.image != newListIcon) {
                    list.name = newListName
                    list.color = newListColor
                    list.image = newListIcon
                    list.editDate = Date.now
                    dismiss()
                }
            } label: {
                Label("Save Changes", systemImage: componentsData.availibleIcons[newListIcon])
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .tint(Color(hex: componentsData.availibleColors[newListColor]))
            .padding(.bottom, 5)
            .disabled(newListName.isEmpty)
        }
        .onAppear(){
            newListName = list.name
            newListIcon = list.image
            newListColor = list.color
        }
        .accentColor(Color(hex: componentsData.availibleColors[newListColor]))
    }
}
