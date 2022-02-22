//
//  ViewController.swift
//  The Emojinator
//
//  Created by Jason Dufair on 2/21/22.
//

import Cocoa
import Kingfisher

class ViewController: NSViewController, NSTextFieldDelegate, NSCollectionViewDataSource {
    
    @IBOutlet weak var emojiFilter: NSTextField!
    @IBOutlet weak var emojiCollectionView: NSCollectionView!
    
    var emojiFilterText: String = ""
    var emojiList = [String]()
    let emojiItem = "EmojiItem"
    
    override func loadView() {
        super.loadView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                
        Api().loadEmojiList { (incomingEmojiList) in
            self.emojiList = incomingEmojiList
//            let emojisPerRow = self.emojiGridView.numberOfColumns
//            let emoji2d: [[String]] = stride(from: 0, through: 200, by: emojisPerRow).map {
//                Array(self.emojiList[$0..<min($0+emojisPerRow, self.emojiList.count)])
//            }
//            for emojiRow in emoji2d {
//                self.emojiGridView.addRow(with: emojiRow.map {
//                    let view = LazyImageView()
//                    view.source = "https://emoji-server.azurewebsites.net/emoji/\($0)"
//                    return view
//                })
//            }
        }
}

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    func controlTextDidChange(_ obj: Notification) {
        emojiFilterText = emojiFilter.stringValue
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiList.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: emojiItem), for: indexPath)
        let url = URL(string: "https://emoji-server.azurewebsites.net/emoji/\(emojiList[indexPath[1]])")
        item.imageView?.kf.indicatorType = .activity
        KF.url(url)
            .set(to: item.imageView!)
        item.imageView?.animates = true
        return item
    }
}
