//
//  HomeView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 16.02.24.
//

import SwiftUI
import SwiftData
import AwesomeSwiftyComponents

struct HomeView: View {

	@Environment(HomeVm.self) private var vm
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass

	@Namespace private var transition
	
	@AppStorage(PreferenceKeys.colorScheme) private var colorScheme: PreferredColorScheme = .systemDefault
	@AppStorage(PreferenceKeys.accentColorSchema) private var accentColor: AvailableColors = .blue
    
    var body: some View {
        NavigationSplitView {
			List(vm.lists, selection: Bindable(vm).selectedList) { list in
                ChecklistCellView(list: list)
            }
			.onChange(of: vm.selectedList) {
				vm.backgroundVm.setBackgroundColor(baseColor: vm.selectedList?.color ?? accentColor)
			}
			.scrollContentBackground(.hidden)
			.conditionalBackground(show: horizontalSizeClass == .compact) {
				BackgroundGradientView(vm: vm.backgroundVm)
			}
			#if os(iOS)
			.listRowSpacing(LayoutConstants.listItemSpacing)
			#endif
			.navigationTitle("Checklists")
			.toolbarTitleDisplayMode(.inlineLarge) // large on iPad, inlineLarge on iPhone
            .overlay {
				if vm.searchString.isEmpty && vm.lists.isEmpty {
                    ContentUnavailableView {
                        Label("Add a List", systemImage: "plus")
                    } description: {
                        Text("Get started by adding a list with the button below.")
                    } actions: {
						Button("Add List", systemImage: "plus") { vm.showNewListEditor.toggle() }
                            .buttonStyle(.bordered)
                    }
				} else if vm.lists.isEmpty {
					ContentUnavailableView.search(text: vm.searchString)
                }
            }
            .toolbar { MainToolbar(transition: transition)}
        } detail: {
			if vm.lists.isEmpty {
                ContentUnavailableView("No Checklists", systemImage: "plus", description: Text("Get Started by adding a new Checklist with the plus button"))
					.background(BackgroundGradientView(vm: vm.backgroundVm))
			} else if let list = vm.selectedList {
                ListView()
					.environment(ListVm(list: list))
            } else {
				BackgroundGradientView(vm: vm.backgroundVm)
					.overlay {
						ContentUnavailableView("Nothing Selected", systemImage: "filemenu.and.selection", description: Text("Select a Checklist in the Sidebar"))
					}
            }
        }
		.searchable(text: Bindable(vm).searchString, placement: .sidebar)
		.sheet(isPresented: Bindable(vm).showNewListEditor) {
			ListDetailEditor()
				#if os(iOS)
				.navigationTransition(.zoom(sourceID: AnimationKeys.newList, in: transition))
				#endif
		}
		#if os(iOS)
		.inspector(isPresented: Bindable(vm).showSettings) {
            SettingsView()
				.navigationTransition(.zoom(sourceID: AnimationKeys.settings, in: transition))
				.inspectorColumnWidth(500)
        }
		.alert("Print Empty Checklist", isPresented: Bindable(vm).showEmptyPrintOptions) {
			PrintEmptyChecklistConfigurationView()
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
