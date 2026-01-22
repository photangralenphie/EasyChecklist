//
//  ListView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 11.02.24.
//

import Foundation
import SwiftUI
import AwesomeSwiftyComponents

struct ListView: View {
    
    // Data
	@Environment(HomeVm.self) private var homeVm
	@Environment(ListVm.self) private var vm

    // Functional
	@Namespace private var transition
	@FocusState private var isAddTextFieldFocused: Bool
	@Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    // Settings
	@AppStorage(PreferenceKeys.moveToBottom) private var moveToBottom: Bool = true
    
    var body: some View {
        List {
            if moveToBottom {
				ForEach(vm.filteredUncheckedItems) { listEntry in
                    ListEntryView(listEntry: listEntry)
                }
				if !vm.filteredCheckedItems.isEmpty {
					Section("Completed (\(vm.filteredCheckedItems.count))", isExpanded: Bindable(vm.list).isCompletedSectionExpanded) {
						ForEach(vm.filteredCheckedItems) { listEntry in
                            ListEntryView(listEntry: listEntry)
                        }
                    }
                }
            } else {
				ForEach(vm.filteredListEntries) { listEntry in
                    ListEntryView(listEntry: listEntry)
                }
            }
        }
		.scrollContentBackground(.hidden)
		.background(BackgroundGradientView(vm: homeVm.backgroundVm))
		.scrollDismissesKeyboard(.immediately)
		.tint(vm.list.color.SwiftUIColor)
        .listStyle(.sidebar)
		.toolbarRole(sizeClass == .compact ? .automatic : .editor)
		#if os(iOS)
		.listRowSpacing(LayoutConstants.listItemSpacing)
		.navigationBarTitleDisplayMode(.inline)
		#endif
        .toolbar(id: "listToolbar") {
			ToolbarItem(id: "title", placement: .principal) {
				Button { vm.editList() } label: {
					Label {
						VStack {
							Text(vm.list.name)
								.font(.callout)
								.fontDesign(.rounded)
								.bold()
							Text(vm.list.creationDate.formatted())
								.font(.system(size: 10))
								.foregroundStyle(.secondary)
						}
					} icon: {
						Image(systemName: vm.list.icon)
					}
					.labelStyle(.centeredImage(tintIcon: false))
					.matchedTransitionSource(id: AnimationKeys.editList, in: transition)
				}
				.foregroundStyle(.primary)
				.buttonStyle(.glass)
			}
			
            ToolbarItem(id: "sort", placement: .secondaryAction) {
				Picker(selection: Bindable(vm.list).sortBy.animation()) {
                    Label("Alphabetical", systemImage: "abc")
                        .tag(EntrySort.alphabetically)
                    Label("Newest", systemImage: "clock")
                        .tag(EntrySort.date)
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
            
            ToolbarItem(id: "edit", placement: .secondaryAction) {
				Button("Edit List", systemImage: "square.and.pencil", action: vm.editList)
            }
            
			#if os(iOS)
            ToolbarItem(id: "share", placement: .secondaryAction) {
				ShareLink(item: PdfMaker(list: vm.list), preview: SharePreview(vm.list.name))
            }
			
            ToolbarItem(id: "print", placement: .secondaryAction) {
				Button("Print", systemImage: "printer", action: vm.printList)
            }
			#endif
			
            ToolbarItem(id: "delete", placement: .secondaryAction) {
                Button("Delete List", systemImage: "trash", role: .destructive, action: deleteList)
					.tint(.red)
            }
		}
		.searchable(text: Bindable(vm).searchString, isPresented: Bindable(vm).isSearching, prompt: Text("Search \(vm.list.name)"))
        .overlay {
			if vm.filteredListEntries.isEmpty && vm.isSearching {
				ContentUnavailableView.search(text: vm.searchString)
            }
			
			if let entries = vm.list.listEntries {
				if entries.isEmpty && !vm.isSearching {
					ContentUnavailableView {
						Label("No Entries", systemImage: "plus")
					} actions: {
						Button("Add an Item") { isAddTextFieldFocused = true }
							.buttonStyle(.bordered)
					}
                }
            }
			
			if vm.showBusyIndicator {
                GroupBox {
                    ProgressView()
						.tint(.primary)
                } label: {
                    Label("Generating PDF", systemImage: "doc")
						.foregroundStyle(vm.list.color.SwiftUIColor)
                }
                .padding(0)
                .contentShape(RoundedRectangle(cornerRadius: 10))
                .frame(width: 200)
				.glassEffect(.regular, in: .rect(cornerRadius: 20, style: .continuous))
            }
        }
		#if os(macOS)
		.safeAreaBar(edge: .bottom){
			HStack {
				TextField("Add an Item", text: $newEntryName.animation())
					.padding(.horizontal)
					.onSubmit { vm.addNewEntry(duplicateAvoidance: duplicateAvoidance) }
					.submitLabel(.continue)
					.textFieldStyle(.plain)
					.frame(height: 50)
					.glassEffect()
				
				Image(systemName: "plus")
					.onTapGesture { addNewEntry(duplicateAvoidance: duplicateAvoidance) }
					.tint(list.color.SwiftUIColor)
					.frame(width: 50, height: 50)
					.clipShape(.circle)
					.glassEffect(newEntryName.isEmpty ? .regular : .clear.tint(list.color.SwiftUIColor))
			}
			.padding()
		}
		#else
		.toolbar {
			if !vm.isSearching {
				ToolbarItemGroup(placement: .bottomBar) {
					TextField("Add an Item", text: Bindable(vm).newEntryName.animation())
						.focused($isAddTextFieldFocused)
						.padding(.horizontal)
						.onSubmit { vm.addNewEntry(duplicateAvoidance: duplicateAvoidance) }
						.submitLabel(.continue)
					
					Button("Add", systemImage: "plus", role: .confirm) { vm.addNewEntry(duplicateAvoidance: duplicateAvoidance) }
						.labelStyle(.iconOnly)
						.tint(vm.list.color.SwiftUIColor)
						.buttonStyle(.glassProminent)
						.disabled(vm.newEntryName.isEmpty)
				}
			}
		}
		#endif
		.sheet(isPresented: Bindable(vm).isEditing) {
			ListDetailEditor(list: vm.list)
				#if os(iOS)
				.navigationTransition(.zoom(sourceID: AnimationKeys.editList, in: transition))
				#endif
        }
		.alert("No Entries to print in checklist.", isPresented: Bindable(vm).showNoEntriesAlert) {
            Button("OK") { }
        }
    }
	
	func deleteList() {
		dismiss()
		homeVm.deleteList(vm.list)
	}
}

#Preview {
	@Previewable @State var vm = HomeVm()
	NavigationStack {
		ListView()
			.onAppear {
				vm.backgroundVm.setBackgroundColor(CustomList.exampleList.color, reason: .preview)
			}
			.environment(vm)
			.environment(ListVm(list: CustomList.exampleList))
	}
}
