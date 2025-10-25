//
//  AvailableColors+AdjacentColors.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 24.10.25.
//

import AwesomeSwiftyComponents
import SwiftUI

extension AvailableColors {
	var adjacentColor1: Color {
		switch self {
			case .blue: return .cyan
			case .cyan: return .mint
			case .mint: return .green
			case .green: return .yellow
			case .yellow: return .orange
			case .orange: return .red
			case .red: return .purple
			case .purple: return .indigo
			case .indigo: return .blue
			case .primary: return .secondary
		}
	}
	
	var adjacentColor2: Color {
		switch self {
			case .blue: return .indigo
			case .cyan: return .blue
			case .mint: return .cyan
			case .green: return .mint
			case .yellow: return .green
			case .orange: return .red
			case .red: return .orange
			case .purple: return .red
			case .indigo: return .purple
			case .primary: return .secondary
		}
	}
}
