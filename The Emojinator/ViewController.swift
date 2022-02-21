//
//  ViewController.swift
//  The Emojinator
//
//  Created by Jason Dufair on 2/21/22.
//

import Cocoa
import NukeUI

class ViewController: NSViewController {
    
    @IBOutlet weak var lazyImageView: LazyImageView!
    
    override func loadView() {
        super.loadView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        lazyImageView.source = "https://emoji-server.azurewebsites.net/emoji/boom2"        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

