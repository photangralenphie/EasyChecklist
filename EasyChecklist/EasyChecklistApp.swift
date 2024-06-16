//
//  EasyChecklistApp.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 07.10.22.
//

import SwiftUI
import SwiftData
import AwesomeSwiftyComponents

@main
struct EasyChecklistApp: App {
    
    // Appearance
    @AppStorage("accentColorID") private var accentColorID: Int = 0
    @AppStorage("colorScheme") private var colorScheme: PreferredColorScheme = .systemDefault
    
    // Sorting
    @AppStorage("sortOrder") private var sortOrder: ListSort = ListSort.modified
    @AppStorage("isAcendingSort") private var isAscendingSort: Bool = false
    
    // Data
    @Query private var lists: [CustomList]
    
    var body: some Scene {
        WindowGroup {
            ContentView(sortOrder: $sortOrder, isAscendingSort: $isAscendingSort)
                .preferredColorScheme(colorScheme.mode())
                .tint(GetColorByID(accentColorID))
        }
        .modelContainer(for: CustomList.self)
    }
}
