//
//  EasyChecklistApp.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 07.10.22.
//

import SwiftUI
import SwiftData
import InlineColorPicker
import ColorSchemeSwitcher

@main
struct EasyChecklistApp: App {
    
    @AppStorage("accentColorID") private var accentColorID: Int = 0
    @AppStorage("colorScheme") private var colorScheme: PreferredColorScheme = .systemDefault
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(GetColorByID(accentColorID))
                .preferredColorScheme(colorScheme.mode())
        }
        .modelContainer(for: CustomList.self)
    }
}
