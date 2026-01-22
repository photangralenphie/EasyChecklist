//
//  ListVm.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 01.11.25.
//

import SwiftUI
import TPPDF
import PrintingKit

@MainActor
@Observable
class ListVm {
	@ObservationIgnored
	let list: CustomList
	
	@ObservationIgnored
	var document: PDFDocument?
	var newEntryName: String = ""
	
	var isSearching: Bool = false
	var searchString: String = ""
	
	var isEditing: Bool = false
	var showBusyIndicator: Bool = false
	var showNoEntriesAlert: Bool = false
	
	var filteredListEntries: [ListEntry] {
		guard let entries = list.listEntries else { return [] }
		let filteredEntries = searchString.isEmpty ? entries : entries.filter{ $0.name.localizedCaseInsensitiveContains(searchString) }
		switch list.sortBy {
			case .date:
				return filteredEntries.sorted { $0.dateAdded > $1.dateAdded }
			case .alphabetically:
				return filteredEntries.sorted { $0.name < $1.name }
		}
	}
	
	var filteredUncheckedItems: [ListEntry] { filteredListEntries.filter { !$0.checked } }
	var filteredCheckedItems: [ListEntry] { filteredListEntries.filter{ $0.checked } }
	
	init(list: CustomList){
		self.list = list
	}
	
	func addNewEntry(duplicateAvoidance: Bool) {
		if duplicateAvoidance, let duplicate = list.listEntries?.filter({ $0.name == newEntryName }).first {
			withAnimation { duplicate.checked = false }
		} else {
			list.addNewEntry(contents: newEntryName)
		}
		
		newEntryName = ""
	}
	
	func editList() {
		isEditing.toggle()
	}
	
	#if os(iOS)
	func printList() {
		guard let entries = list.listEntries else { return  }
		
		if entries.count <= 0 {
			showNoEntriesAlert.toggle()
			return
		}
		
		Task {
			withAnimation {
				showBusyIndicator = true
			}
			
			// I added an overlay for this now I also want to see it.
			try await Task.sleep(for: .milliseconds(750 + Int.random(in: 0...500)))
			
			let pdf = PdfMaker(list: list).makePDF()
			
			try? Printer.shared.printPdfData(pdf)
			showBusyIndicator = false
		}
	}
	#endif
	
	func checkAll() {
		withAnimation {
			list.listEntries?.forEach { $0.checked = true }
		}
	}

	func uncheckAll() {
		withAnimation {
			list.listEntries?.forEach { $0.checked = false }
		}
	}
}
