//
//  ConfigView.swift
//  DeskNote
//
//  Created by Beak on 2024/6/9.
//

import SwiftUI

struct ConfigView: View {
    
    static let bgPalette: [Color] = ColorPalette.allCases.map { $0.color }
    static let fontPalette: [Color] = [.black, .white, Color(red: 0.32, green: 0.32, blue: 0.32)]
    
    @ObservedObject var noteVM: NoteVM
    
    @Binding var bgColor: Color
    @Binding var fontColor: Color
    @Binding var bgAlpha: Double
    @Binding var alphaUnactiveOnly: Bool
    @Binding var fontSize: Double
    @Binding var isBold: Bool
    @Binding var isItalic: Bool
    
    @State private var workItem: DispatchWorkItem? = nil
    
    var body: some View {
        VStack {
            Text("Config_title_background")
                .bold()
                .font(.title3)
            PaletteView(palette: ConfigView.bgPalette) { index in
                withAnimation {
                    bgColor = ConfigView.bgPalette[index]
                }
            }
            Slider(
                value: $bgAlpha,
                in: 0.2 ... 1,
                onEditingChanged: { editing in
                    withAnimation {
                        noteVM.isGlobalAlphaEditing = editing
                    }
                }
            )
            .controlSize(.mini)
            .frame(minWidth: 0, maxWidth: .infinity)

            Toggle(isOn: $alphaUnactiveOnly) {
                Text("Config_alpha_unhover_only")
            }
            .toggleStyle(.checkbox)
            
            Divider()
            
            Text("Config_title_font")
                .bold()
                .font(.title3)
            PaletteView(palette: ConfigView.fontPalette) { index in
                withAnimation {
                    fontColor = ConfigView.fontPalette[index]
                }
            }
            Slider(value: $fontSize, in: 10 ... 36)
                .controlSize(.mini)
                .frame(minWidth: 0, maxWidth: .infinity)
            HStack {
                Toggle(isOn: $isBold) {
                    Image(systemName: "bold")
                }
                .frame(width: 24, height: 24)
                .toggleStyle(.button)
                Toggle(isOn: $isItalic) {
                    Image(systemName: "italic")
                }
                .frame(width: 24, height: 24)
                .toggleStyle(.button)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.all, 8)
        .onHover { hovering in
            workItem?.cancel()
            workItem = nil
            if hovering {
                withAnimation {
                    noteVM.isHoveringInConfigPanel = hovering
                }
            } else {
                workItem = DispatchWorkItem {
                    workItem = nil
                    withAnimation {
                        noteVM.isHoveringInConfigPanel = hovering
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: workItem!)
            }
            
        }
    }
    
}
