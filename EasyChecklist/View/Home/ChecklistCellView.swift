//
//  ContentView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 07.10.22.
//

import SwiftUI
import SwiftData
import AwesomeSwiftyComponents

struct ChecklistCellView: View {
    
    // Init
    public var list: CustomList
    
    // Settings
	@AppStorage(PreferenceKeys.showExhaustiveListDetails) private var showExhaustiveListDetails: Bool = true
    
    var listDetailSubtitle: String {
        return "\(numDoneItems)/\(list.listEntries?.count ?? 0)"
    }
    
    var listExhaustiveDetailSubtitle: LocalizedStringKey {
        return "\(list.listEntries?.count ?? 0) - \(numDoneItems) Done - \(numToDoItems) ToDo"
    }
    
    var numDoneItems: Int {
        guard let listEntries = list.listEntries else { return 0 }
        return listEntries.filter { $0.checked }.count
    }
    
    var numToDoItems: Int {
        guard let listEntries = list.listEntries else { return 0 }
        return listEntries.filter { !$0.checked }.count
    }
    
    var body: some View {
		NavigationLink(value: list) {
			Label {
				VStack(alignment: .leading) {
					HStack(alignment: .firstTextBaseline) {
						Text(list.name)
							.foregroundStyle(Color.primary)
						Spacer()
						if !showExhaustiveListDetails {
							Text(listDetailSubtitle)
								.foregroundStyle(Color.secondary)
						}
					}
					if showExhaustiveListDetails {
						Text(listExhaustiveDetailSubtitle)
							.font(.footnote)
							.foregroundStyle(Color.secondary)
					}
				}
			} icon: {
				Image(systemName: list.icon)
					.foregroundStyle(list.color.SwiftUIColor)
			}
			.labelStyle(.centeredImage)
		}
		.listGlassCell()
		.swipeActions(edge: .trailing, allowsFullSwipe: false) { ChecklistCellViewContextAndSwipeActions(list: list) }
		.contextMenu { ChecklistCellViewContextAndSwipeActions(list: list) }
    }
}

#Preview {
	@Previewable @State var vm = HomeVm()
	HomeView()
		.environment(vm)
		.onAppear {
			vm.addList(.exampleList)
			vm.fetchLists()
		}
}
