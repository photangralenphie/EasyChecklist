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
	@Environment(HomeVm.self) private var homeVm
    
    // Functional
    @State private var editCustomList: Bool = false
    
    var body: some View {
        Button(role: .destructive, action: deleteList)
            .tint(.red)
		
        Button("Edit", systemImage: "rectangle.and.pencil.and.ellipsis") { editCustomList.toggle() }
			.tint(Color.accentColor)
            .sheet(isPresented: $editCustomList) {
				ListDetailEditor(list: list)
            }
    }
    
    func deleteList() {
		homeVm.deleteList(list)
    }
}
