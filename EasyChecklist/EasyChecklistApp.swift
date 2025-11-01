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
	@AppStorage(PreferenceKeys.accentColorSchema) private var accentColorSchema: AvailableColors = .blue
	@AppStorage(PreferenceKeys.colorScheme) private var colorScheme: PreferredColorScheme = .systemDefault
    
	// ViewModels
	@State private var vm = HomeVm()
	@State private var backgroundGradientVm = BackgroundGradientVm()
	  
//    init() {
//		#if os(iOS)
//        UIExtensions.setNavigationBarFont(fontDesign: .rounded)
//		#endif
//    }
    
    var body: some Scene {
        WindowGroup {
			HomeView()
                .preferredColorScheme(colorScheme.mode)
				.tint(vm.selectedList?.color.SwiftUIColor ?? accentColorSchema.SwiftUIColor)
				.environment(vm)
				.onAppear {
					vm.fetchLists()
					vm.backgroundVm.setBackgroundColor(baseColor: accentColorSchema)
				}
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
