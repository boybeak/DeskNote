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
    private var onDragStart: (() -> Void)? =  nil
    private var onDragEnd: (() -> Void)? = nil
    private var onHover: ((_ hover: Bool) -> Void)? = nil
    
    init(onMouseIgnore: ((_ ignored: Bool) -> Void)?, onPin: ((_ pin: Bool) -> Void)?, onClose: (() -> Void)? = nil, onDragStart: (() -> Void)? = nil, onDragEnd: (() -> Void)? = nil, onHover: ((_ hover: Bool) -> Void)? = nil) {
        self.onMouseIgnore = onMouseIgnore
        self.onPin = onPin
        self.onClose = onClose
        self.onDragStart = onDragStart
        self.onDragEnd = onDragEnd
        self.onHover = onHover
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
    func actionOnDragStart() {
        onDragStart?()
    }
    func actionOnDragEnd() {
        onDragEnd?()
    }
    func actionOnHover(hover: Bool) {
        onHover?(hover)
    }
}
