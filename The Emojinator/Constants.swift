//
//  Constants.swift
//  The Emojinator
//
//  Created by Jason Dufair on 3/2/22.
//

import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let showPopup = Self("showPopup", default: .init(.return, modifiers: [.command, .shift]))
}
