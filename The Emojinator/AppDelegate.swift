//
//  AppDelegate.swift
//  The Emojinator
//
//  Created by Jason Dufair on 2/21/22.
//

import Cocoa
import KeyboardShortcuts

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow?
    
    var statusItem: NSStatusItem = {
        NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    }()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let windowSize = NSSize(width: 250, height: 350)
        let location = NSEvent.mouseLocation
        let screens = NSScreen.screens
        let screenWithMouse = (screens.first { NSMouseInRect(location, $0.frame, false) })
        let screenSize = screenWithMouse?.frame.size ?? .zero
        let rect = NSMakeRect(screenWithMouse!.frame.minX + screenSize.width/2 - windowSize.width/2, screenWithMouse!.frame.minY + screenSize.height/2 - windowSize.height/2, windowSize.width, windowSize.height)
        window = NSWindow(contentRect: rect, styleMask: [.titled], backing: .buffered, defer: false)
        window?.title = "The Emojinator"

        // Fetch storyboard and gather contentController for our popover
        let storyboard = NSStoryboard(name: "Main", bundle: Bundle.main)
        guard let viewController = storyboard.instantiateController(withIdentifier: "MainViewController") as? NSViewController else {
            print ("Unable to instantiate storyboard view controller")
            return
        }
        
        let btn = self.statusItem.button
        btn?.action = #selector(statusItemClicked(_:))
        btn?.sendAction(on: [.leftMouseDown, .rightMouseDown])
        let appIcon = NSImage(named: "teams-dumpsterfire-3")
        btn?.image = appIcon
        
        window?.contentViewController = viewController
        
        KeyboardShortcuts.onKeyUp(for: .showPopup) {
            let location = NSEvent.mouseLocation
            let screens = NSScreen.screens
            let screenWithMouse = (screens.first { NSMouseInRect(location, $0.frame, false) })
            let screenSize = screenWithMouse?.frame.size ?? .zero
            self.window?.setFrameOrigin(NSPoint(x: screenWithMouse!.frame.minX + screenSize.width/2 - windowSize.width/2, y: screenWithMouse!.frame.minY + screenSize.height/2 - windowSize.height/2))
            NSApp.activate(ignoringOtherApps: true)
            self.window?.orderFrontRegardless()
            self.window?.makeKey()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    @objc func statusItemClicked(_ sender: NSStatusBarButton) {
        if NSApp.currentEvent?.type == .rightMouseDown {
            self.showMenu()
        } else {
            self.window?.makeKeyAndOrderFront(nil)
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

