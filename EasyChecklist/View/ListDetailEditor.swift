//
//  ListDetailEditor.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 10.03.24.
//

import SwiftUI
import AwesomeSwiftyComponents

struct ListDetailEditor: View {
    
    @Environment(\.dismiss) private var dismiss
    
    // Init
    public let navigationTitle: LocalizedStringKey
    public let buttonTitle: LocalizedStringKey
    
    // State
    @State public var listName: String = ""
    @State public var listIcon: Int = 0
    @State public var listColor: AvailableColors = .blue
    
    // Closure
    let action: (_ listName: String, _ listIcon: Int, _ listColor: AvailableColors) -> Void
    
    @FocusState private var listNameFocused: Bool
    
    var body: some View {
        NavigationStack{
            Form {
                Section("Name") {
                    TextField("Name", text: $listName)
                        .focused($listNameFocused)
                }
                
                Section("Accent Color") {
                    InlineColorPicker(selectedColor: $listColor, pickerStyle: .slim)
                }
                
                Section("Icon") {
                    IconPicker(newIcon: $listIcon)
                }
            }
            .navigationTitle(navigationTitle)
			#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
			#endif
            .toolbar{
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
            Button(buttonTitle, systemImage: availibleIcons[listIcon], action: save)
                .buttonStyle(.bordered)
                .controlSize(.large)
                .padding(.bottom, 15)
                .disabled(listName.isEmpty)
        }
        .tint(listColor.SwiftUIColor)
    }
    
    func save() {
        action(listName, listIcon, listColor)
        dismiss()
    }
}
