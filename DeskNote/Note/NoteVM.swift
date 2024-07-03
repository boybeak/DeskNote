//
//  NoteViewModel.swift
//  DeskNote
//
//  Created by Beak on 2024/6/9.
//

import Foundation
import SwiftUI

class NoteVM: ObservableObject {
    
    var note: Note
    
    private var isInitialized: Bool = false
    
    @Published
    var text: String {
        didSet {
            if (oldValue != text && isInitialized) {
                note.text = text
                NoteManager.shared.updateNote()
            }
        }
    }
    @Published
    var bgColor: Color {
        didSet {
            if (oldValue != bgColor && isInitialized) {
                refreshBackgroundColor()
                
                note.bgColor = bgColor.toData()
                NoteManager.shared.updateNote()
            }
        }
    }
    @Published var bgColorSmart: Color = ConfigView.bgPalette[0]
    
    @Published 
    var isGlobalAlphaEditing: Bool = false {
        didSet {
            if (oldValue != isGlobalAlphaEditing) {
                refreshBackgroundColor()
            }
        }
    }
    @Published
    var globalAlpha: Double {
        didSet {
            if (oldValue != globalAlpha && isInitialized) {
                refreshBackgroundColor()
                
                note.alpha = Float(globalAlpha)
                NoteManager.shared.updateNote()
            }
        }
    }
    
    @Published
    var alphaUnhoverOnly: Bool  {
        didSet {
            if (oldValue != alphaUnhoverOnly && isInitialized) {
                refreshBackgroundColor()
                
                note.alphaOnlyUnhover = alphaUnhoverOnly
                NoteManager.shared.updateNote()
            }
        }
    }
    
    @Published
    var fontColor: Color {
        didSet {
            if (oldValue != fontColor && isInitialized) {
                note.fontColor = fontColor.toData()
                NoteManager.shared.updateNote()
            }
        }
    }
    
    @Published
    var fontSize: Double {
        didSet {
            if (oldValue != fontSize && isInitialized) {
                note.fontSize = Float(fontSize)
                NoteManager.shared.updateNote()
            }
        }
    }
    
    @Published
    var isBold: Bool {
        didSet {
            if (oldValue != isBold && isInitialized) {
                note.isBold = isBold
                NoteManager.shared.updateNote()
            }
        }
    }
    
    @Published
    var isItalic: Bool {
        didSet {
            if (oldValue != isItalic && isInitialized) {
                note.isItalic = isItalic
                NoteManager.shared.updateNote()
            }
        }
    }
    
    private let iconHintColor = Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.5)
    @Published var iconColor: Color
    
    var pinIconColor: Color {
        isMouseIgnored ? iconHintColor : iconColor
    }
    
    var pinIconName: String {
        isPinned ? "pin.fill" : "pin.slash"
    }
    
    var cursorIconColor: Color {
        isMouseIgnored ? iconHintColor : iconColor
    }
    
    var cursorIconName: String {
        isMouseIgnoredEnable ? "cursorarrow.slash" : "cursorarrow"
    }
    
    var isCursorHovering: Bool = false {
        didSet {
            if oldValue != isCursorHovering {
                if isCursorHovering {
                    withAnimation {
                        iconColor = fontColor
                    }
                } else {
                    withAnimation {
                        iconColor = iconHintColor
                    }
                }
                uiCallback?.actionOnHover(hover: isCursorHovering)
            }
        }
    }
    
    @Published var isHoveringInMainPanel: Bool = false {
        didSet {
            if oldValue != isHoveringInMainPanel {
                refreshBackgroundColor()
                
                isCursorHovering = computeIsHovering()
            }
        }
    }
    @Published var isHoveringInConfigPanel: Bool = false {
        didSet {
            if (oldValue != isHoveringInConfigPanel) {
                refreshBackgroundColor()
                
                isCursorHovering = computeIsHovering()
            }
        }
    }
    
    @Published var isHoveringInDeletePanel: Bool = false {
        didSet {
            if (oldValue != isHoveringInDeletePanel) {
                refreshBackgroundColor()
                
                isCursorHovering = computeIsHovering()
            }
        }
    }
    
    @Published var isConfigPanelShowing = false
    
    @Published var uiCallback: NoteUICallback?
    
    @Published
    var isPinned: Bool {
        didSet {
            if (oldValue != isPinned && isInitialized) {
                note.isPinned = isPinned
                NoteManager.shared.updateNote()
            }
        }
    }
    
    let wakeupTimer = CountdownTimer()
    
    @Published var wakeProgress: Double = 0
    
    @Published
    var isMouseIgnoredEnable: Bool {
        didSet {
            if (oldValue != isMouseIgnoredEnable && isInitialized) {
                note.isMouseIgnoreEnabled = isMouseIgnoredEnable
                NoteManager.shared.updateNote()
            }
        }
    }

    @Published var isMouseIgnored = false {
        didSet {
            if oldValue != isMouseIgnored {
                if (isMouseIgnored) {
                    wakeProgress = 0
                }
                refreshBackgroundColor()
                uiCallback?.actionOnMouseIgnore(ignore: isMouseIgnored)
            }
        }
    }
    
    init(note: Note) {
        self.note = note
        
        self.text = note.text ?? ""
        self.bgColor = note.bgColor?.toColor() ?? ConfigView.bgPalette[0]
        self.globalAlpha = Double(note.alpha)
        self.alphaUnhoverOnly = note.alphaOnlyUnhover
        self.fontColor = note.fontColor?.toColor() ?? ConfigView.fontPalette[0]
        self.fontSize = Double(note.fontSize)
        self.isBold = note.isBold
        self.isItalic = note.isItalic
        self.isPinned = note.isPinned
        self.isMouseIgnoredEnable = note.isMouseIgnoreEnabled
        
        iconColor = iconHintColor
        
        wakeupTimer.onUpdate = { [self] remaining in
            withAnimation {
                wakeProgress = 1 - 0.25 * Double(remaining)
            }
        }
        wakeupTimer.onFinish = {
            withAnimation {
                self.wakeProgress = 1
                self.isMouseIgnored = false
            }
        }
        
        self.refreshBackgroundColor()
        
        isInitialized = true
    }
    
    private func computeIsHovering()-> Bool {
        return isHoveringInMainPanel || isHoveringInConfigPanel || isHoveringInDeletePanel
    }
    
    private func refreshBackgroundColor() {
        bgColorSmart = computeBackgroundColor()
    }
    
    private func computeBackgroundColor()-> Color {
        return if alphaUnhoverOnly {
            if isCursorHovering && !isGlobalAlphaEditing {
                bgColor
            } else {
                bgColor.opacity(globalAlpha)
            }
        } else {
            bgColor.opacity(globalAlpha)
        }
    }
    
    func getFontColor()-> Color {
        return fontColor.opacity(globalAlpha)
    }
    
}
