//
//  ListEntryView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 11.02.24.
//

import SwiftUI

struct ListEntryView: View {
    
    let listEntry: ListEntry
    
    @AppStorage("strikeCheckedEntries") private var strikeCheckedEntries: Bool = true
    
    var body: some View {
        Label {
            Text(listEntry.name)
                .strikethrough(listEntry.checked && strikeCheckedEntries)
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
