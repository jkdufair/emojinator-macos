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
    var isViewVisible = false
    
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
            let url = URL(string: "https://emoji-server.azurewebsites.net/emoji/\(filteredEmojiList[indexPath[1]])?s=24")
            item.imageView?.kf.indicatorType = .activity
            KF.url(url).set(to: item.imageView!)
        item.imageView?.animates = isViewVisible
            return item
        }
    
    // MARK: Utility functions
    
    func resetView() {
        self.emojiFilter.stringValue = ""
        self.emojiFilter.becomeFirstResponder()
        self.filteredEmojiList = self.emojiList
        self.emojiCollectionView.reloadData()
        for item in emojiCollectionView.visibleItems() {
            item.imageView?.animates = false
        }
        selectedEmojiView.animates = false
        self.isViewVisible = false
        self.view.window?.orderOut(nil)
    }
    
    func selectEmoji(newIndex: Int) {
        let indexPath = IndexPath(item: newIndex, section: 0)
        let selectionRect = self.emojiCollectionView.frameForItem(at: newIndex)
        self.emojiCollectionView.scrollToVisible(selectionRect)
        self.emojiCollectionView.selectionIndexPaths = [indexPath]
        self.selectedEmoji = self.filteredEmojiList[newIndex]

        self.emojiLabel.stringValue = ":\(self.selectedEmoji!):"
        let url = URL(string: "https://emoji-server.azurewebsites.net/emoji/\(self.selectedEmoji!)?s=48")
        selectedEmojiView.kf.indicatorType = .activity
        KF.url(url).set(to: selectedEmojiView)
        selectedEmojiView.animates = true
    }
    
    private func copySelectedEmojiToPasteboard (size: Int) {
        if (self.selectedEmoji == nil) { return }
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString("<meta charset='utf-8'><img src=\"https://emoji-server.azurewebsites.net/emoji/\(self.selectedEmoji!)?s=\(size)\" alt=\":\(self.selectedEmoji!):\" title=\":\(self.selectedEmoji!):\"/>",
                     forType: NSPasteboard.PasteboardType.html)
        let teams = NSRunningApplication.runningApplications(withBundleIdentifier: "com.microsoft.teams")
        if (!teams.isEmpty) {
            teams[0].activate(options: NSApplication.ActivationOptions.activateAllWindows)
        }
    }
    
    public func didPopUp() {
        self.isViewVisible = true
        emojiCollectionView.reloadData()
        // Visible items is empty until *after* this method completes. So this hack works.
        // Probably not the most elegant way to do it
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
        {
            for item in self.emojiCollectionView.visibleItems() {
                item.imageView?.animates = true
            }
            self.selectedEmojiView.animates = true
        }

        selectEmoji(newIndex: 0)
    }
    
    // MARK: NSCollectionViewDelegate methods
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        var size = 24
        if (NSEvent.modifierFlags.contains(.control)) { size = 36 }
        if (NSEvent.modifierFlags.contains(.option)) { size = 48 }
        selectEmoji(newIndex: collectionView.selectionIndexes.first!)
        copySelectedEmojiToPasteboard(size: size)
        resetView()
    }
    
    // MARK: Keyboard controls
    
    // Fuzzy filter the grid of emojis
    func controlTextDidChange(_ obj: Notification) {
        let emojiFilterText = emojiFilter.stringValue
        if (emojiFilterText == "") {
            filteredEmojiList = emojiList
        } else {
            let fuse = Fuse(location: 0, distance: 100, threshold: 0.35, maxPatternLength: 32, isCaseSensitive: false, tokenize: false)
            let results = fuse.search(emojiFilterText, in: emojiList)
            filteredEmojiList = results.map { (index, _, matchedRanges) in
                return emojiList[index]
            }
            let atMostThirty = min(max(filteredEmojiList.count - 1, 0), 30)
            if atMostThirty == 0 {
                filteredEmojiList = [String]()
            } else {
                filteredEmojiList = Array(filteredEmojiList[0...atMostThirty])
            }
        }
        emojiCollectionView.reloadData()
        if !filteredEmojiList.isEmpty {
            selectEmoji(newIndex: 0)
        } else {
            self.selectedEmojiView.image = nil
            self.emojiLabel.stringValue = ""
        }
    }
    
    // Navigation & actions
    func myKeyDown(with event: NSEvent) -> Bool {
        // handle keyDown only if current window has focus, i.e. is keyWindow
        guard let locWindow = self.view.window,
           NSApplication.shared.keyWindow === locWindow else { return false }

        let index = self.emojiCollectionView.selectionIndexes.first
        // Not sure why this changed. What do I look like? A macOS developer?
        let horizontalItemCount = 10 //self.emojiCollectionView.enclosingScrollView?.verticalScroller?.isHidden == true ? 10 : 9
        switch Int(event.keyCode) {
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
            var size = 24
            if (event.modifierFlags.contains(.control)) { size = 36 }
            if (event.modifierFlags.contains(.option)) { size = 48 }
            copySelectedEmojiToPasteboard(size: size)
            resetView()
            return true
        default:
            return false
        }
    }
}
