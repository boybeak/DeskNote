//
//  NoteWindow.swift
//  DeskNote
//
//  Created by Beak on 2024/6/7.
//

import AppKit

class NoteWindow: NSWindow {
    
    
    
    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return true
    }
}
