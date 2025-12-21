//
//  HomeVm.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 27.10.25.
//

import SwiftUI
import SwiftData
import AwesomeSwiftyComponents

@MainActor
@Observable
class HomeVm {
	
	@ObservationIgnored
	private var dataService = DataService.shared
	
	@ObservationIgnored
	private(set) var allLists: [CustomList] = []
	
	@ObservationIgnored
	private(set) var backgroundVm = BackgroundGradientVm()
	
	var selectedList: CustomList?
	var searchString: String = ""
	var showSettings: Bool = false
	var showNewListEditor: Bool = false
	
	var showEmptyPrintOptions: Bool = false
	
	var sortOrder: ListSort = HomeVm.getSavedSortOrder() {
		didSet { UserDefaults().set(sortOrder.rawValue, forKey: PreferenceKeys.sortOrder) }
	}
	
	var isAscendingSort: Bool = UserDefaults().bool(forKey: PreferenceKeys.isAscendingSort) {
		didSet { UserDefaults().set(isAscendingSort, forKey: PreferenceKeys.isAscendingSort) }
	}
	
	var lists: [CustomList] {
		var ret = allLists;
		switch sortOrder {
			case .alphabetically:
				ret.sort(by: { $0.name > $1.name })
			case .creationDate:
				ret.sort(by: { $0.creationDate < $1.creationDate })
			case .modified:
				ret.sort(by: { $0.editDate < $1.editDate })
		}
		
		if isAscendingSort {
			ret.reverse()
		}
		
		if !searchString.isEmpty {
			ret = ret.filter { $0.name.localizedCaseInsensitiveContains(searchString) }
		}
		
		return ret
	}
	
	func fetchLists() {
		self.allLists = dataService.fetchLists()
	}
	
	
	func createNewList(listName: String, listIcon: String, listColor: AvailableColors) {
		let newList = CustomList(name: listName, color: listColor, icon: listIcon)
		addList(newList)
		selectedList = newList
	}

	func addList(_ list: CustomList) {
		dataService.insertNewList(newList: list)
		withAnimation {
			allLists.append(list)
		}
	}
	
	func deleteList(_ list: CustomList) {
		if let selectedList, selectedList == list {
			self.selectedList = nil
		}
		
		dataService.deleteList(list)
		withAnimation {
			allLists.removeAll(where: { $0.id == list.id })
		}
	}
	
	private static func getSavedSortOrder() -> ListSort {
		let raw = UserDefaults().string(forKey: PreferenceKeys.sortOrder)
		var sort = ListSort.modified
		if let raw {
			sort = ListSort(rawValue: raw) ?? .modified
		}
		return sort
	}
}

@MainActor
class DataService {
	
	@MainActor public static var shared = DataService()
	
	private var modelContainer: ModelContainer = {
		let schema = Schema([ CustomList.self ])
		let modelConfiguration = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
		
		do {
			return try ModelContainer(for: schema, configurations: [modelConfiguration])
		} catch {
			fatalError("Could not create ModelContainer: \(error.localizedDescription)")
		}
	}()
	
	func fetchLists() -> [CustomList] {
		let fetchDescriptor: FetchDescriptor<CustomList> = FetchDescriptor()
		do {
			return try modelContainer.mainContext.fetch(fetchDescriptor)
		} catch {
			return []
		}
	}
	
	fileprivate func insertNewList(newList: CustomList) {
		modelContainer.mainContext.insert(newList)
	}
	
	fileprivate func deleteList(_ list: CustomList) {
		modelContainer.mainContext.delete(list)
	}
	
	func deleteListEntry(_ entry: ListEntry) {
		withAnimation {
			modelContainer.mainContext.delete(entry)
		}
	}
	
	private func save() {
		try? modelContainer.mainContext.save()
	}
	
	private init() {}
}
