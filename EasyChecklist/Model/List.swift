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

@Model
class CustomList {
    var name: String = ""
    var id = UUID()
	var color: AvailableColors = AvailableColors.blue
    var image: Int = 0
	var creationDate: Date = Date.now
	var editDate: Date = Date.now
	var sortBy: EntrySort = EntrySort.alphabetically
    var isCompletedSectionExpanded: Bool = true
    
    @Relationship(deleteRule: .cascade)
    var listEntries: [ListEntry]? = []
    
    init(name: String, color: AvailableColors, image: Int, sortBy: EntrySort = .alphabetically) {
        self.name = name
        self.color = color
        self.image = image
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
	
	func updateList(listName: String, listIcon: Int, listColor: AvailableColors) {
		if (self.name != listName || self.color != listColor || self.image != listIcon) {
			self.name = listName
			self.color = listColor
			self.image = listIcon
			self.editDate = Date.now
		}
	}
}

enum EntrySort: String, Codable {
    case date = "Date"
    case alphabetically = "Alphabetically"
}

enum ListSort: String {
    case alphabetically = "Alphabetically"
    case creationDate = "Creation Date"
    case modified = "Modified"
}
