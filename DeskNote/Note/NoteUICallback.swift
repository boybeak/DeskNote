//
//  A.swift
//  DeskNote
//
//  Created by Beak on 2024/6/9.
//

import SwiftUI

class NoteUICallback {
    
    private var onMouseIgnore: ((_ ignored: Bool) -> Void)? = nil
    private var onPin: ((_ pin: Bool) -> Void)? = nil
    private var onClose: (() -> Void)? = nil
    private var onDragMove: ((_ move: CGSize) -> Void)? =  nil
    private var onDragEnd: (() -> Void)? = nil
    
    init(onMouseIgnore: ((_ ignored: Bool) -> Void)?, onPin: ((_ pin: Bool) -> Void)?, onClose: ( () -> Void)? = nil, onDragMove: ( (_: CGSize) -> Void)? = nil, onDragEnd: ( () -> Void)? = nil) {
        self.onMouseIgnore = onMouseIgnore
        self.onPin = onPin
        self.onClose = onClose
        self.onDragMove = onDragMove
        self.onDragEnd = onDragEnd
    }
    
    func actionOnMouseIgnore(ignore: Bool) {
        onMouseIgnore?(ignore)
    }
    
    func actionOnPin(pin: Bool) {
        onPin?(pin)
    }
    func actionOnClose() {
        onClose?()
    }
    func actionOnDragMove(move: CGSize) {
        onDragMove?(move)
    }
    func actionOnDragEnd() {
        onDragEnd?()
    }
}
