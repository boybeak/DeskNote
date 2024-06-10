//
//  ConfigView.swift
//  DeskNote
//
//  Created by Beak on 2024/6/9.
//

import SwiftUI

struct ConfigView: View {
    
    static let bgPalette: [Color] = [.yellow, .red, .green, .blue, .orange, .mint, .cyan]
    static let fontPalette: [Color] = [.black, .white, .gray]
    
    @ObservedObject var noteVM: NoteViewModel
    
    @Binding var bgColor: Color
    @Binding var fontColor: Color
    @Binding var bgAlpha: Double
    @Binding var alphaUnactiveOnly: Bool
    @Binding var fontSize: Double
    
    @State private var workItem: DispatchWorkItem? = nil
    
    var body: some View {
        VStack {
            Text("Background")
            PaletteView(palette: ConfigView.bgPalette) { index in
                withAnimation {
                    bgColor = ConfigView.bgPalette[index]
                }
            }
            Slider(value: $bgAlpha, in: 0.2 ... 1)
                .controlSize(.mini)
                .frame(minWidth: 0, maxWidth: .infinity)
            Toggle(isOn: $alphaUnactiveOnly) {
                Text("Unactive only")
            }
            .toggleStyle(.checkbox)
            Divider()
            Text("Font")
            PaletteView(palette: ConfigView.fontPalette) { index in
                withAnimation {
                    fontColor = ConfigView.fontPalette[index]
                }
            }
            Slider(value: $fontSize, in: 10 ... 36)
                .controlSize(.mini)
                .frame(minWidth: 0, maxWidth: .infinity)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .padding(.all, 16)
        .onHover { hovering in
            workItem?.cancel()
            workItem = nil
            if hovering {
                noteVM.isCursorHoveringInConfigPanel = hovering
            } else {
                workItem = DispatchWorkItem {
                    workItem = nil
                    noteVM.isCursorHoveringInConfigPanel = hovering
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: workItem!)
            }
            
        }
    }
}
