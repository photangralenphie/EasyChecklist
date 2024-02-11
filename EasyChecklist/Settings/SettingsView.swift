//
//  SettingsView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 08.10.22.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    let componentsData = MyComponentData()

    // Sort options
    @AppStorage("strikeDoneEntries") private var strikePrivateEntries: Bool = true
    @AppStorage("sortListsBy") private var sortListsBy: Int = 0      // 0 = alphabetial, 1 = newest, 2 = recently edited
    @AppStorage("sortEntriesBy") private var sortEntriesBy: Int = 0  // 0 = alphabetial, 1 = newest
    
    // Not Implemented Yet
    @AppStorage("moveToBottom") private var moveToBottom: Bool = false
    @AppStorage("useiCloudSync") private var useiCloudSync: Bool = false
    @AppStorage("accentColor") private var accentColor: Int = 0
    
    
    var body: some View {
        NavigationStack{
            Form{
                Section(header: Text("Appearance")){
                    DisplayModeSetting()
                }
                
                Section(header: Text("Sorting")){
                    Picker(selection: $sortListsBy) {
                        Label("Alphabetical", systemImage: "a.square")
                            .tag(0)
                        Label("Newest", systemImage: "clock")
                            .tag(1)
                        Label("Edit Date", systemImage: "clock.arrow.2.circlepath")
                            .tag(2)
                    } label: {
                        Label("Checklists", systemImage: "arrow.up.arrow.down")
                    }
                    .pickerStyle(.automatic)
                    
                    Toggle(isOn: $strikePrivateEntries) {
                        Label("Strike Done Items", systemImage: "strikethrough")
                    }
                }
                
                Section(header: Text("Not Implemented Yet")){
                    Picker(selection: $sortEntriesBy) {
                        Label("Alphabetical", systemImage: "a.square")
                            .tag(0)
                        Label("Newest", systemImage: "clock")
                            .tag(1)
                    } label: {
                        Label("List Entries", systemImage: "arrow.up.arrow.down")
                    }
                    .pickerStyle(.automatic)
                    
                    Toggle(isOn: $moveToBottom, label: {
                        Label("Move checked items to bottom", systemImage: "checkmark.circle")
                    })
                    .toggleStyle(SwitchToggleStyle())
                    
                    Toggle(isOn: $useiCloudSync, label: {
                        Label("iCloud Sync", systemImage: "icloud")
                    })
                    .toggleStyle(SwitchToggleStyle())
                    
                    MyColorPicker(newColor: $accentColor)
                }
            }
            .navigationTitle("Settings")
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .accentColor(Color(hex: componentsData.availibleColors[accentColor]))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
