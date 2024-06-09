//
//  ContentView.swift
//  DeskNote
//
//  Created by Beak on 2024/6/5.
//

import SwiftUI
import SwiftData

struct NoteView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @StateObject private var noteVM: NoteViewModel = NoteViewModel()
    private var uiCallback: NoteUICallback?
    
    @State private var text: String = "Hello, World"
    
    @State private var configShowing = false
    
    private let barColor = Color(red: 0.6, green: 0.6, blue: 0.6, opacity: 0.25)
    
    private let iconHintColor = Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.5)
    @State private var iconColor: Color
    
    private let draggerColor = Color(red: 1, green: 1, blue: 1, opacity: 0.4)
    @State private var draggerEnable = false {
        didSet {
            if draggerEnable {
                withAnimation {
                    iconColor = fontColor
                }
            } else {
                withAnimation {
                    iconColor = iconHintColor
                }
            }
        }
    }
    
    @State private var bgColor: Color = ConfigView.bgPalette[0]
    @State private var bgAlpha: Double = 1
        
    
    @State private var fontColor: Color = ConfigView.fontPalette[0]
    @State private var fontSize: Double = 16 // 初始值
    
    @State private var alphaUnactiveOnly: Bool = false
    
    @State private var isDragging = false {
        didSet {
            if (isDragging) {
                NSCursor.closedHand.set()
            } else {
                NSCursor.openHand.set()
            }
        }
    }
    private var drag: some Gesture {
        DragGesture()
            .onChanged { ev in
                self.isDragging = true
                noteVM.uiCallback?.actionOnDragMove(move: ev.translation)
            }
            .onEnded { ev in
                self.isDragging = false
                noteVM.uiCallback?.actionOnDragEnd()
            }
    }
    
    @State private var isPinned = false
    
    init(callback: NoteUICallback? = nil) {
        self.iconColor = self.iconHintColor
        self.uiCallback = callback
    }
    
    // MARK: -Body
    var body: some View {
        ZStack(alignment: .top) {
            TextEditor(text: $text)
                .font(.system(size: fontSize))
                .foregroundColor(fontColor.opacity(bgAlpha))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .safeAreaPadding(EdgeInsets(top: 16, leading: 8, bottom: 8, trailing: 16))
                .scrollContentBackground(.hidden)
                .background(.clear)
                .scrollDisabled(true)
            VStack {
                if draggerEnable && !noteVM.isMouseIgnored {
                    RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                        .fill(draggerColor)
                        .stroke(barColor, lineWidth: 1)
                        .padding(.top, 0)
                        .frame(width: 40, height: 8)
                        .offset(y: 4)
                        .transition(.opacity)
                        .onHover { hovering in
                            if hovering {
                                NSCursor.openHand.set()
                            } else {
                                NSCursor.arrow.set()
                            }
                        }
                        .gesture(drag)
                }
                Spacer()
                HStack(spacing: noteVM.isMouseIgnored ? 0 : 8) {
                    if !noteVM.isMouseIgnored {
                        Image(systemName: "paintpalette")
                            .bold()
                            .frame(width: 24, height: 24)
                            .foregroundColor(iconColor)
                            .overlay {
                                if draggerEnable {
                                    Circle().fill(barColor)
                                }
                            }
                            .popover(isPresented: $configShowing) {
                                ConfigView(
                                    bgColor: $bgColor,
                                    fontColor: $fontColor,
                                    bgAlpha: $bgAlpha, 
                                    alphaUnactiveOnly: $alphaUnactiveOnly,
                                    fontSize: $fontSize
                                )
                            }
                            .onTapGesture {
                                configShowing.toggle()
                            }
                    }
                    if !noteVM.isMouseIgnored || isPinned {
                        Image(systemName: isPinned ? "pin.fill" : "pin.slash")
                            .bold()
                            .frame(width: 24, height: 24)
                            .foregroundColor(noteVM.isMouseIgnored ? iconHintColor : iconColor)
                            .overlay {
                                if draggerEnable && !noteVM.isMouseIgnored {
                                    Circle().fill(barColor)
                                }
                            }
                            .onTapGesture {
                                withAnimation {
                                    isPinned.toggle()
                                }
                                noteVM.uiCallback?.actionOnPin(pin: isPinned)
                            }
                            .scaleEffect(noteVM.isMouseIgnored ? 0.75 : 1.0)
                    }
                    ZStack {
                        Image(systemName: noteVM.isMouseIgnoredEnable ? "cursorarrow.slash" : "cursorarrow")
                            .bold()
                            .frame(width: 24, height: 24)
                            .foregroundColor(noteVM.isMouseIgnored ? iconHintColor : iconColor)
                            .overlay {
                                if draggerEnable && !noteVM.isMouseIgnored {
                                    Circle().fill(barColor)
                                }
                            }
                            .onTapGesture {
                                withAnimation {
                                    noteVM.isMouseIgnoredEnable.toggle()
                                }
                            }
                        if draggerEnable && noteVM.isMouseIgnored {
                            CircularProgressView(progress: noteVM.wakeProgress)
                                .frame(width: 24, height: 24)
                        }
                    }.scaleEffect(noteVM.isMouseIgnored ? 0.75 : 1.0)
                    if !noteVM.isMouseIgnored {
                        Image(systemName: "trash")
                            .bold()
                            .frame(width: 24, height: 24)
                            .foregroundColor(iconColor)
                            .overlay {
                                if draggerEnable {
                                    Circle().fill(barColor)
                                }
                            }
                            .onTapGesture {
                                noteVM.uiCallback?.actionOnClose()
                            }
                    }
                }
                .padding(.all, 4)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                
            }
            
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(bgColor.opacity(bgAlpha))
            .cornerRadius(8)
            .onHover { hovering in
                withAnimation {
                    draggerEnable.toggle()
                }
                if noteVM.isMouseIgnoredEnable {
                    if noteVM.isMouseIgnored {
                        if (hovering) {
                            noteVM.wakeupTimer.start(totalTime: 4)
                        } else {
                            noteVM.wakeupTimer.stop()
                            noteVM.wakeupTimer.reset()
                            noteVM.wakeProgress = 0
                        }
                    }
                    if !hovering {
                        withAnimation {
                            noteVM.isMouseIgnored = true
                        }
                    }
                }
                
            }
            .onAppear {
                self.noteVM.uiCallback = self.uiCallback
            }
    }
}

#Preview {
    NoteView()
        .modelContainer(for: Item.self, inMemory: true)
}
