//
//  IconPicker.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 11.10.22.
//

import SwiftUI

struct IconPicker: View {
    
    @Binding public var newIcon: Int
    
    private let iconCollums: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: iconCollums) {
            ForEach(0..<availibleIcons.count, id: \.self) { iconIndex in
                Image(systemName: availibleIcons[iconIndex])
                    .foregroundColor(newIcon==iconIndex ? Color.accentColor : Color.primary)
                    .padding(.vertical, 8)
                    .onTapGesture { newIcon = iconIndex }
            }
        }
        .sensoryFeedback(.selection, trigger: newIcon)
    }
}

public let availibleIcons = ["checklist", "checkmark", "pencil", "trash", "folder", "tray", "doc", "calendar", "book", "books.vertical", "bookmark", "graduationcap", "ticket", "paperclip", "link", "person", "exclamationmark.triangle", "play", "music.note", "star", "flag", "location", "bell", "bolt", "camera", "phone", "envelope", "cart", "pianokeys", "hammer", "wrench", "screwdriver", "printer", "suitcase", "house", "mappin", "map", "tv", "airplane", "guitars", "leaf", "film", "lightbulb", "list.bullet", "questionmark", "exclamationmark", "exclamationmark.2", "exclamationmark.3", "chevron.left.forwardslash.chevron.right", "curlybraces", "slider.horizontal.3", "dollarsign.circle", "eurosign.square", "sterlingsign.square"]
