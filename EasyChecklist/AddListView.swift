//
//  AddListView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 07.10.22.
//

import SwiftUI

struct AddListView: View {
    
    @Environment(\.modelContext) private var context
    //@Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    // List attributes for creation
    let componentsData = MyComponentData()
    @State private var newListName: String = ""
    @State private var newListIcon: Int = 0
    @State private var newListColor: Int = 0
    
    @State private var noNameAlert: Bool = false
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
            
            .alert("No Name!", isPresented: $noNameAlert) {
                Button("OK") {
                    listNameFocused = true
                }
            } message: {
                Text("Please ensure you give the list a name to create it.")
            }
                
            Button {
                if (newListName != "") {
                    let newList = CustomList(name: newListName, color: newListColor, image: newListIcon)
                    context.insert(newList)
                    dismiss()
                } else {
                    noNameAlert.toggle()
                }
            } label: {
                Label("Add New List", systemImage: componentsData.availibleIcons[newListIcon])
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .tint(Color(hex: componentsData.availibleColors[newListColor]))
            .padding(.bottom, 15)
            .disabled(newListName.isEmpty)
        }
        .accentColor(Color(hex: componentsData.availibleColors[newListColor]))
    }
}

struct AddListView_Previews: PreviewProvider {
    static var previews: some View {
        AddListView()
    }
}
