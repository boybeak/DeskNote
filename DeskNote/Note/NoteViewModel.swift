//
//  NoteViewModel.swift
//  DeskNote
//
//  Created by Beak on 2024/6/9.
//

import Foundation
import SwiftUI

class NoteViewModel: ObservableObject {
    
    @Published var uiCallback: NoteUICallback?
    let wakeupTimer = CountdownTimer()
    
    @Published var wakeProgress: Double = 0
    
    @Published var isMouseIgnoredEnable = false
//    {
//        didSet {
//            if oldValue != isMouseIgnoredEnable && isMouseIgnoredEnable {
//                isMouseIgnored = true
//            }
//        }
//    }
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
        wakeupTimer.onUpdate = { [self] remaining in
            wakeProgress = 1 - 0.25 * Double(remaining)
        }
        wakeupTimer.onFinish = {
            withAnimation {
                self.isMouseIgnored = false
            }
        }
    }
    
    func wakeup() {}
    
    func sleep() {}
    
}
