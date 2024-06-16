//
//  Note.swift
//  DeskNote
//
//  Created by Beak on 2024/6/11.
//

import Foundation
import SwiftUI

/*
final class Note: NSManagedObject, Identifiable {
    
    var text: String = ""
    var position: CGPoint = CGPoint()
    var bgColor: RGB = RGB(color: .clear)
    var alpha: Double = 1
    var alphaOnlyUnhover: Bool = false
    var fontColor: RGB = RGB(color: .clear)
    var fontSize: Double = 16
    var isBold: Bool = false
    var isItalic: Bool = false
    
    var isPinned: Bool = false
    var isMouseIgnoreEnabled: Bool = false
    
    init(text: String, position: CGPoint, bgColor: RGB, alpha: Double, alphaOnlyUnhover: Bool, fontColor: RGB, fontSize: Double, isBold: Bool, isItalic: Bool, isPinned: Bool, isMouseIgnoreEnabled: Bool) {
        self.text = text
        self.position = position
        self.bgColor = bgColor
        self.alpha = alpha
        self.alphaOnlyUnhover = alphaOnlyUnhover
        self.fontColor = fontColor
        self.fontSize = fontSize
        self.isBold = isBold
        self.isItalic = isItalic
        self.isPinned = isPinned
        self.isMouseIgnoreEnabled = isMouseIgnoreEnabled
    }
    
    convenience init(text: String, position: CGPoint, bgColor: Color, alpha: Double, alphaOnlyUnhover: Bool, fontColor: Color, fontSize: Double, isBold: Bool, isItalic: Bool, isPinned: Bool, isMouseIgnoreEnabled: Bool) {
        self.init(text: text, position: position, bgColor: RGB(color: bgColor), alpha: alpha, alphaOnlyUnhover: alphaOnlyUnhover, fontColor: RGB(color: fontColor), fontSize: fontSize, isBold: isBold, isItalic: isItalic, isPinned: isPinned, isMouseIgnoreEnabled: isMouseIgnoreEnabled)
    }
    
    convenience init(position: CGPoint) {
        self.init(text: "", position: position, bgColor: ConfigView.bgPalette[0], alpha: 1, alphaOnlyUnhover: false, fontColor: ConfigView.fontPalette[0], fontSize: 16, isBold: false, isItalic: false, isPinned: false, isMouseIgnoreEnabled: false)
    }
}
 */

/*
class Note: NSManagedObject {
    @NSManaged var text: String
}*/

extension Note {
    convenience init(context: NSManagedObjectContext, position: CGPoint, screen: NSScreen? = nil) {
        self.init(context: context)
        self.position = position.toData()
        self.bgColor = ConfigView.bgPalette[0].toData()
        self.fontColor = ConfigView.fontPalette[0].toData()
        self.alpha = 1
        self.fontSize = 16
        if (screen != nil) {
            self.screenName = screen!.localizedName
        } else {
            if NSScreen.screens.isEmpty {
                self.screenName = nil
            } else {
                self.screenName = NSScreen.screens[0].localizedName
            }
        }
    }
}

struct RGB: Codable {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    
    init(turple: (red: CGFloat, green: CGFloat, blue: CGFloat)) {
        self.red = turple.red
        self.green = turple.green
        self.blue = turple.blue
    }
    
    init(color: Color) {
        self.init(turple: color.rgb)
    }
}

extension CGPoint {
    func toData()-> Data {
        var point = self
        return Data(bytes: &point, count: MemoryLayout<CGPoint>.size)
    }
}

extension Color {
    func toData()-> Data {
        return withUnsafeBytes(of: self.rgb) {
            Data($0)
        }
    }
}

extension NSData {
    
}

extension Data {
    func toPoint()-> CGPoint {
        guard self.count == MemoryLayout<CGPoint>.size else { return .zero }
        var point = CGPoint()
        self.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            if bytes.count >= MemoryLayout<CGPoint>.size {
                let typedPointer = bytes.baseAddress!.assumingMemoryBound(to: CGPoint.self)
                point = typedPointer.pointee
            }
        }
        return point
    }
    func toColor()-> Color {
        guard self.count == MemoryLayout<(CGFloat, CGFloat, CGFloat)>.size else { return .clear }
        let rgb = self.withUnsafeBytes { $0.load(as: (CGFloat, CGFloat, CGFloat).self) }
        
        return Color(red: rgb.0, green: rgb.1, blue: rgb.2)
    }
}
