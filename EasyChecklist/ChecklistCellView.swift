//
//  ContentView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 07.10.22.
//

import SwiftUI
import SwiftData
import AwsomeSwiftyComponents

struct ChecklistCellView: View {
    
    // Init
    public var list: CustomList
    
    @Environment(\.modelContext) private var context

    @State private var editCustomList: Bool = false
    
    // Settings
    @AppStorage("accentColorID") private var accentColorID: Int = 0
    @AppStorage("showExhaustiveListDetails") private var showExhaustiveListDetails: Bool = true
    
    var listDetailSubtitle: String {
        guard let listEntries = list.listEntries else { return "" }
        return "\(numToDoItems)/\(listEntries.count)"
    }
    
    var listExhaustiveDetailSubtitle: LocalizedStringKey {
        guard let listEntries = list.listEntries else { return "" }
        return "\(listEntries.count) Entry - \(numDoneItems) Done - \(numToDoItems) ToDo"
    }
    
    var numDoneItems: Int {
        guard let listEntries = list.listEntries else { return 0 }
        return listEntries.filter { $0.checked }.count
    }
    
    var numToDoItems: Int {
        guard let listEntries = list.listEntries else { return 0 }
        return listEntries.filter { !$0.checked }.count
    }
    
    var body: some View {
        Section {
            NavigationLink(value: list) {
                Label {
                    VStack(alignment: .leading) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(list.name)
                                .foregroundStyle(Color.primary)
                            Spacer()
                            if !showExhaustiveListDetails {
                                Text(listDetailSubtitle)
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                        if showExhaustiveListDetails {
                            Text(listExhaustiveDetailSubtitle)
                                .font(.footnote)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                } icon: {
                    Image(systemName: availibleIcons[list.image])
                        .foregroundStyle(GetColorByID(list.color))
                }
                .labelStyle(CenteredImageLabelStyle())
                .sheet(isPresented: $editCustomList) {
                    ListDetailEditor(navigationTitle: "Edit List", buttonTitle: "Save Changes", listName: list.name, listIcon: list.image, listColor: list.color, action: editListDetails)
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button("Delete", systemImage: "trash", role: .destructive, action: deleteList)
                    .tint(.red)
                Button("Edit", systemImage: "rectangle.and.pencil.and.ellipsis") { editCustomList.toggle() }
                    .tint(GetColorByID(accentColorID))
            }
            .contextMenu {
                Button("Edit", systemImage: "rectangle.and.pencil.and.ellipsis") { editCustomList.toggle() }
                Button("Delete", systemImage: "trash", role: .destructive, action: deleteList)
            }
        }
    }
    
    func deleteList() {
        withAnimation {
            context.delete(list)
        }
    }
    
    func editListDetails(listName: String, listIcon: Int, listColor: Int) {
        if (list.name != listName || list.color != listColor || list.image != listIcon) {
            list.name = listName
            list.color = listColor
            list.image = listIcon
            list.editDate = Date.now
        }
    }
}
