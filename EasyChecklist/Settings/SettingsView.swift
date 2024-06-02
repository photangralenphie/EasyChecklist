//
//  SettingsView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 08.10.22.
//

import SwiftUI
import AwsomeSwiftyComponents
import LocalAuthentication

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss

    // Appearance
    @AppStorage("accentColorID") private var accentColorID: Int = 0
    @AppStorage("colorScheme") private var colorScheme: PreferredColorScheme = .systemDefault
    
    // General
    @AppStorage("showExhaustiveListDetails") private var showExhaustiveListDetails: Bool = true
    @AppStorage("useBiometricAuthentication") private var useBiometricAuthentication: Bool = false
    let context = LAContext()

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
                    ColorSchemeSwitcher(colorScheme: $colorScheme, showIcon: true)
                }
                
                Section("General") {
                    Toggle(isOn: $showExhaustiveListDetails.animation()) {
                        Label("Show Exhaustive List Details", systemImage: showExhaustiveListDetails ? "tag" : "tag.slash")
                            .contentTransition(.symbolEffect(.replace))
                            .labelStyle(CenteredImageLabelStyle())
                    }
                    
                    if context.biometryType != .none {
                        Toggle(isOn: $useBiometricAuthentication.animation()) {
                            Label("Lock using \(context.biometryType.name)", systemImage: context.biometryType.systemName)
                                .labelStyle(CenteredImageLabelStyle())
                        }
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
