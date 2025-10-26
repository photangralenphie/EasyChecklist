//
//  ChecklistCellViewContextAndSwipeActions.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 16.06.24.
//

import SwiftUI
import AwesomeSwiftyComponents

struct ChecklistCellViewContextAndSwipeActions: View {
    
    // Init
    public var list: CustomList
    
    // Functional
    @Environment(\.modelContext) private var context
    @State private var editCustomList: Bool = false
    
    var body: some View {
        Button("Delete", systemImage: "trash", role: .destructive, action: deleteList)
            .tint(.red)
        Button("Edit", systemImage: "rectangle.and.pencil.and.ellipsis") { editCustomList.toggle() }
            .tint(list.color.SwiftUIColor)
            .sheet(isPresented: $editCustomList) {
                ListDetailEditor(navigationTitle: "Edit List", buttonTitle: "Save Changes", listName: list.name, listIcon: list.icon, listColor: list.color, action: editListDetails)
            }
    }
    
    func deleteList() {
        withAnimation {
            context.delete(list)
        }
    }
    
    func editListDetails(listName: String, listIcon: String, listColor: AvailableColors) {
        if (list.name != listName || list.color != listColor || list.icon != listIcon) {
            list.name = listName
            list.color = listColor
            list.icon = listIcon
            list.editDate = Date.now
        }
    }
}
