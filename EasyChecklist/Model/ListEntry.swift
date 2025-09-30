//
//  ListEntry.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 11.02.24.
//

import Foundation
import SwiftData

@Model
class ListEntry {
    var name: String = ""
    var id: UUID = UUID()
    var checked: Bool  = false
    var dateAdded = Date.now
    
    init(name: String) {
        self.name = name
    }
    
	@Relationship(inverse: \CustomList.listEntries)
    var list: CustomList?
}
