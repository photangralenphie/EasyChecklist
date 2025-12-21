//
//  ListDetailEditorVm.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 29.10.25.
//

import SwiftUI
import AwesomeSwiftyComponents

@MainActor
protocol ListDetailEditorVm: Observable {
	var navigationTitle: LocalizedStringKey { get }
	var buttonTitle: LocalizedStringKey { get }
	
	var listName: String { get set }
	var listIcon: String { get set }
	var listColor: AvailableColors { get set }
	
	func save(homeVm: HomeVm)
}

@Observable
class CreateListDetailEditorVm: ListDetailEditorVm {
	@ObservationIgnored
	var navigationTitle: LocalizedStringKey = "New List"
	@ObservationIgnored
	var buttonTitle: LocalizedStringKey = "Create"
	
	var listName: String = ""
	var listIcon: String = SystemDefaults.defaultIcon
	var listColor: AvailableColors = {
		let userColor = UserDefaults.standard.integer(forKey: PreferenceKeys.accentColorSchema)
		return AvailableColors(rawValue: userColor) ?? .blue
	}()

	func save(homeVm: HomeVm) {
		homeVm.createNewList(listName: listName, listIcon: listIcon, listColor: listColor)
	}
}

@Observable
class EditListDetailEditorVm: ListDetailEditorVm {
	@ObservationIgnored
	private var list: CustomList
	
	@ObservationIgnored
	var navigationTitle: LocalizedStringKey = "Edit List"
	@ObservationIgnored
	var buttonTitle: LocalizedStringKey = "Save"
	
	var listName: String
	var listIcon: String
	var listColor: AvailableColors
	
	init(list: CustomList) {
		self.list = list
		
		self.listName = list.name
		self.listIcon = list.icon
		self.listColor = list.color
	}
	
	func save(homeVm: HomeVm) {
		if (list.name != listName || list.color != listColor || list.icon != listIcon) {
			list.name = listName
			list.color = listColor
			list.icon = listIcon
			list.editDate = Date.now
		}
		
		if homeVm.selectedList == list {
			homeVm.backgroundVm.setBackgroundColor(list.color, reason: .selection)
		}
	}
}
