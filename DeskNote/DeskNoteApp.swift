//
//  DeskNoteApp.swift
//  DeskNote
//
//  Created by Beak on 2024/6/5.
//

import SwiftUI
import SwiftData
import Tray
import LaunchAtLogin
import NoLaunchWin
import GithubReleaseChecker

@main
struct DeskNoteApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var app: AppDelegate

    var body: some Scene {
        WindowGroup {
            NoLaunchWinView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var tray: Tray!
    
    private let checker = GithubReleaseChecker()
    private let versionCheckItem = NSMenuItem(title: NSLocalizedString("Menu_item_version_check", comment: ""), action: #selector(checkVersion), keyEquivalent: "")
    private var newVersion: ReleaseInfo? = nil
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        tray = Tray.install(named: "TrayIcon") { tray in
            tray.setOnLeftClick(onClick: {
                self.onNewNoteAction()
                return true
            })
        }
        
        let menu = NSMenu()
        
        let newNoteMenuItem = NSMenuItem(title: NSLocalizedString("Menu_item_new_note", comment: ""), action: #selector(onNewNoteAction), keyEquivalent: "")
        
        let launchAtLoginMenuItem = NSMenuItem(title: NSLocalizedString("Menu_item_launch_at_login", comment: ""), action: #selector(onLaunchAtLoginToggle), keyEquivalent: "")
        launchAtLoginMenuItem.state = LaunchAtLogin.isEnabled ? .on : .off
        
        
        versionCheckItem.isHidden = true
        
        let quitMenuItem = NSMenuItem(title: NSLocalizedString("Menu_item_quit", comment: ""), action: #selector(onQuitAction), keyEquivalent: "")
        
        menu.addItem(newNoteMenuItem)
        
        menu.addItem(.separator())
        
        let edgeDockMenuItem = NSMenuItem(title: NSLocalizedString("Menu_item_edge_dock", comment: ""), action: nil, keyEquivalent: "")
        
        edgeDockMenuItem.submenu = SettingsManager.shared.edgeSubMenu
        
        menu.addItem(edgeDockMenuItem)
        menu.addItem(launchAtLoginMenuItem)
        
        menu.addItem(.separator())
        
        menu.addItem(versionCheckItem)
        menu.addItem(quitMenuItem)
        
        tray.setMenu(menu: menu)
        
        showHistoryNotes(notes: NoteManager.shared.fetchAllNotes())
        
        checker.checkUpdate(for: .userRepo("boybeak/DeskNote")) { (res: Result<(newVersion: ReleaseInfo, hasUpdate: Bool), any Error>) in
            switch(res) {
            case .success((let newVersion, let hasUpdate)):
                self.versionCheckItem.isHidden = !hasUpdate
                self.versionCheckItem.title = String(format: NSLocalizedString("Menu_item_version_check", comment: ""), newVersion.tagName)
                if hasUpdate {
                    self.newVersion = newVersion
                }
            case .failure(_):
                self.versionCheckItem.isHidden = true
                self.newVersion = nil
            }
        }
    }
    
    @objc func onNewNoteAction() {
        let noteWin = NoteWindowController { controler in
        }
        
        if let button = self.tray.statusItem?.button {
            if let window = button.window {
                let buttonFrame = button.convert(button.bounds, to: nil)
                let screenFrame = window.convertToScreen(buttonFrame)
                var position = CGPoint(x: screenFrame.origin.x - NoteWindowController.WIDTH / 2 + screenFrame.width / 2, y: screenFrame.origin.y - NoteWindowController.HEIGHT - 8)
                
                let offsetX = Double.random(in: -50...50)
                let offsetY = Double.random(in: -50...0)
                
                position.x += offsetX
                position.y += offsetY
                
                noteWin.show(at: position) { window in
                    newNote(window: window)
                }
            }
        }
    }
    
    private func newNote(window: NSWindow) -> Note {
        return NoteManager.shared.addNote(window: window)
    }
    
    private func showHistoryNotes(notes: [Note]) {
        notes.forEach { note in
            let win = NoteWindowController { controller in}
            win.showNote(note: note)
        }
    }
    
    @objc func onLaunchAtLoginToggle(sender: Any) {
        if let menuItem = sender as? NSMenuItem {
            LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled
            menuItem.state = LaunchAtLogin.isEnabled ? .on : .off
        }
    }
    
    @objc func checkVersion() {
        if let newVersion = self.newVersion, let url = URL(string: newVersion.htmlUrl) {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc func onQuitAction() {
        NSApplication.shared.terminate(nil)
    }
    
}
