//
//  EmojiItem.swift
//  The Emojinator
//
//  Created by Jason Dufair on 2/22/22.
//

import Cocoa

class EmojiItem: NSCollectionViewItem {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override var isSelected: Bool {
        didSet {
            self.view.wantsLayer = true
            self.view.layer?.backgroundColor = (isSelected ? NSColor.controlAccentColor.cgColor : NSColor.clear.cgColor)
            self.view.setNeedsDisplay(self.view.bounds)
        }
    }
}
