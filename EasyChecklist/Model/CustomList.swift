//
//  List.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 11.02.24.
//

import Foundation
import SwiftData

@Model
class CustomList {
    var name: String
    var id = UUID()
    var color: Int
    var image: Int
    var creationDate: Date
    var editDate: Date
    var sortBy: EntrySort
    var isCompletedSectionExpanded: Bool
    
    @Relationship(deleteRule: .cascade)
    var listEntries: [ListEntry]?
    
    init(name: String, color: Int, image: Int, sortBy: EntrySort = .alphabetically) {
        self.name = name
        self.color = color
        self.image = image
        self.creationDate = Date.now
        self.editDate = Date.now
        self.sortBy = sortBy
        self.isCompletedSectionExpanded = true
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
