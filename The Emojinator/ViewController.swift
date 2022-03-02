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
            self.emojiCollectionView.reloadData()
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
        self.view.window?.orderOut(nil)
    }
    
    func myKeyDown(with event: NSEvent) -> Bool {
        // handle keyDown only if current window has focus, i.e. is keyWindow
        guard let locWindow = self.view.window,
           NSApplication.shared.keyWindow === locWindow else { return false }
        switch Int( event.keyCode) {
        case kVK_DownArrow:
            print(emojiCollectionView.selectionIndexPaths)
            let indexPath = IndexPath(item: 0, section: 0)
            self.emojiCollectionView.selectItems(at: [indexPath], scrollPosition: .top)
            self.highlightItems(true, atIndexPaths: [indexPath])
            print(emojiCollectionView.selectionIndexPaths)
            return true
        case kVK_UpArrow:
            return true
        case kVK_LeftArrow:
            return true
        case kVK_RightArrow:
            return true
        case kVK_Escape:
            resetView()
            return true
        case kVK_Return:
            // copy emoji to pasteboard
            resetView()
            return true
        default:
            return false
        }
    }
    
    func highlightItems(_ selected: Bool, atIndexPaths: Set<IndexPath>) {
        for indexPath in atIndexPaths {
            guard let item = self.emojiCollectionView.item(at: indexPath) else { continue }

            item.view.layer!.borderWidth = 3.0
            item.view.layer!.cornerRadius = 6.0
            let color: CGColor = NSColor.blue.cgColor
            item.view.layer!.borderColor = color
        }
    }
}
