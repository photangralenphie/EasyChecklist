//
//  List.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 11.02.24.
//

import Foundation
import SwiftData
import AwesomeSwiftyComponents
import SwiftUI

//@MainActor
@Model
class CustomList {
    var name: String = ""
    var id = UUID()
	var color: AvailableColors = AvailableColors.blue
	var icon: String = "checkmark"
	var creationDate: Date = Date.now
	var editDate: Date = Date.now
	var sortBy: EntrySort = EntrySort.alphabetically
    var isCompletedSectionExpanded: Bool = true
    
    @Relationship(deleteRule: .cascade)
    var listEntries: [ListEntry]? = []
    
    init(name: String, color: AvailableColors, icon: String, sortBy: EntrySort = .alphabetically) {
        self.name = name
        self.color = color
		self.icon = icon
        self.sortBy = sortBy
    }
	
	func addNewEntry(contents: String) {
		if contents.isEmpty {
			return
		}
		
		let newEntry = ListEntry(name: contents)
		
		withAnimation {
			newEntry.list = self
			self.editDate = Date.now
		}
	}
	
	func updateList(listName: String, listIcon: String, listColor: AvailableColors) {
		if (self.name != listName || self.color != listColor || self.icon != listIcon) {
			self.name = listName
			self.color = listColor
			self.icon = listIcon
			self.editDate = Date.now
		}
	}
}

enum EntrySort: String, CaseIterable, Identifiable, Codable {
	var id: Self { self }
	
	case alphabetically = "Alphabetically"
    case date = "Date"
	
	var name: LocalizedStringKey {
		switch self {
			case .date:
				return "Date"
			case .alphabetically:
				return "Alphabetically"
		}
	}
	
	var icon: String {
		switch self {
			case .date:
				return "clock"
			case .alphabetically:
				return "abc"
		}
	}
}

enum ListSort: String {
    case alphabetically = "Alphabetically"
    case creationDate = "Creation Date"
    case modified = "Modified"
}

extension CustomList {
	static var exampleList: CustomList {
		let list = CustomList(name: "DevList", color: .orange, icon: "checkmark")
		list.addNewEntry(contents: "Test")
		list.addNewEntry(contents: "Test")
		list.addNewEntry(contents: "Test")
		list.addNewEntry(contents: "Test")
		list.addNewEntry(contents: "Test")
		list.addNewEntry(contents: "Test")
		list.addNewEntry(contents: "Test")
		list.addNewEntry(contents: "Test")
		list.addNewEntry(contents: "Test")
		list.addNewEntry(contents: "Test")
		list.addNewEntry(contents: "Test")
		
		return list
	}
}
