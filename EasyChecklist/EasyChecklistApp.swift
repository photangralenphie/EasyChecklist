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
    @AppStorage("accentColorSchema") private var accentColorSchema: AvailableColors = .blue
    @AppStorage("colorScheme") private var colorScheme: PreferredColorScheme = .systemDefault
    
    // Sorting
    @AppStorage("sortOrder") private var sortOrder: ListSort = ListSort.modified
    @AppStorage("isAcendingSort") private var isAscendingSort: Bool = false
    
    // Data
    @Query private var lists: [CustomList]
	
	var iCloudContainer: ModelContainer = {
		let schema = Schema([ CustomList.self ])
		let modelConfiguration = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
		
		do {
			return try ModelContainer(for: schema, configurations: [modelConfiguration])
		} catch {
			fatalError("Could not create ModelContainer: \(error.localizedDescription)")
		}
	}()
	
//	private let context: ModelContext? = {
//		guard let container = try? ModelContainer(for: CustomList.self, configurations: ModelConfiguration("bookmarks", cloudKitDatabase: .automatic)) else { return nil }
//		let context = ModelContext(container)
//		return context
//	}()
//    
    init() {
		#if os(iOS)
        UIExtensions.setNavigationBarFont(fontDesign: .rounded)
		#endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(sortOrder: $sortOrder, isAscendingSort: $isAscendingSort)
                .preferredColorScheme(colorScheme.mode)
                .tint(accentColorSchema.SwiftUIColor)
        }
//        .modelContainer(for: CustomList.self, isAutosaveEnabled: true)
		.modelContainer(iCloudContainer)
		
		#if os(macOS)
		Settings {
			SettingsView()
		}
		#endif
    }
}
