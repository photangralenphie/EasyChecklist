//
//  LABiometrics.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 31.05.24.
//

import LocalAuthentication

extension LABiometryType {
    var systemName: String {
        switch self {
        case .touchID:
            "touchid"
        case .faceID:
            "faceid"
        case .opticID:
            "opticid"
        case .none:
            ""
        @unknown default:
            ""
        }
    }
    
    var name: String {
        switch self {
        case .none:
            return ""
        case .touchID:
            return "Touch ID"
        case .faceID:
            return "Face ID"
        case .opticID:
            return "Optic ID"
        @unknown default:
            return ""
        }
    }
}
