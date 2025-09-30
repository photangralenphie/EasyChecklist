//
//  CenteredImageLabelStyle.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 31.05.24.
//

import SwiftUI
import AwesomeSwiftyComponents

struct CenteredImageLabelStyle: LabelStyle {
    
	@AppStorage(PreferenceKeys.accentColorSchema) private var accentColorSchema: AvailableColors = .blue
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center) {
            configuration.icon
                .frame(width: 25)
                .foregroundStyle(accentColorSchema.SwiftUIColor)
            configuration.title
                .padding(.leading, 5)
        }
    }
}
