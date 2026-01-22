//
//  PrintEmptyChecklistConfigurationView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 27.10.25.
//

import SwiftUI
import PrintingKit

struct PrintEmptyChecklistConfigurationView: View {
	
	@Environment(HomeVm.self) private var vm
	
	@State private var emptyPrintListName: String = ""
	@State private var emptyPrintListNumEntries: Int?
	
    var body: some View {
		TextField("Name", text: $emptyPrintListName)
		TextField("Number Empty Items", value: $emptyPrintListNumEntries, format: .number)
			.keyboardType(.numberPad)
		Button(role: .cancel, action: resetEmptyPrintList)
		Button("Print", action: printEmptyList)
			.disabled(emptyPrintListNumEntries == nil || emptyPrintListName == "")
    }
	
	#if os(iOS)
	func printEmptyList() {
		guard let num = emptyPrintListNumEntries else { return }
		let pdf = PdfMaker(name: emptyPrintListName, numEmptyItems: num).makePDF()
		try? Printer.shared.printPdfData(pdf)
		resetEmptyPrintList()
	}
	#endif
	
	func resetEmptyPrintList() {
		emptyPrintListName = ""
		emptyPrintListNumEntries = nil
		vm.showEmptyPrintOptions.toggle()
	}
}


#Preview {
	@Previewable @State var vm = HomeVm()
	PrintEmptyChecklistConfigurationView()
		.environment(vm)
		.onAppear {
			vm.addList(.exampleList)
			vm.fetchLists()
		}
}
