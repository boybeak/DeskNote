//
//  ColorUtils.swift
//  DeskNote
//
//  Created by Beak on 2024/6/11.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    var rgb: (red: CGFloat, green: CGFloat, blue: CGFloat) {
        #if canImport(UIKit)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        let nativeColor = UIColor(self)
        nativeColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue)

        #elseif canImport(AppKit)
        let nsColor = NSColor(self)
        guard let rgbColor = nsColor.usingColorSpace(.deviceRGB) else {
            return (0, 0, 0)
        }
        return (rgbColor.redComponent, rgbColor.greenComponent, rgbColor.blueComponent)
        #endif
    }
}
