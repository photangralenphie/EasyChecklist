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
    var id: UUID
    var color: Int
    var image: Int
    var creationDate: Date
    var editDate: Date
    
    @Relationship(deleteRule: .cascade)
    var listEntries: [ListEntry]?
    
    init(name: String, color: Int, image: Int) {
        self.name = name
        self.id = UUID()
        self.color = color
        self.image = image
        self.creationDate = Date.now
        self.editDate = Date.now
    }
}
