//
//  ListEntryView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 11.02.24.
//

import SwiftUI

struct ListEntryView: View {
    
    let listEntry: ListEntry
    // Data
    @Environment(\.modelContext) private var context
    @State private var showRenameAlert: Bool = false
    
    @AppStorage("strikeCheckedEntries") private var strikeCheckedEntries: Bool = true
    
    var body: some View {
        Label {
            Text(listEntry.name)
                .strikethrough(listEntry.checked && strikeCheckedEntries)
        } icon: {
            Image(systemName: listEntry.checked ? "checkmark.circle" : "circle")
        }
        .contentShape(Rectangle())
        .sensoryFeedback(.success, trigger: listEntry.checked)
        .onTapGesture {
            withAnimation {
                listEntry.checked.toggle()
            }
            listEntry.list?.editDate = Date.now
        }
        .onLongPressGesture { showRenameAlert.toggle() }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                withAnimation {
                    context.delete(listEntry)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(Color.red)
            Button {
                showRenameAlert.toggle()
            } label: {
                Label("Rename", systemImage: "rectangle.and.pencil.and.ellipsis")
            }
        }
        .onChange(of: listEntry.name) { listEntry.list?.editDate = Date.now }
        .alert("Rename", isPresented: $showRenameAlert) {
            TextField("Entry", text: Bindable(listEntry).name)
        }
    }
}
