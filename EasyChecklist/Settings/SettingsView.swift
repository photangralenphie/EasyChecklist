//
//  SettingsView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 08.10.22.
//

import SwiftUI
import AwesomeSwiftyComponents

struct SettingsView: View {
    
    @Binding public var showSettings: Bool
    //@Environment(\.dismiss) var dismiss

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
        Form{
            Section{
                InlineColorPicker(colorIndex: $accentColorID, pickerStyle: .expanded)
                ColorSchemeSwitcher(colorScheme: $colorScheme, showIcon: true)
            } header: {
                Text("Appearance")
            } footer: {
                Text("Setting your Accent Color to Primary will use white on Darkmode and black in Lightmode.")
            }
            
            Section("General") {
                Toggle(isOn: $showExhaustiveListDetails.animation()) {
                    Label("Show Exhaustive List Details", systemImage: showExhaustiveListDetails ? "tag" : "tag.slash")
                        .contentTransition(.symbolEffect(.replace))
                        .labelStyle(CenteredImageLabelStyle())
                }
            }
            
            Section("List Entries"){
                Toggle(isOn: $strikeCheckedEntries) {
                    Label("Strike Done Items", systemImage: "strikethrough")
                        .symbolEffect(.bounce, value: strikeCheckedEntries)
                        .labelStyle(CenteredImageLabelStyle())
                }
                
                Toggle(isOn: $moveToBottom) {
                    Label("Move Checked Items to Bottom", systemImage: "checkmark.circle")
                        .symbolEffect(.bounce, value: moveToBottom)
                        .labelStyle(CenteredImageLabelStyle())
                }
            }
            Section {
                Button(action: openSystemSettings) {
                    Label("Open System Settings", systemImage: "arrow.up.right.square")
                        .labelStyle(CenteredImageLabelStyle())
                }
            } header: {
                Text("Language etc.")
            } footer: {
                Text("Here you can set the language of EasyChecklist and manage permissions like to use Face-ID or Touch-ID.")
            }

            
            Section("Not Implemented Yet"){
                Toggle(isOn: $useiCloudSync) {
                    Label("iCloud Sync", systemImage: "icloud")
                        .labelStyle(CenteredImageLabelStyle())
                }
            }
            
            NavigationLink {
                CreditsView()
            } label: {
                Label("Credits", systemImage: "c.circle")
                    .labelStyle(CenteredImageLabelStyle())
            }
        }
        .toolbar{
            ToolbarItem(placement: .principal) {
                Text("Settings")
                    .fontWeight(.bold)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { showSettings.toggle() }
            }
        }
        .preferredColorScheme(colorScheme.mode())
    }
    
    func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
