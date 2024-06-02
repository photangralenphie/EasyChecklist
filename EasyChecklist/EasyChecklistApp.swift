//
//  EasyChecklistApp.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 07.10.22.
//

import SwiftUI
import SwiftData
import AwsomeSwiftyComponents
import LocalAuthentication

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
    
    // Locking
    @State private var isUnlocked: Bool = true
    @AppStorage("useBiometricAuthentication") private var useBiometricAuthentication: Bool = false
    @Environment(\.scenePhase) var scenePhase
    let context = LAContext()
    @State var error: NSError?
    
    var body: some Scene {
        WindowGroup {
            if isUnlocked {
                ContentView(sortOrder: $sortOrder, isAscendingSort: $isAscendingSort)
                    .preferredColorScheme(colorScheme.mode())
                    .tint(GetColorByID(accentColorID))
                    .task { _ = hasBiometrics() }
            } else {
                ContentUnavailableView {
                    Label("Locked", systemImage: "lock")
                } actions: {
                    Button(action: authenticate) {
                        Label("Unlock using \(context.biometryType.name)", systemImage: context.biometryType.systemName)
                    }
                }
            }
        }
        .modelContainer(for: CustomList.self)
        .onChange(of: scenePhase, setLockedStateAfterScenePhaseChange)
    }
    
    func hasBiometrics() -> Bool {
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func authenticate() {
        if !hasBiometrics() {
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "We need to unlock your data.") { success, _ in
            if success {
                isUnlocked = true
            } else {
                isUnlocked = false
            }
        }
    }
    
    func setLockedStateAfterScenePhaseChange(oldValue: ScenePhase, newValue:ScenePhase) {
        isUnlocked = false
        
        if !useBiometricAuthentication {
            isUnlocked = true
            return
        }
        
        switch newValue {
            case .background:
                isUnlocked = false
            case .inactive:
                isUnlocked = false
            case .active:
                if oldValue != .active{
                        authenticate()
                    } else {
                        isUnlocked = true
                    }
            @unknown default: break
        }
    }
}
