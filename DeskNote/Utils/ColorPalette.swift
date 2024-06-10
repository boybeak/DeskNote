//
//  HoloColor.swift
//  DeskNote
//
//  Created by Beak on 2024/6/10.
//

import SwiftUI

enum ColorPalette : CaseIterable {
//    case holoYellow
    case holoOrangeLight
    case holoOrangeDark
    
//    case holoGreen
    case holoGreenDark
    case holoGreenLight
    
//    case holoBlue
    case holoBlueDark
    case holoBlueLight
    
//    case holoRed
    case holoRedDark
    case holoRedLight
    
    case holoPurple

    var color: Color {
        switch self {
//        case .holoBlue:return Color(red: 0, green: 0, blue: 1)
        case .holoBlueDark:
            return Color(red: 0.0, green: 0.6, blue: 0.8)
        case .holoBlueLight:
            return Color(red: 0.2, green: 0.71, blue: 0.9)
//        case .holoGreen:return Color(red: 0, green: 1, blue: 0.0)
        case .holoGreenDark:
            return Color(red: 0.4, green: 0.6, blue: 0.0)
        case .holoGreenLight:
            return Color(red: 0.6, green: 0.8, blue: 0.0)
//        case .holoRed:return Color(red: 1, green: 0, blue: 0)
        case .holoRedDark:
            return Color(red: 0.8, green: 0.0, blue: 0.0)
        case .holoRedLight:
            return Color(red: 1.0, green: 0.27, blue: 0.27)
        case .holoPurple:
            return Color(red: 0.67, green: 0.4, blue: 0.8)
//        case .holoYellow:return Color(red: 1.0, green: 1, blue: 0.0)
        case .holoOrangeLight:
            return Color(red: 1.0, green: 0.73, blue: 0.2)
        case .holoOrangeDark:
            return Color(red: 1.0, green: 0.53, blue: 0.0)
        }
    }
}
