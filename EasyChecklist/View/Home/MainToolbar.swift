//
//  MainToolbar.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 28.10.25.
//

import SwiftUI

struct MainToolbar: ToolbarContent {
	
	let transition: Namespace.ID
	
	@Environment(HomeVm.self) private var vm
	
    var body: some ToolbarContent {
		#if os(iOS)
		ToolbarItemGroup(placement: .bottomBar) {
			Menu("Sort by", systemImage: "arrow.up.arrow.down") {
				Picker(selection: Bindable(vm).sortOrder.animation()) {
					Label("Alphabetically", systemImage: "textformat.abc")
						.tag(ListSort.alphabetically)
					Label("Newest", systemImage: "calendar")
						.tag(ListSort.creationDate)
					Label("Modified", systemImage: "eraser.line.dashed.fill")
						.tag(ListSort.modified)
				} label: {
					Text("Sort")
				}
				
				ControlGroup("Order") {
					Button {
						withAnimation { vm.isAscendingSort = true }
					} label: {
						Label("Ascending", image: vm.isAscendingSort ? "arrow.up.badge.checkmark" : "arrow.up")
					}
					Button {
						withAnimation { vm.isAscendingSort = false }
					} label: {
						Label("Descending", image: vm.isAscendingSort ? "arrow.down" : "arrow.down.badge.checkmark")
					}
				}
			}
			
			Button("Print Empty Checklist", systemImage: "printer") {
				vm.showEmptyPrintOptions.toggle()
			}
		}

		ToolbarSpacer(.fixed)
		
		ToolbarItem(placement: .bottomBar) {
			Button("Settings", systemImage: "gear") { vm.showSettings.toggle() }
				.matchedTransitionSource(id: AnimationKeys.settings, in: transition)
		}
		
		ToolbarSpacer(.flexible, placement: .bottomBar)

		ToolbarItem(placement: .bottomBar) {
			Button("Create", systemImage: "plus") { vm.showNewListEditor.toggle() }
				.matchedTransitionSource(id: AnimationKeys.newList, in: transition)
		}
		#endif
    }
}

#Preview {
	@Previewable @State var vm = HomeVm()
	HomeView()
		.environment(vm)
		.onAppear {
			vm.fetchLists()
			vm.addList(.exampleList)
		}
}
