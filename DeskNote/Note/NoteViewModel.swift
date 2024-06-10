//
//  NoteViewModel.swift
//  DeskNote
//
//  Created by Beak on 2024/6/9.
//

import Foundation
import SwiftUI

class NoteViewModel: ObservableObject {
    
    @Published var bgColor: Color = .clear
    @Published var bgAlpha: Double = 1
    
    @Published var alphaUnactiveOnly: Bool = false
    
    @Published var fontColor: Color = ConfigView.fontPalette[0]
    
    @Published var fontSize: Double = 16
    
    
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
            }
        }
    }
    @Published var isCursorHoveringInConfigPanel: Bool = false
    
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
                uiCallback?.actionOnMouseIgnore(ignore: isMouseIgnored)
            }
        }
    }
    
    init() {
        bgColor = ConfigView.bgPalette[0]
        iconColor = iconHintColor
        
        wakeupTimer.onUpdate = { [self] remaining in
            wakeProgress = 1 - 0.25 * Double(remaining)
        }
        wakeupTimer.onFinish = {
            withAnimation {
                self.isMouseIgnored = false
            }
        }
    }
    
    func getBackgroundColor()-> Color {
        return if alphaUnactiveOnly {
            if isCursorHovering {
                bgColor
            } else {
                bgColor.opacity(bgAlpha)
            }
        } else {
            bgColor.opacity(bgAlpha)
        }
    }
    
    func getFontColor()-> Color {
        return fontColor.opacity(bgAlpha)
    }
    
}
