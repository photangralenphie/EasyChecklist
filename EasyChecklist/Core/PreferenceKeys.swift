//
//  PreferenceKeys.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 29.09.25.
//

@MainActor
struct PreferenceKeys {
	// Settings
	public static var accentColorSchema: String = "accentColorSchema"
	public static var colorScheme: String = "colorScheme"
	public static var showExhaustiveListDetails: String = "showExhaustiveListDetails"
	public static var strikeCheckedEntries: String = "strikeCheckedEntries"
	public static var moveToBottom: String = "moveToBottom"
	
	// Other
	public static var sortOrder: String = "sortOrder"
	public static var isAscendingSort: String = "isAscendingSort"
	
	private init() { }
}
