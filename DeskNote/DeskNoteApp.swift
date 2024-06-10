//
//  DeskNoteApp.swift
//  DeskNote
//
//  Created by Beak on 2024/6/5.
//

import SwiftUI
import SwiftData
import Tray

@main
struct DeskNoteApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var app: AppDelegate

    var body: some Scene {
        Settings {}.modelContainer(sharedModelContainer)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var windows = [NoteWindowController]()
    
    private var tray: Tray!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        tray = Tray.install(systemSymbolName: "newspaper.fill") { tray in
//            tray.setView(content: NoteView())
            tray.setOnLeftClick(onClick: {
                self.onNewNoteAction()
                return true
            })
        }
        
        let menu = NSMenu()
        let newNoteMenuItem = NSMenuItem(title: "New Note", action: #selector(onNewNoteAction), keyEquivalent: "")
        
        let testMenuItem = NSMenuItem(title: "Test", action: #selector(onTestAction), keyEquivalent: "")
        
        let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(onQuitAction), keyEquivalent: "")
        menu.addItem(newNoteMenuItem)
        menu.addItem(testMenuItem)
        menu.addItem(quitMenuItem)
        tray.setMenu(menu: menu)
    }
    
    @objc func onNewNoteAction() {
        let noteWin = NoteWindowController { controler in
            self.windows.removeAll { $0 == controler }
        }
        
        if windows.isEmpty {
            if let button = self.tray.statusItem?.button {
                if let window = button.window {
                    let buttonFrame = button.convert(button.bounds, to: nil)
                    let screenFrame = window.convertToScreen(buttonFrame)
                    noteWin.show(at: CGPoint(x: screenFrame.origin.x - NoteWindowController.WIDTH / 2 + screenFrame.width / 2, y: screenFrame.origin.y - NoteWindowController.HEIGHT - 8))
                }
            }
        } else {
            noteWin.showAccordingTo(window: windows.last!.window!)
        }
        windows.append(noteWin)
    }
    
    @objc func onTestAction() {
    }
    
    @objc func onQuitAction() {
        
    }
    
}
