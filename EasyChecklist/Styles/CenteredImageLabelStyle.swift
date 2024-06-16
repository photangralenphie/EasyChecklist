//
//  CenteredImageLabelStyle.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 31.05.24.
//

import SwiftUI
import AwesomeSwiftyComponents

struct CenteredImageLabelStyle: LabelStyle {
    
    @AppStorage("accentColorID") private var accentColorID: Int = 0
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center) {
            configuration.icon
                .frame(width: 25)
                .foregroundStyle(GetColorByID(accentColorID))
            configuration.title
                .padding(.leading, 5)
        }
    }
}
