//
//  ListEntryView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 11.02.24.
//

import SwiftUI

struct ListEntryView: View {
    
    let listEntry: ListEntry
    
    @AppStorage("strikeDoneEntries") private var strikePrivateEntries: Bool = true
    
    var body: some View {
        Label {
            Text(listEntry.name)
                .strikethrough(listEntry.checked && strikePrivateEntries)
        } icon: {
            Image(systemName: listEntry.checked ? "checkmark.circle" : "circle")
        }
        .onTapGesture {
            withAnimation {
                listEntry.checked.toggle()
            }
            listEntry.list?.editDate = Date.now
        }
    }
}
