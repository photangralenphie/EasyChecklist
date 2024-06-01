//
//  CenteredImageLabelStyle.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 31.05.24.
//

import SwiftUI

struct CenteredImageLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center) {
            configuration.icon
                .frame(width: 25)
            configuration.title
                .padding(.leading, 5)
        }
    }
}
