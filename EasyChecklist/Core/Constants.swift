//
//  Constants.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 23.10.25.
//

import CoreFoundation
import AwesomeSwiftyComponents

struct LayoutConstants {
	public static let listItemSpacing: CGFloat = 10
	
	private init() {}
}

struct AnimationKeys {
	public static let settings = "settings"
	public static let newList = "newList"
	public static let editList = "editList"
	
	private init() {}
}

struct SystemDefaults {
	public static let accentColor = AvailableColors.blue
	public static let defaultIcon: String = "checklist"
	
	private init() {}
}
