//
//  AppDelegate.swift
//  OpenNasURL
//
//  Created by JungMin Ahn on 2015. 12. 4..
//  Copyright © 2015년 SmartStudy. All rights reserved.
//

import Cocoa

let deleteCount = 5

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    let submenu = NSMenu(title: "최근 URL")

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        initMenuItem()
    }

    func applicationWillTerminate(notification: NSNotification) {
        submenu.itemArray.reduce([]) { $0.0 + [$0.1.title] }.saveURLList()
    }
}

extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(menu: NSMenu) {
        guard let urlStr = NSPasteboard.generalPasteboard().stringForType(NSStringPboardType) else { return }
        statusItem.menu?.itemAtIndex(0)?.title = "열기 : " + urlStr
    }
    func menuDidClose(menu: NSMenu) {
        statusItem.menu?.itemAtIndex(0)?.title = "URL 인코딩"
    }
}
// MARK: - Handler
extension AppDelegate {
    func openURL(sender: NSMenuItem) {
        let pasteboard = NSPasteboard.generalPasteboard()
        guard let urlStr = pasteboard.stringForType(NSStringPboardType) else { return }
        let encodingURL = urlStr.encodedURL
        pasteboard.clearContents()
        pasteboard.writeObjects([encodingURL])
        openFinder(encodingURL)
        insertMenuItem(encodingURL)
    }

    func openRecentlyURL(sender: NSMenuItem) {
        openFinder(sender.title.encodedURL)
    }
    func deleteURL(sender: NSMenuItem) {
        (0..<5).forEach { _ in
            guard let removeItem = submenu.itemArray.last else { return }
            submenu.removeItem(removeItem)
        }
    }
}

// MARK: - MenuItem
extension AppDelegate {
    func initMenuItem() {
        statusItem.button?.image = NSImage(named: "StatusBarButtonImage")

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "열기", action: Selector("openURL:"), keyEquivalent: "s"))
        menu.addItem(NSMenuItem(title: "최근 URL", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "마지막 주소 " + String(deleteCount) + "개 지우기", action: Selector("deleteURL:"), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "종료", action: Selector("terminate:"), keyEquivalent: "q"))
        menu.itemAtIndex(1)?.submenu = submenu
        menu.delegate = self
        statusItem.menu = menu
        loadURLList().forEach { submenu.addItem(NSMenuItem(title: $0, action: Selector("openRecentlyURL:"), keyEquivalent: "")) }
    }

    func insertMenuItem(url: String) {
        if let menuItem = submenu.itemWithTitle(url) {
            statusItem.menu?.removeItem(menuItem)
        }
        submenu.insertItem(NSMenuItem(title: url, action: Selector("openRecentlyURL:"), keyEquivalent: ""), atIndex: 0);
        if submenu.itemArray.count > 50 { submenu.removeItemAtIndex(submenu.itemArray.count-1) }
    }
}
