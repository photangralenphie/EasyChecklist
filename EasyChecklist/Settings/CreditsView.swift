//
//  CreditsView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 09.03.24.
//

import SwiftUI
import AwesomeSwiftyComponents

struct CreditsView: View {
    var body: some View {
        List {
            LicenceView(name: "PrintingKit", year: "2023 - 2024", author: "Daniel Saidi", licence: .mit)
            LicenceView(name: "TPPDF", year: "2016 - 2024", author: "Philip Niedertscheider", licence: .mit)
        }
        .navigationTitle("Credits")
    }
}
