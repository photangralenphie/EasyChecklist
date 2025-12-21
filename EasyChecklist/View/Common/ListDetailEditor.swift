//
//  ListDetailEditor.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 10.03.24.
//

import SwiftUI
import AwesomeSwiftyComponents

struct ListDetailEditor: View {
    
	@Environment(HomeVm.self) private var homeVm
    @Environment(\.dismiss) private var dismiss
	@FocusState private var listNameFocused: Bool
	
	@State private var vm: any ListDetailEditorVm
	
	init(list: CustomList? = nil) {
		if let list {
			vm = EditListDetailEditorVm(list: list)
		} else {
			vm = CreateListDetailEditorVm()
		}
	}
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
					TextField("Name", text: $vm.listName)
                        .focused($listNameFocused)
						.listGlassCell()
                }
                
                Section("Accent Color") {
					InlineColorPicker(selectedColor: $vm.listColor, pickerStyle: .slim)
						.listGlassCell()
                }
                
                Section("Icon") {
					IconPicker(selectedIcon: $vm.listIcon)
						.padding()
						.listRowBackground(
							Color.clear
								.glassEffect(.clear.interactive(), in: .rect(cornerRadius: 30, style: .continuous))
						)
                }
            }
			.navigationTitle(vm.navigationTitle)
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
					Button(vm.buttonTitle, systemImage: "checkmark", role: .confirm, action: save)
						.disabled(vm.listName.isEmpty)
				}
            }
        }
		.tint(vm.listColor.SwiftUIColor)
		.scrollContentBackground(.hidden)
		.background(BackgroundGradientView(vm: homeVm.backgroundVm))
		.onAppear(perform: updateBackground)
		.onChange(of: vm.listColor, updateBackground)
    }
	
	private func updateBackground() {
		homeVm.backgroundVm.setBackgroundColor(vm.listColor, reason: .listUpdate)
	}
	
	private func save() {
		vm.save(homeVm: homeVm)
		dismiss()
	}
}

#Preview {
	@Previewable @State var vm = HomeVm()
	NavigationStack {
		ListDetailEditor(list: CustomList.exampleList)
			.environment(vm)
	}
}
