//
//  ListDetailEditor.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 10.03.24.
//

import SwiftUI
import AwsomeSwiftyComponents

struct ListDetailEditor: View {
    
    @Environment(\.dismiss) private var dismiss
    
    // Init
    public let navigationTitle: LocalizedStringKey
    public let buttonTitle: LocalizedStringKey
    
    // State
    @State public var listName: String = ""
    @State public var listIcon: Int = 0
    @State public var listColor: Int = 0
    
    // Closure
    let action: (_ listName: String, _ listIcon: Int, _ listColor: Int) -> Void
    
    @FocusState private var listNameFocused: Bool
    
    var body: some View {
        NavigationStack{
            Form {
                Section("Name") {
                    TextField("Name", text: $listName)
                        .focused($listNameFocused)
                }
                
                Section("Accent Color") {
                    InlineColorPicker(colorIndex: $listColor, pickerStyle: .slim)
                }
                
                Section("Icon") {
                    IconPicker(newIcon: $listIcon)
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
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
        .tint(GetColorByID(listColor))
    }
    
    func save() {
        action(listName, listIcon, listColor)
        dismiss()
    }
}
