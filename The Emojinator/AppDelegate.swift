//
//  AppDelegate.swift
//  The Emojinator
//
//  Created by Jason Dufair on 2/21/22.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem = {
        NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    }()
    
    var popover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .transient
        return popover
    }()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Fetch storyboard and gather contentController for our popover
        let storyboard = NSStoryboard(name: "Main", bundle: Bundle.main)
        guard let windowController = storyboard.instantiateController(withIdentifier: "MainWindowController") as? NSWindowController else {
            print ("Unable to instantiate storyboard window controller")
            return
        }
        let contentViewController = windowController.contentViewController
        
        let btn = self.statusItem.button
        btn?.action = #selector(statusItemClicked(_:))
        btn?.sendAction(on: [.rightMouseDown])
        
        let appIcon = NSImage(named: "teams-dumpsterfire-3")
        //appIcon!.isTemplate = true
        btn?.image = appIcon
        
        // Assign our storyboard contentViewController to our popover
        self.popover.contentViewController = contentViewController
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    @objc func statusItemClicked(_ sender: NSStatusBarButton) {
        let isRightClickEvent = NSApp.currentEvent?.isRightClick ?? false
        
        if isRightClickEvent {
            self.showMenu()
        } else {
        }
    }
    
    func showMenu() {
        var location = NSEvent.mouseLocation
        let screens = NSScreen.screens
        let screenWithMouse = (screens.first { NSMouseInRect(location, $0.frame, false) })
        location.y = screenWithMouse!.frame.height + screenWithMouse!.frame.minY - NSStatusBar.system.thickness - 10
        
        let contentRect = NSRect(origin: location, size: CGSize(width: 0, height: 0))
        
        let tmpWindow = NSWindow(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)
        tmpWindow.isReleasedWhenClosed = true
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        menu.popUp(positioning: nil, at: .zero, in: tmpWindow.contentView)
    }

}

// MARK: - Extensions

extension NSEvent {
    var isRightClick: Bool {
        self.type == .rightMouseDown
    }
}

