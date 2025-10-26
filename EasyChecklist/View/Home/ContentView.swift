//
//  ContentView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 16.02.24.
//

import SwiftUI
import SwiftData
import PrintingKit
import AwesomeSwiftyComponents

struct ContentView: View {
    
    // Init
    @Query private var lists: [CustomList]
    @Binding private var sortOrder: ListSort
    @Binding private var isAscendingSort: Bool
	@Binding private var selectedList: CustomList?
    
    init(sortOrder: Binding<ListSort>, isAscendingSort: Binding<Bool>, selectedList: Binding<CustomList?>) {
        let sortDescriptors: [SortDescriptor<CustomList>] = switch sortOrder.wrappedValue {
        case .alphabetically:
            [SortDescriptor(\CustomList.name, order: isAscendingSort.wrappedValue ? .forward : .reverse)]
        case .creationDate:
            [SortDescriptor(\CustomList.creationDate, order: isAscendingSort.wrappedValue ? .reverse : .forward)]
        case .modified:
            [SortDescriptor(\CustomList.editDate, order: isAscendingSort.wrappedValue ? .reverse : .forward)]
        }
        
        _isAscendingSort = isAscendingSort
        _sortOrder = sortOrder
		_selectedList = selectedList
		
        _lists = Query(sort: sortDescriptors, animation: .snappy)
    }
    
    // Functional
    @Environment(\.modelContext) private var context
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	@AppStorage("selection") private var selection: String?
    @State private var searchString: String = ""
    
    // Sheets
    @State private var showSettings: Bool = false
    @State private var newCustomList: Bool = false
    
    // Empty List printing
    @State private var showEmptyPrintOptions: Bool = false
    @State private var emptyPrintListName: String = ""
    @State private var emptyPrintListNumEntries: Int?
	
	@Namespace private var transition
	@AppStorage(PreferenceKeys.colorScheme) private var colorScheme: PreferredColorScheme = .systemDefault
	@AppStorage(PreferenceKeys.accentColorSchema) private var accentColor: AvailableColors = .blue
    
    var filteredLists: [CustomList] {
        searchString.isEmpty ? lists : lists.filter{ $0.name.localizedCaseInsensitiveContains(searchString) }
    }
    
    var body: some View {
        NavigationSplitView {
			List(filteredLists, selection: $selectedList) { list in
                ChecklistCellView(list: list)
            }
			.scrollContentBackground(.hidden)
			.conditionalBackground(show: horizontalSizeClass == .compact) {
				BackgroundGradientView(vm: .init(baseColor: accentColor))
			}
			#if os(iOS)
			.listRowSpacing(LayoutConstants.listItemSpacing)
			#endif
			.navigationTitle("Checklists")
			.toolbarTitleDisplayMode(.inlineLarge) // large on iPad, inlineLarge on iPhone
            .overlay {
                if searchString.isEmpty && filteredLists.isEmpty {
                    ContentUnavailableView {
                        Label("Add a List", systemImage: "plus")
                    } description: {
                        Text("Get started by adding a list with the button below.")
                    } actions: {
                        Button("Add List", systemImage: "plus") { newCustomList.toggle() }
                            .buttonStyle(.bordered)
                    }
                } else if filteredLists.isEmpty {
                    ContentUnavailableView.search(text: searchString)
                }
            }
            .toolbar {
				#if os(iOS)
				ToolbarItem(placement: horizontalSizeClass == .compact ? .secondaryAction : .bottomBar) {
					Menu("Sort by", systemImage: "arrow.up.arrow.down") {
						Picker(selection: $sortOrder.animation()) {
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
								withAnimation { isAscendingSort = true }
							} label: {
								Label("Ascending", image: isAscendingSort ? "arrow.up.badge.checkmark" : "arrow.up")
							}
							Button {
								withAnimation { isAscendingSort = false }
							} label: {
								Label("Descending", image: isAscendingSort ? "arrow.down" : "arrow.down.badge.checkmark")
							}
						}
					}
				}
				
				ToolbarItem(placement: horizontalSizeClass == .compact ? .secondaryAction : .bottomBar) {
					Button {
						showEmptyPrintOptions.toggle()
					} label: {
						Label("Print Empty Checklist", systemImage: "printer")
					}
				}
				
				ToolbarItem(placement: horizontalSizeClass == .compact ? .secondaryAction : .bottomBar) {
					Button("Settings", systemImage: "gear") { showSettings.toggle() }
						.matchedTransitionSource(id: AnimationKeys.settings, in: transition)
				}

				ToolbarSpacer(.flexible, placement: .bottomBar)
				
				ToolbarItem(placement: .bottomBar) {
                    Button("Create", systemImage: "plus") { newCustomList.toggle() }
						.matchedTransitionSource(id: AnimationKeys.newList, in: transition)
				}
				#endif
            }
        } detail: {
            if lists.isEmpty {
                ContentUnavailableView("No Checklists", systemImage: "plus", description: Text("Get Started by adding a new Checklist with the plus button"))
					.background(BackgroundGradientView(vm: .init(baseColor: accentColor)))
            } else if let list = selectedList {
                ListView(list: list)
            } else {
				BackgroundGradientView(vm: .init(baseColor: accentColor))
					.overlay {
						ContentUnavailableView("Nothing Selected", systemImage: "filemenu.and.selection", description: Text("Select a Checklist in the Sidebar"))
					}
            }
        }
		.searchable(text: $searchString, placement: .sidebar)
		.sheet(isPresented: $newCustomList) {
			ListDetailEditor(navigationTitle: "Add New List", buttonTitle: "Add New List", action: addNewList)
				.navigationTransition(.zoom(sourceID: AnimationKeys.newList, in: transition))
		}
		#if os(iOS)
        .inspector(isPresented: $showSettings) {
            SettingsView()
				.navigationTransition(.zoom(sourceID: AnimationKeys.settings, in: transition))
				.inspectorColumnWidth(500)
        }
		.alert("Print Empty Checklist", isPresented: $showEmptyPrintOptions) {
			TextField("Name", text: $emptyPrintListName)
			TextField("Number Empty Items", value: $emptyPrintListNumEntries, format: .number)
				.keyboardType(.numberPad)
			Button("Cancel", role: .cancel, action: resetEmptyPrintList)
			Button("Print", action: printEmptyList)
				.disabled(emptyPrintListNumEntries == nil || emptyPrintListName == "")
		}
		#endif
    }
    
    func addNewList(listName: String, listIcon: String, listColor: AvailableColors) {
        let newList = CustomList(name: listName, color: listColor, icon: listIcon)
        context.insert(newList)
        selectedList = newList
    }
    
	#if os(iOS)
    func printEmptyList() {
        guard let num = emptyPrintListNumEntries else { return }
		let pdf = PdfMaker(name: emptyPrintListName, numEmptyItems: num).makePDF()
		try? Printer.shared.printPdfData(pdf)
        resetEmptyPrintList()
    }
	#endif
    
    func resetEmptyPrintList() {
        emptyPrintListName = ""
        emptyPrintListNumEntries = nil
        showEmptyPrintOptions.toggle()
    }
}

#Preview {
	@Previewable @State var selection: CustomList?
	
	let container: ModelContainer = {
		let schema = Schema([ CustomList.self ])
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
		return try! ModelContainer(for: schema, configurations: [modelConfiguration])
	}()
	
	ContentView(sortOrder: .constant(.alphabetically), isAscendingSort: .constant(false), selectedList: $selection)
		.modelContainer(container)
		.onAppear { container.mainContext.insert(CustomList.exampleList) }
}
