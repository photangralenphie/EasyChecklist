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
        return "\(numToDoItems)/\(list.listEntries?.count ?? 0)"
    }
    
    var listExhaustiveDetailSubtitle: LocalizedStringKey {
        return "\(list.listEntries?.count ?? 0) Entry - \(numDoneItems) Done - \(numToDoItems) ToDo"
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
				Image(systemName: availibleIcons[list.image])
					.foregroundStyle(list.color.SwiftUIColor)
			}
			.labelStyle(.centeredImage)
		}
		.swipeActions(edge: .trailing, allowsFullSwipe: false) { ChecklistCellViewContextAndSwipeActions(list: list) }
		.contextMenu { ChecklistCellViewContextAndSwipeActions(list: list) }
		.listRowBackground(
			Capsule(style: .continuous)
				.glassEffect(.clear.interactive())
		)
    }
}
