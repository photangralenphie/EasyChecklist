//
//  EasyChecklistApp.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 07.10.22.
//

import SwiftUI
import SwiftData

@main
struct EasyChecklistApp: App {
    
    //Keeps CoreData Loaded for all views to use (initialize "DataController")
    //@StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ListListView()
            // injects CoreData into environment
            //.environment(\.managedObjectContext, dataController.container.viewContext)
        }
        .modelContainer(for: CustomList.self)
    }
}
