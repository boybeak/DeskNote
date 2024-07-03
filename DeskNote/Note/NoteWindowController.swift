//
//  NoteWindowController.swift
//  DeskNote
//
//  Created by Beak on 2024/6/7.
//

import AppKit
import SwiftUI
import WinToEdge

class NoteWindowController: NSWindowController {
    
    static let WIDTH: Double = 256, HEIGHT: Double = 256
    
    private var windowCloseCallback: ((_ controller: NoteWindowController) -> Void)? = nil
    
    private var snapEdges: [WinToEdge.Edge] = [WinToEdge.Edge]()
    
    convenience init(windowCloseCallback: @escaping (_ controller: NoteWindowController) -> Void) {
        let screenSize = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
        let window = NoteWindow(
            contentRect: NSRect(
                x: screenSize.width - NoteWindowController.WIDTH,
                y: screenSize.height - NoteWindowController.HEIGHT,
                width: NoteWindowController.WIDTH,
                height: NoteWindowController.HEIGHT
            ),
            styleMask: [],
            backing: .buffered,
            defer: false
        )

        window.backgroundColor = .clear
        window.level = .normal
        
        self.init(window: window)
        
        self.windowCloseCallback = windowCloseCallback
    }
    
    private func bindNoteView(note: Note) {
        let noteView = NoteView(noteVM: NoteVM(note: note), uiCallback: NoteUICallback(
            onMouseIgnore: { ignored in
                self.window?.ignoresMouseEvents = ignored
            },
            onPin: { pinned in
                self.window?.level = pinned ? .floating : .normal
            },
            onClose: {
                self.close()
                NoteManager.shared.deleteNote(note: note)
            },
            onDragStart: {
                self.window?.hasShadow = true
            },
            onDragEnd: {
                self.window?.hasShadow = false
                note.position = (self.window?.frame.origin ?? CGPoint()).toData()
                note.screenName = self.window?.screen?.localizedName
                NoteManager.shared.updateNote()
            },
            onHover: { hovering in
                if hovering {
                    self.window?.escapeFromEdge(edges: self.snapEdges)
                } else {
                    self.snapEdges.removeAll()
                    self.snapEdges.append(contentsOf: SettingsManager.shared.snapEdges)
                    self.window?.snapToEdge(edges: self.snapEdges)
                }
            }
        ))

        let contentView = NSHostingView(rootView: noteView)

        window?.contentView = contentView

    }
    
    func showNote(note: Note) {
        window?.level = note.isPinned ? .floating : .normal
        window?.ignoresMouseEvents = note.isMouseIgnoreEnabled
        
        show(at: note.position?.toPoint()) { point in
            return note
        }
    }
    
    func show(at: CGPoint? = nil, screenName: String? = nil, noteCreator: (_ window: NSWindow) -> Note) {
        if at != nil {
            let screenFrame = NSScreen.screens.first { screen in
                return screen.localizedName == screenName
            }?.frame
            let x = (screenFrame?.minX ?? 0) + at!.x
            let y = (screenFrame?.minY ?? 0) + at!.y
            let frame = CGRect(x: x, y: y, width: NoteWindowController.WIDTH, height: NoteWindowController.HEIGHT)
            window?.setFrame(frame, display: false)
        } else {
            let screenFrame = NSScreen.screens.first { screen in
                return screen.localizedName == screenName
            }?.frame
            let x = min((screenFrame?.midX ?? 0) - NoteWindowController.WIDTH / 2, 0)
            let y = min((screenFrame?.midY ?? 0) - NoteWindowController.HEIGHT / 2, 0)
            let frame = CGRect(x: x, y: y, width: NoteWindowController.WIDTH, height: NoteWindowController.HEIGHT)
            window?.setFrame(frame, display: false)
        }
        let note = noteCreator(window!)
        bindNoteView(note: note)
        showWindow(nil)
    }
    
    func showAccordingTo(window: NSWindow, noteCreator: (_ window: NSWindow) -> Note)-> CGPoint {
        let frame = window.frame
        
        var pendingAt = CGPoint(x: frame.origin.x, y: frame.origin.y - NoteWindowController.HEIGHT)
        
        if pendingAt.y < 0 {
            let screenSize = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
            pendingAt.y = screenSize.height - NoteWindowController.HEIGHT
            pendingAt.x = frame.origin.x - NoteWindowController.WIDTH
        }
        
        show(at: pendingAt, noteCreator: noteCreator)
        
        return pendingAt
    }
    
    override func close() {
        windowCloseCallback?(self)
        windowCloseCallback = nil
        super.close()
    }
    
}
