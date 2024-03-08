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
    
    // General
    @AppStorage("showExhaustiveListDetails") private var showExhaustiveListDetails: Bool = true
    
    // List Entries
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
                
                Section("General") {
                    Toggle(isOn: $showExhaustiveListDetails.animation()) {
                        Label("Show Exhaustive List Details", systemImage: showExhaustiveListDetails ? "tag" : "tag.slash")
                            .contentTransition(.symbolEffect(.replace))
                    }
                }
                
                Section("List Entries"){
                    Toggle(isOn: $strikeCheckedEntries) {
                        Label("Strike Done Items", systemImage: "strikethrough")
                            .symbolEffect(.bounce, value: strikeCheckedEntries)
                    }
                    
                    Toggle(isOn: $moveToBottom) {
                        Label("Move Checked Items to Bottom", systemImage: "checkmark.circle")
                            .symbolEffect(.bounce, value: moveToBottom)
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
