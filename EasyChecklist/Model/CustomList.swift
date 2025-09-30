//
//  List.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 11.02.24.
//

import Foundation
import SwiftData
import AwesomeSwiftyComponents

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
