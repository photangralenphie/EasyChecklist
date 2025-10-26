//
//  ListEntryView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 11.02.24.
//

import SwiftUI

struct ListEntryView: View {
    
    // Init
    @Bindable public var listEntry: ListEntry
    
    // Data
    @Environment(\.modelContext) private var context
    @State private var showRenameAlert: Bool = false
    
    // Settings
	@AppStorage(PreferenceKeys.strikeCheckedEntries) private var strikeCheckedEntries: Bool = true
    
    var body: some View {
		Label(listEntry.name, systemImage: listEntry.checked ? "checkmark.circle" : "circle")
			.strikethrough(listEntry.checked && strikeCheckedEntries)
			.contentTransition(.symbolEffect(.replace))
			.contentShape(.rect)
			.listGlassCell()
			.sensoryFeedback(.success, trigger: listEntry.checked)
			.onTapGesture(perform: OnTapGesture)
			.onLongPressGesture { showRenameAlert.toggle() }
			.swipeActions(edge: .trailing) {
				Button("Delete", systemImage: "trash", role: .destructive, action: DeleteListEntry)
					.tint(Color.red)
				Button("Rename", systemImage: "rectangle.and.pencil.and.ellipsis") { showRenameAlert.toggle() }
			}
			.onChange(of: listEntry.name) { listEntry.list?.editDate = Date.now }
			.alert("Rename", isPresented: $showRenameAlert) {
				TextField("Entry", text: $listEntry.name)
			}
    }
    
    func OnTapGesture() {
        withAnimation {
            listEntry.checked.toggle()
            listEntry.list?.editDate = Date.now
        }
    }
    
    func DeleteListEntry() {
        withAnimation {
            context.delete(listEntry)
        }
    }
}

#Preview {
	NavigationStack {
		ListView(list: CustomList.exampleList)
	}
}
