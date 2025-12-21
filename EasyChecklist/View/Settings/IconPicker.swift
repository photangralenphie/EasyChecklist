//
//  IconPicker.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 11.10.22.
//

import SwiftUI

struct IconPicker: View {
    
	@Binding public var selectedIcon: String
    
	@Namespace private var namespace
	private let iconColumns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 9)
	private let availableIcons = ["checklist", "checkmark", "pencil", "trash", "folder", "tray", "doc", "calendar", "book", "books.vertical", "bookmark", "graduationcap", "ticket", "paperclip", "link", "person", "exclamationmark.triangle", "play", "music.note", "star", "flag", "location", "bell", "bolt", "camera", "phone", "envelope", "cart", "pianokeys", "hammer", "wrench", "screwdriver", "printer", "suitcase", "house", "mappin", "map", "tv", "airplane", "guitars", "leaf", "film", "lightbulb", "list.bullet", "questionmark", "exclamationmark", "exclamationmark.2", "exclamationmark.3", "chevron.left.forwardslash.chevron.right", "curlybraces", "slider.horizontal.3", "dollarsign.circle", "eurosign.square", "sterlingsign.square"]
    
    var body: some View {
		NavigationStack {
			ZStack {
				Color.clear
					.glassEffect(.clear.tint(.accentColor), in: .circle)
					.matchedGeometryEffect(id: selectedIcon, in: namespace, isSource: false)
				
				LazyVGrid(columns: iconColumns) {
					ForEach(availableIcons, id: \.self) { iconName in
						Image(systemName: iconName)
							.frame(width: 40, height: 40)
							.background() {
								Color.clear
									.matchedGeometryEffect(id: iconName, in: namespace, isSource: true)
							}
							.onTapGesture {
								withAnimation(.spring(duration: 0.25, bounce: 0.4)) {
									selectedIcon = iconName
								}
							}
					}
				}
				.sensoryFeedback(.selection, trigger: selectedIcon)
			}
		}
    }
}

#Preview {
	@Previewable @State var selectedIcon: String = SystemDefaults.defaultIcon
	NavigationStack {
		Form {
			IconPicker(selectedIcon: $selectedIcon)
		}
		.formStyle(.grouped)
	}
}
