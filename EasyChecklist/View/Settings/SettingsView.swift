//
//  SettingsView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 08.10.22.
//

import SwiftUI
import AwesomeSwiftyComponents

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss

    // Appearance
	@AppStorage(PreferenceKeys.accentColorSchema) private var accentColorSchema: AvailableColors = .blue
    @AppStorage("colorScheme") private var colorScheme: PreferredColorScheme = .systemDefault
    
    // General
    @AppStorage("showExhaustiveListDetails") private var showExhaustiveListDetails: Bool = true

    // List Entries
    @AppStorage("strikeCheckedEntries") private var strikeCheckedEntries: Bool = true
    @AppStorage("moveToBottom") private var moveToBottom: Bool = true
    
    // Not Implemented Yet
    @AppStorage("useiCloudSync") private var useiCloudSync: Bool = false
    
    var body: some View {
        Form {
            Section{
				InlineColorPicker(selectedColor: $accentColorSchema, pickerStyle: .expanded(systemImage: "paintbrush", description: "Theme Color"))
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
						
			#if os(iOS)
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

			LinkedCreditManager(systemImage: "c.circle") {
				LicenceLink(licence: .mit(name: "PrintingKit", author: "Daniel Saidi", year: "2023 - 2024"))
				LicenceLink(licence: .mit(name: "TPPDF", author: "Philip Niedertscheider", year: "2016 - 2024"))
			}
			#endif
        }
        .toolbar {
			ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
        .preferredColorScheme(colorScheme.mode)
    }
    
    func openSystemSettings() {
		#if os(iOS)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
		#endif
    }
}
