//
//  ColorPicker.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 11.10.22.
//

import SwiftUI

struct MyColorPicker: View {
    
    @Binding public var newColor: Int
    let componentsData = MyComponentData()
    
    var body: some View {
        HStack {
            ForEach(0..<componentsData.availibleColors.count, id: \.self) { colorIndex in
                Circle()
                    .strokeBorder(colorIndex==newColor ? Color.primary : Color(hex: componentsData.availibleColors[colorIndex]) , lineWidth: 3)
                    .background(Circle().foregroundColor(Color(hex: componentsData.availibleColors[colorIndex])))
                    .padding(.horizontal, -13)
                    .onTapGesture {
                        newColor = colorIndex
                    }
            }
        }
        .padding(.vertical)
    }
}
