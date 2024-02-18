//
//  SettingsView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 08.10.22.
//

import SwiftUI
import InlineColorPicker
import ColorSchemeSwitcher

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss

    // Appearance
    @AppStorage("accentColorID") private var accentColorID: Int = 0
    @AppStorage("colorScheme") private var colorScheme: PreferredColorScheme = .systemDefault
    
    // Items
    @AppStorage("strikeCheckedEntries") private var strikeCheckedEntries: Bool = true
    @AppStorage("moveToBottom") private var moveToBottom: Bool = true
    
    // Not Implemented Yet
    @AppStorage("useiCloudSync") private var useiCloudSync: Bool = false

    var body: some View {
        NavigationStack{
            Form{
                Section("Appearance"){
                    InlineColorPicker(colorIndex: $accentColorID, pickerStyle: .expanded)
                    ColorSchemeSwitcher(colorScheme: $colorScheme, showIcon: true, accentColor: GetColorByID(accentColorID))
                }
                
                Section("Item"){
                    Toggle(isOn: $strikeCheckedEntries) {
                        Label("Strike Done Items", systemImage: "strikethrough")
                    }
                    
                    Toggle(isOn: $moveToBottom) {
                        Label("Move Checked Items to Bottom", systemImage: "checkmark.circle")
                    }
                }
                
                Section("Not Implemented Yet"){
                    Toggle(isOn: $useiCloudSync) {
                        Label("iCloud Sync", systemImage: "icloud")
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .preferredColorScheme(colorScheme.mode())
    }
}
