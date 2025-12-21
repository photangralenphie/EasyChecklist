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
	
	// ViewModel
	@State private var vm = HomeVm()
    
	// Appearance
	@AppStorage(PreferenceKeys.accentColorSchema) private var accentColor: AvailableColors = .blue
	@AppStorage(PreferenceKeys.colorScheme) private var colorScheme: PreferredColorScheme = .systemDefault
	  
    init() {
		#if os(iOS)
        UIExtensions.setNavigationBarFont(fontDesign: .rounded)
		#endif
		
		vm.fetchLists()
		vm.backgroundVm.setBackgroundColor(accentColor, reason: .appear)
    }
    
    var body: some Scene {
        WindowGroup {
			HomeView()
                .preferredColorScheme(colorScheme.mode)
				.environment(vm)
        }

		
		#if os(macOS)
		Settings {
			SettingsView()
		}
		#endif
    }
}

#Preview {
	@Previewable @State var vm = HomeVm()
	HomeView()
		.environment(vm)
		.onAppear {
			vm.fetchLists()
			vm.addList(.exampleList)
		}
}
