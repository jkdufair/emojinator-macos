//
//  ViewController.swift
//  The Emojinator
//
//  Created by Jason Dufair on 2/21/22.
//

import Cocoa
import Kingfisher
import Fuse

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
}
