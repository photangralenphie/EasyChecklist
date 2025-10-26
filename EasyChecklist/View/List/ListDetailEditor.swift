//
//  ListDetailEditor.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 10.03.24.
//

import SwiftUI
import AwesomeSwiftyComponents
import SwiftUIIntrospect

struct ListDetailEditor: View {
    
    @Environment(\.dismiss) private var dismiss
    
    // Init
    public let navigationTitle: LocalizedStringKey
    public let buttonTitle: LocalizedStringKey
    
    // State
    @State public var listName: String = ""
	@State public var listIcon: String = IconPicker.defaultIcon
	@State public var listColor: AvailableColors = {
		let userColor = UserDefaults.standard.integer(forKey: PreferenceKeys.accentColorSchema)
		return AvailableColors(rawValue: userColor) ?? .blue
	}()
    
    // Closure
    let action: (_ listName: String, _ listIcon: String, _ listColor: AvailableColors) -> Void
    
    @FocusState private var listNameFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Name", text: $listName)
                        .focused($listNameFocused)
						.listGlassCell()
                }
                
                Section("Accent Color") {
                    InlineColorPicker(selectedColor: $listColor, pickerStyle: .slim)
						.listGlassCell()
                }
                
                Section("Icon") {
					IconPicker(selectedIcon: $listIcon)
						.padding()
						.listRowBackground(
							Color.clear
								.glassEffect(.clear.interactive(), in: .rect(cornerRadius: 20, style: .continuous))
						)
                }
            }
            .navigationTitle(navigationTitle)
			.formStyle(.grouped)
			.scrollContentBackground(.hidden)
			#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
			#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark", role: .cancel) { dismiss() }
                }
				
				ToolbarItem(placement: .confirmationAction) {
					Button(buttonTitle, systemImage: "checkmark", role: .confirm, action: save)
						.disabled(listName.isEmpty)
				}
            }
        }
        .tint(listColor.SwiftUIColor)
		.scrollContentBackground(.hidden)
		.background(BackgroundGradientView(vm: BackgroundGradientVm(baseColor: listColor)))
    }
    
    func save() {
        action(listName, listIcon, listColor)
        dismiss()
    }
}

#Preview {
	NavigationStack {
		ListDetailEditor(navigationTitle: "Edit", buttonTitle: "Save") { _, _, _ in }
	}
}
