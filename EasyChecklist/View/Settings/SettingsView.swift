//
//  SettingsView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 08.10.22.
//

import SwiftUI
import AwesomeSwiftyComponents

struct SettingsView: View {
    
	@Environment(\.horizontalSizeClass) var horizontalSizeClass

    // Appearance
	@AppStorage(PreferenceKeys.accentColorSchema) private var accentColorSchema: AvailableColors = .blue
	@AppStorage(PreferenceKeys.colorScheme) private var colorScheme: PreferredColorScheme = .systemDefault
    
    // General
	@AppStorage(PreferenceKeys.showExhaustiveListDetails) private var showExhaustiveListDetails: Bool = true

    // List Entries
	@AppStorage(PreferenceKeys.strikeCheckedEntries) private var strikeCheckedEntries: Bool = true
	@AppStorage(PreferenceKeys.moveToBottom) private var moveToBottom: Bool = true
	
	@Environment(HomeVm.self) private var homeVm
	
    var body: some View {
		NavigationStack {
			Form {
				Section {
					InlineColorPicker(selectedColor: $accentColorSchema, description: "Theme Color", systemImage: "paintbrush")
						.listGlassCell(in: .rect())
						.onChange(of: accentColorSchema) { setBackground() }
					ColorSchemeSwitcher(colorScheme: $colorScheme, showIcon: true)
						.listGlassCell()
				} header: {
					Text("Appearance")
				} footer: {
					Text("Setting your Accent Color to Primary will use white on Darkmode and black in Lightmode.")
				}
				
				Section("General") {
					Toggle(isOn: $showExhaustiveListDetails.animation()) {
						Label("Show Exhaustive List Details", systemImage: showExhaustiveListDetails ? "tag" : "tag.slash")
							.contentTransition(.symbolEffect(.replace))
							.labelStyle(.centeredImage)
					}
					.listGlassCell()
				}
				
				Section("List Entries"){
					Toggle(isOn: $strikeCheckedEntries) {
						Label("Strike Done Items", systemImage: "strikethrough")
							.symbolEffect(.bounce, value: strikeCheckedEntries)
							.labelStyle(.centeredImage)
					}
					.listGlassCell()
					
					Toggle(isOn: $moveToBottom) {
						Label("Move Checked Items to Bottom", systemImage: "checkmark.circle")
							.symbolEffect(.bounce, value: moveToBottom)
							.labelStyle(.centeredImage)
					}
					.listGlassCell()
				}
							
				#if os(iOS)
				Section {
					Button(action: openSystemSettings) {
						Label("Open System Settings", systemImage: "arrow.up.right.square")
							.labelStyle(.centeredImage)
					}
					.listGlassCell()
				} header: {
					Text("Language etc.")
				} footer: {
					Text("Here you can set the language of EasyChecklist and manage permissions like to use Face-ID or Touch-ID.")
				}

				LinkedCreditManager(systemImage: "c.circle") {
					LicenceLink(licence: .mit(name: "PrintingKit", author: "Daniel Saidi", year: "2023 - 2024"))
					LicenceLink(licence: .mit(name: "TPPDF", author: "Philip Niedertscheider", year: "2016 - 2024"))
				}
				.listGlassCell()
				#endif
			}
			.navigationTitle("Settings")
			.scrollEdgeEffectStyle(.soft, for: .top)
			.preferredColorScheme(colorScheme.mode)
			.scrollContentBackground(.hidden)
			.listRowSpacing(LayoutConstants.listItemSpacing)
			.toolbarTitleDisplayMode(.inlineLarge)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button("Done", systemImage: "checkmark") { homeVm.showSettings = false /*dismiss()*/ }
						.labelStyle(.iconOnly)
						.buttonStyle(.glassProminent)
				}
			}
		}
		.onAppear { setBackground() }
		.scrollContentBackground(.hidden)
		.background { BackgroundGradientView(vm: homeVm.backgroundVm) }
    }
    
	func setBackground() {
		homeVm.backgroundVm.setBackgroundColor(accentColorSchema, reason: .accentColorChange)
	}
	
    func openSystemSettings() {
		#if os(iOS)
		if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
		#endif
    }
}

#Preview {
	NavigationStack {
		Text("Hello, World!")
			.sheet(isPresented: .constant(true)) {
				SettingsView()
					.environment(HomeVm())
			}
	}
}
