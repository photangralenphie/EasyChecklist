//
//  CreditsView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 09.03.24.
//

import SwiftUI
import AwsomeSwiftyComponents

struct CreditsView: View {
    var body: some View {
        List {
            LicenceView(name: "CreditManager", year: 2024, author: "Jonas Helmer", licence: .mit)
            LicenceView(name: "ColorScemeSwitcher", year: 2024, author: "Jonas Helmer", licence: .mit)
            LicenceView(name: "InlineColorPicker", year: 2024, author: "Jonas Helmer", licence: .mit)
            LicenceView(name: "PrintingKit", year: "2023 - 2024", author: "Daniel Saidi", licence: .mit)
            LicenceView(name: "TPPDF", year: "2016 - 2024", author: "Philip Niedertscheider", licence: .mit)
        }
        .navigationTitle("Credits")
    }
}
