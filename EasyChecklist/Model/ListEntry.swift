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
    var name: String
    var id: UUID
    var checked: Bool
    
    init(name: String) {
        self.name = name
        self.id = UUID()
        self.checked = false
    }
    
    var list: CustomList?
}
