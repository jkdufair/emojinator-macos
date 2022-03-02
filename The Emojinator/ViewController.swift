//
//  ViewController.swift
//  The Emojinator
//
//  Created by Jason Dufair on 2/21/22.
//

import Cocoa
import Kingfisher
import Fuse
import Carbon.HIToolbox.Events

class ViewController: NSViewController, NSTextFieldDelegate, NSCollectionViewDataSource {
    
    @IBOutlet weak var emojiFilter: NSTextField!
    @IBOutlet weak var emojiCollectionView: NSCollectionView!
    
    var emojiList = [String]()
    var filteredEmojiList = [String]()
    
    override func loadView() {
        super.loadView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                
        Api().loadEmojiList { (incomingEmojiList) in
            self.emojiList = incomingEmojiList
            self.filteredEmojiList = incomingEmojiList
        }
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            if self.myKeyDown(with: $0) {
                return nil
            } else {
                return $0
            }
        }
    }

    override var representedObject: Any? {
        didSet { }
    }
    
    func controlTextDidChange(_ obj: Notification) {
        let emojiFilterText = emojiFilter.stringValue
        if (emojiFilterText == "") {
            filteredEmojiList = emojiList
        } else {
            let fuse = Fuse(location: 0, distance: 20, threshold: 0.99, maxPatternLength: 32, isCaseSensitive: false, tokenize: false)
            let results = fuse.search(emojiFilterText, in: emojiList)
            filteredEmojiList = results.map { (index, _, matchedRanges) in
                return emojiList[index]
            }
            filteredEmojiList = Array(filteredEmojiList[0...10])
        }
        emojiCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredEmojiList.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "EmojiItem"), for: indexPath)
        let url = URL(string: "https://emoji-server.azurewebsites.net/emoji/\(filteredEmojiList[indexPath[1]])")
        item.imageView?.kf.indicatorType = .activity
        KF.url(url).set(to: item.imageView!)
        item.imageView?.animates = true
        return item
    }
    
    func resetView() {
        self.emojiFilter.stringValue = ""
        self.filteredEmojiList = self.emojiList
        emojiCollectionView.reloadData()
        self.view.window?.close()
    }
    
    func myKeyDown(with event: NSEvent) -> Bool {
        // handle keyDown only if current window has focus, i.e. is keyWindow
        guard let locWindow = self.view.window,
           NSApplication.shared.keyWindow === locWindow else { return false }
        switch Int( event.keyCode) {
        case kVK_DownArrow:
            print("down arrow")
            return true
        case kVK_UpArrow:
            print("up arrow")
            return true
        case kVK_LeftArrow:
            print("left arrow")
            return true
        case kVK_RightArrow:
            print("right arrow")
            return true
        case kVK_Escape:
            resetView()
            return true
        case kVK_Return:
            // copy emoji to pasteboard
            resetView()
            return true
        default:
            print(event.keyCode)
            return false
        }
    }
}
