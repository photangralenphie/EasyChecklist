//
//  IconPicker.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 11.10.22.
//

import SwiftUI

struct MyIconPicker: View {
    
    @Binding public var newIcon: Int
    @Binding public var newColor: Int
    let componentsData = MyComponentData()
    
    // Icon Selection
    @State private var selectedIcon: Int = 0
    
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
            ForEach(0..<componentsData.availibleIcons.count, id: \.self) { iconIndex in
                Image(systemName: componentsData.availibleIcons[iconIndex])
                    .foregroundColor(newIcon==iconIndex ? Color(hex: componentsData.availibleColors[newColor]) : Color.primary)
                    .padding(.vertical, 8)
                    .onTapGesture {
                        newIcon = iconIndex
                    }
            }
        }
    }
}
