//
//  NoteWindowController.swift
//  DeskNote
//
//  Created by Beak on 2024/6/7.
//

import AppKit
import SwiftUI

class NoteWindowController: NSWindowController {
    
    static let WIDTH: Double = 256, HEIGHT: Double = 256
    
    private var windowCloseCallback: ((_ controller: NoteWindowController) -> Void)? = nil
    
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

        window.title = "New Note"
        window.backgroundColor = .clear
        window.level = .normal
        
        self.init(window: window)
        
        let noteView = NoteView(callback: NoteUICallback(
            onMouseIgnore: { ignored in
                self.window?.ignoresMouseEvents = ignored
            },
            onPin: { pinned in
                self.window?.level = pinned ? .floating : .normal
            },
            onClose: {
                self.close()
            },
            onDragMove: { move in
                let origin = self.window?.frame.origin
                self.window?.setFrameOrigin(NSPoint(x: origin!.x + move.width, y: origin!.y - move.height))
            },
            onDragEnd: {
                
            }
        ))
        let contentView = NSHostingView(rootView: noteView)
        window.contentView = contentView
        
        self.windowCloseCallback = windowCloseCallback
    }
    
    func show(at: CGPoint? = nil) {
        if at != nil {
            window?.setFrame(CGRect(x: at!.x, y: at!.y, width: NoteWindowController.WIDTH, height: NoteWindowController.HEIGHT), display: false)
        }
        showWindow(nil)
    }
    
    func showAccordingTo(window: NSWindow) {
        let frame = window.frame
        
        var pendingAt = CGPoint(x: frame.origin.x, y: frame.origin.y - NoteWindowController.HEIGHT)
        
        if pendingAt.y < 0 {
            let screenSize = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
            pendingAt.y = screenSize.height - NoteWindowController.HEIGHT
            pendingAt.x = frame.origin.x - NoteWindowController.WIDTH
        }
        
        show(at: pendingAt)
    }
    
    override func close() {
        windowCloseCallback?(self)
        windowCloseCallback = nil
        super.close()
    }
    
}
