//
//  PaletteView.swift
//  DeskNote
//
//  Created by Beak on 2024/6/9.
//

import SwiftUI

struct PaletteView: View {
    
    private static let SPACING: Double = 8
    
    static let COLOR_CIRCLE_SIZE: Double = 24
    
    private let columns = [
        GridItem(.fixed(PaletteView.COLOR_CIRCLE_SIZE), spacing: PaletteView.SPACING),
        GridItem(.fixed(PaletteView.COLOR_CIRCLE_SIZE), spacing: PaletteView.SPACING),
        GridItem(.fixed(PaletteView.COLOR_CIRCLE_SIZE), spacing: PaletteView.SPACING)
    ]
    
    let palette: [Color]
    
    let onSelected: (Int) -> Void
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: PaletteView.SPACING) {
            ForEach(palette.indices, id: \.self) { index in
                Circle().fill(palette[index]).stroke(.white, lineWidth: 1)
                    .onTapGesture {
                        onSelected(index)
                    }
            }
        }
    }
}
