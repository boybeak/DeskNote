//
//  NoteViewModel.swift
//  DeskNote
//
//  Created by Beak on 2024/6/9.
//

import Foundation
import SwiftUI

class NoteViewModel: ObservableObject {
    
    @Published var bgColor: Color = ConfigView.bgPalette[0] {
        didSet {
            if (oldValue != bgColor) {
                refreshBackgroundColor()
            }
        }
    }
    @Published var bgColorCompat: Color = ConfigView.bgPalette[0]
    
    @Published var isGlobalAlphaEditing: Bool = false {
        didSet {
            if (oldValue != isGlobalAlphaEditing) {
                refreshBackgroundColor()
            }
        }
    }
    @Published var globalAlpha: Double = 1 {
        didSet {
            if (oldValue != globalAlpha) {
                refreshBackgroundColor()
            }
        }
    }
    
    @Published var alphaUnactiveOnly: Bool = false {
        didSet {
            if (oldValue != alphaUnactiveOnly) {
                refreshBackgroundColor()
            }
        }
    }
    
    @Published var fontColor: Color = ConfigView.fontPalette[0]
    
    @Published var fontSize: Double = 16
    
    @Published var isBold: Bool = false
    
    @Published var isItalic: Bool = false
    
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
    
    var isCursorHovering: Bool {
        return isCursorHoveringInMainPanel || isCursorHoveringInConfigPanel
    }
    
    @Published var isCursorHoveringInMainPanel: Bool = false {
        didSet {
            if oldValue != isCursorHoveringInMainPanel {
                if isCursorHovering {
                    withAnimation {
                        iconColor = fontColor
                    }
                } else {
                    withAnimation {
                        iconColor = iconHintColor
                    }
                }
                refreshBackgroundColor()
            }
        }
    }
    @Published var isCursorHoveringInConfigPanel: Bool = false {
        didSet {
            if (oldValue != isCursorHoveringInConfigPanel) {
                refreshBackgroundColor()
            }
        }
    }
    
    @Published var isConfigPanelShowing = false
    
    @Published var uiCallback: NoteUICallback?
    
    @Published var isPinned = false
    
    let wakeupTimer = CountdownTimer()
    
    @Published var wakeProgress: Double = 0
    
    @Published var isMouseIgnoredEnable = false

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
    
    init() {
        bgColor = ConfigView.bgPalette[0]
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
    }
    
    private func refreshBackgroundColor() {
        bgColorCompat = computeBackgroundColor()
    }
    
    private func computeBackgroundColor()-> Color {
        return if alphaUnactiveOnly {
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
