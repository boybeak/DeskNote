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
    @NSApplicationDelegateAdaptor(AppDelegate.self) var app: AppDelegate

    var body: some Scene {
        Settings {}
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
        
        showHistoryNotes(notes: NoteManager.shared.fetchAllNotes())
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
                    let position = CGPoint(x: screenFrame.origin.x - NoteWindowController.WIDTH / 2 + screenFrame.width / 2, y: screenFrame.origin.y - NoteWindowController.HEIGHT - 8)
                    noteWin.show(at: position) { point in
                        newNote(position: point)
                    }
                }
            }
        } else {
            _ = noteWin.showAccordingTo(window: windows.last!.window!) { point in
                newNote(position: point)
            }
        }
        windows.append(noteWin)
    }
    
    private func newNote(position: CGPoint) -> Note {
        return NoteManager.shared.addNote(position: position)
    }
    
    private func showHistoryNotes(notes: [Note]) {
        notes.forEach { note in
            let win = NoteWindowController { controller in
                NoteManager.shared.deleteNote(note: note)
            }
            win.show(at: note.position?.toPoint()) { point in
                return note
            }
        }
    }
    
    @objc func onTestAction() {
    }
    
    @objc func onQuitAction() {
        
    }
    
}
