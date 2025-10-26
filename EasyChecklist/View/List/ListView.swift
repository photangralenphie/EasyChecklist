//
//  ListView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 11.02.24.
//

import Foundation
import SwiftUI
import AwesomeSwiftyComponents
import TPPDF
import PrintingKit
import UniformTypeIdentifiers

struct ListView: View {
    
    // Init
    @Bindable public var list: CustomList
    
    // Data
    @Environment(\.modelContext) private var context
    @State private var document: PDFDocument?
    
    // Functional
	@State private var newEntryName: String = ""
    @State private var searchString: String = ""
    @State private var isEditing: Bool = false
    @State private var showBusyIndicator: Bool = false
    @State private var showNoEntriesAlert: Bool = false
    
    @Environment(\.horizontalSizeClass) private var sizeClass
	@Environment(\.dismiss) private var dismiss
    
	@Namespace private var transition
	
    // Settings
	@AppStorage(PreferenceKeys.moveToBottom) private var moveToBottom: Bool = true
    
    var filteredListEntries: [ListEntry] {
        guard let entries = list.listEntries else { return [] }
        let filteredEntries = searchString.isEmpty ? entries : entries.filter{ $0.name.localizedCaseInsensitiveContains(searchString) }
        switch list.sortBy {
            case .date:
                return filteredEntries.sorted { $0.dateAdded > $1.dateAdded }
            case .alphabetically:
                return filteredEntries.sorted { $0.name < $1.name }
        }
    }
    
    var filteredUncheckedItems: [ListEntry] { filteredListEntries.filter { !$0.checked } }
    var filteredCheckedItems: [ListEntry] { filteredListEntries.filter{ $0.checked } }
    
    var body: some View {
        List {
			
            if moveToBottom {
                ForEach(filteredUncheckedItems) { listEntry in
                    ListEntryView(listEntry: listEntry)
                }
                if !filteredCheckedItems.isEmpty {
                    Section("Completed (\(filteredCheckedItems.count))", isExpanded: Bindable(list).isCompletedSectionExpanded) {
                        ForEach(filteredCheckedItems) { listEntry in
                            ListEntryView(listEntry: listEntry)
                        }
                    }
                }
            } else {
                ForEach(filteredListEntries) { listEntry in
                    ListEntryView(listEntry: listEntry)
                }
            }
        }
		.scrollContentBackground(.hidden)
		.background(BackgroundGradientView(vm: .init(baseColor: list.color)).id(list.color))
		.scrollDismissesKeyboard(.immediately)
        .tint(list.color.SwiftUIColor)
        .listStyle(.sidebar)
        .toolbarRole(sizeClass == UserInterfaceSizeClass.compact ? .automatic : .editor)
		#if os(iOS)
		.listRowSpacing(LayoutConstants.listItemSpacing)
		.navigationBarTitleDisplayMode(.inline)
		#endif
        .toolbar(id: "listToolbar") {
//            ToolbarItem(id: "search", placement: .primaryAction) {
//                if sizeClass == .compact {
//                    Button("Search", systemImage: "magnifyingglass") { isSearching.toggle() }
//                }
//            }
            
			ToolbarItem(id: "title", placement: .principal) {
				Button {
					editList()
				} label: {
					Label {
						VStack {
							Text(list.name)
								.font(.callout.bold())
							Text(list.creationDate.formatted())
								.font(.system(size: 10))
								.foregroundStyle(.secondary)
						}
					} icon: {
						Image(systemName: list.icon)
					}
				}
				.labelStyle(.centeredImage(tintIcon: false))
				.matchedTransitionSource(id: AnimationKeys.editList, in: transition)
				.buttonStyle(.glass)
				.foregroundStyle(.primary)
			}
			
            ToolbarItem(id: "sort", placement: .secondaryAction) {
                Picker(selection: $list.sortBy.animation()) {
                    Label("Alphabetical", systemImage: "abc")
                        .tag(EntrySort.alphabetically)
                    Label("Newest", systemImage: "clock")
                        .tag(EntrySort.date)
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
            
            ToolbarItem(id: "edit", placement: .secondaryAction) {
                Button("Edit List", systemImage: "square.and.pencil", action: editList)
            }
            
			#if os(iOS)
            ToolbarItem(id: "share", placement: .secondaryAction) {
                ShareLink(item: PdfMaker(list: list), preview: SharePreview(list.name))
            }
			
            ToolbarItem(id: "print", placement: .secondaryAction) {
                Button("Print", systemImage: "printer", action: printList)
            }
			#endif
            
            ToolbarItem(id: "delete", placement: .secondaryAction) {
                Button("Delete List", systemImage: "trash", role: .destructive, action: deleteList)
            }
        }
        .searchable(text: $searchString, prompt: Text("Search \(list.name)"))
        .overlay {
//            if filteredListEntries.isEmpty && isSearching {
//                ContentUnavailableView.search(text: searchString)
//            }
			
//            if let entries = list.listEntries {
//                if entries.isEmpty && !isSearching {
//                    ContentUnavailableView("No Entries", systemImage: "plus")
//                }
//            }
			
            if showBusyIndicator {
                GroupBox {
                    ProgressView()
						.tint(.primary)
                } label: {
                    Label("Generating PDF", systemImage: "doc")
						.foregroundStyle(list.color.SwiftUIColor)
                }
                .padding(0)
                .contentShape(RoundedRectangle(cornerRadius: 10))
                .frame(width: 200)
				.glassEffect(.regular, in: .rect(cornerRadius: 20, style: .continuous))
            }
        }
		#if os(macOS)
		.safeAreaBar(edge: .bottom){
//		.overlay(alignment: .bottom) {
			HStack {
				TextField("Add an Item", text: $newEntryName.animation())
					.padding(.horizontal)
					.onSubmit(addNewEntry)
					.submitLabel(.continue)
					.textFieldStyle(.plain)
					.frame(height: 50)
					.glassEffect()
				
				Image(systemName: "plus")
					.onTapGesture { addNewEntry() }
					.tint(list.color.SwiftUIColor)
					.frame(width: 50, height: 50)
					.clipShape(.circle)
					.glassEffect(newEntryName.isEmpty ? .regular : .clear.tint(list.color.SwiftUIColor))
//					.disabled()
				
//				Button("Add", systemImage: "plus", role: .confirm, action: addNewEntry)
//					.labelStyle(.iconOnly)
//					.tint(list.color.SwiftUIColor)
//					.frame(height: 50)
//					.buttonStyle(.glassProminent)
//					.disabled(newEntryName.isEmpty)
				
			}
//			.glassEffect()
			.padding()
		}
		#else
		.toolbar {
//			if !isSearching {
				ToolbarItemGroup(placement: .bottomBar) {
					TextField("Add an Item", text: $newEntryName.animation())
						.padding(.horizontal)
						.onSubmit(addNewEntry)
						.submitLabel(.continue)
					
					Button("Add", systemImage: "plus", role: .confirm, action: addNewEntry)
						.labelStyle(.iconOnly)
						.tint(list.color.SwiftUIColor)
						.buttonStyle(.glassProminent)
						.disabled(newEntryName.isEmpty)
				}
//			}
		}
		#endif
        .sheet(isPresented: $isEditing) {
			ListDetailEditor(navigationTitle: "Edit List", buttonTitle: "Save Changes", listName: list.name, listIcon: list.icon, listColor: list.color, action: list.updateList)
				.navigationTransition(.zoom(sourceID: AnimationKeys.editList, in: transition))
        }
        .alert("No Entries to print in checklist.", isPresented: $showNoEntriesAlert) {
            Button("OK") { }
        }
    }
	
	func addNewEntry() {
		list.addNewEntry(contents: newEntryName)
		newEntryName = ""
	}
    
    func editList() {
        isEditing.toggle()
    }
    
    func deleteList() {
		dismiss()
        context.delete(list)
    }
    
	#if os(iOS)
    func printList() {
        guard let entries = list.listEntries else { return  }
        
        if entries.count <= 0 {
            showNoEntriesAlert.toggle()
            return
        }
        
        Task {
            withAnimation {
                showBusyIndicator = true
            }
            
            // I added an overlay for this now I also want to see it.
            try await Task.sleep(for: .milliseconds(750 + Int.random(in: 0...500)))
            
            let pdf = PdfMaker(list: list).makePDF()
            
			try? Printer.shared.printPdfData(pdf)
            showBusyIndicator = false
        }
    }
	#endif
}

#Preview {
	NavigationStack {
		ListView(list: CustomList.exampleList)
	}
}
