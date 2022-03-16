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

class ViewController: NSViewController, NSTextFieldDelegate, NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    @IBOutlet weak var emojiFilter: NSTextField!
    @IBOutlet weak var emojiCollectionView: NSCollectionView!
    @IBOutlet weak var emojiLabel: NSTextField!
    @IBOutlet weak var selectedEmojiView: NSImageView!
    
    var emojiList = [String]()
    var filteredEmojiList = [String]()
    var selectedEmoji: String? = nil
    
    override func loadView() {
        super.loadView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Load the emojis from the server
        Api().loadEmojiList { (incomingEmojiList) in
            self.emojiList = incomingEmojiList
            self.filteredEmojiList = incomingEmojiList
            self.emojiCollectionView.reloadData()
        }
        
        // Monitor and react to keystrokes
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

    // MARK: NSCollectionViewDataSource methods
    
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
    
    // MARK: Utility functions
    
    func resetView() {
        self.emojiFilter.stringValue = ""
        self.emojiFilter.becomeFirstResponder()
        self.filteredEmojiList = self.emojiList
        emojiCollectionView.reloadData()
        self.view.window?.orderOut(nil)
    }
    
    func selectEmoji(newIndex: Int) {
        let indexPath = IndexPath(item: newIndex, section: 0)
        let selectionRect = self.emojiCollectionView.frameForItem(at: newIndex)
        self.emojiCollectionView.scrollToVisible(selectionRect)
        self.emojiCollectionView.selectionIndexPaths = [indexPath]
        self.selectedEmoji = self.filteredEmojiList[newIndex]

        self.emojiLabel.stringValue = ":\(self.selectedEmoji!):"
        let url = URL(string: "https://emoji-server.azurewebsites.net/emoji/\(self.selectedEmoji!)")
        selectedEmojiView.kf.indicatorType = .activity
        KF.url(url).set(to: selectedEmojiView)
        selectedEmojiView.animates = true
    }
    
    private func copySelectedEmojiToPasteboard () {
        if (self.selectedEmoji == nil) { return }
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString("<meta charset='utf-8'><img src=\"https://emoji-server.azurewebsites.net/emoji/\(self.selectedEmoji!)\"/>",
                     forType: NSPasteboard.PasteboardType.html)
        let teams = NSRunningApplication.runningApplications(withBundleIdentifier: "com.microsoft.teams")
        if (!teams.isEmpty) {
            teams[0].activate(options: NSApplication.ActivationOptions.activateAllWindows)
        }
    }
    
    public func didPopUp() {
        selectEmoji(newIndex: 0)
    }
    
    // MARK: NSCollectionViewDelegate methods
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        selectEmoji(newIndex: collectionView.selectionIndexes.first!)
        copySelectedEmojiToPasteboard()
        resetView()
    }
    
    // MARK: Keyboard controls
    
    // Fuzzy filter the grid of emojis
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
            filteredEmojiList = Array(filteredEmojiList[0...30])
        }
        emojiCollectionView.reloadData()
        selectEmoji(newIndex: 0)
    }
    
    // Navigation & actions
    func myKeyDown(with event: NSEvent) -> Bool {
        // handle keyDown only if current window has focus, i.e. is keyWindow
        guard let locWindow = self.view.window,
           NSApplication.shared.keyWindow === locWindow else { return false }


        let index = self.emojiCollectionView.selectionIndexes.first
        let horizontalItemCount = self.emojiCollectionView.enclosingScrollView?.verticalScroller?.isHidden == true ? 10 : 9
        switch Int( event.keyCode) {
        case kVK_DownArrow:
            selectEmoji(newIndex: min(index == nil ? 0 : index! + horizontalItemCount, filteredEmojiList.count))
            return true
        case kVK_UpArrow:
            selectEmoji(newIndex: max(index == nil ? 0 : index! - horizontalItemCount, 0))
            return true
        case kVK_LeftArrow:
            selectEmoji(newIndex: max(index == nil ? 0 : index! - 1, 0))
            return true
        case kVK_RightArrow:
            selectEmoji(newIndex: min(index == nil ? 0 : index! + 1, filteredEmojiList.count))
            return true
        case kVK_Escape:
            resetView()
            return true
        case kVK_Return:
            copySelectedEmojiToPasteboard()
            resetView()
            return true
        default:
            return false
        }
    }
}
