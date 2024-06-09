//
//  Item.swift
//  DeskNote
//
//  Created by Beak on 2024/6/5.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
