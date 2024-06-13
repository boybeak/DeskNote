//
//  ContentView.swift
//  DeskNote
//
//  Created by Beak on 2024/6/5.
//

import SwiftUI
import SwiftData

struct NoteView: View {
    
    @StateObject var noteVM: NoteVM
    var uiCallback: NoteUICallback
    
    private let borderColor = Color(red: 0.6, green: 0.6, blue: 0.6, opacity: 0.6)
    private let barColor = Color(red: 0.6, green: 0.6, blue: 0.6, opacity: 0.25)
    
    private let draggerColor = Color(red: 1, green: 1, blue: 1, opacity: 0.4)
    
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
    
    @State private var workItem: DispatchWorkItem? = nil
    
    @State private var showDeleteTip: Bool = false
    
    // MARK: -Body
    var body: some View {
        ZStack(alignment: .top) {
            TextEditor(text: $noteVM.text)
                .font(.system(size: noteVM.fontSize))
                .bold(noteVM.isBold)
                .italic(noteVM.isItalic)
                .foregroundColor(noteVM.getFontColor())
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .safeAreaPadding(.vertical, 16)
                .safeAreaPadding(.horizontal, 8)
                .scrollContentBackground(.hidden)
                .background(.clear)
                .scrollDisabled(true)
            VStack {
                if noteVM.isCursorHovering && !noteVM.isMouseIgnored {
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
                            .foregroundColor(noteVM.iconColor)
                            .overlay {
                                if noteVM.isCursorHovering {
                                    Circle().fill(barColor)
                                }
                            }
                            .popover(isPresented: $noteVM.isConfigPanelShowing) {
                                ConfigView(
                                    noteVM: self.noteVM,
                                    bgColor: $noteVM.bgColor,
                                    fontColor: $noteVM.fontColor,
                                    bgAlpha: $noteVM.globalAlpha,
                                    alphaUnactiveOnly: $noteVM.alphaUnhoverOnly,
                                    fontSize: $noteVM.fontSize, 
                                    isBold: $noteVM.isBold, 
                                    isItalic: $noteVM.isItalic
                                )
                            }
                            .onTapGesture {
                                withAnimation {
                                    noteVM.isConfigPanelShowing.toggle()
                                }
                            }
                    }
                    if !noteVM.isMouseIgnored || noteVM.isPinned {
                        Image(systemName: noteVM.pinIconName)
                            .bold()
                            .frame(width: 24, height: 24)
                            .foregroundColor(noteVM.pinIconColor)
                            .overlay {
                                if noteVM.isCursorHovering && !noteVM.isMouseIgnored {
                                    Circle().fill(barColor)
                                }
                            }
                            .onTapGesture {
                                withAnimation {
                                    noteVM.isPinned.toggle()
                                }
                                noteVM.uiCallback?.actionOnPin(pin: noteVM.isPinned)
                            }
                            .scaleEffect(noteVM.isMouseIgnored ? 0.75 : 1.0)
                            .rotationEffect(.degrees(noteVM.isPinned ? 45 : 0))
                    }
                    ZStack {
                        Image(systemName: noteVM.cursorIconName)
                            .bold()
                            .frame(width: 24, height: 24)
                            .foregroundColor(noteVM.cursorIconColor)
                            .overlay {
                                if noteVM.isCursorHovering && !noteVM.isMouseIgnored {
                                    Circle().fill(barColor)
                                }
                            }
                            .onTapGesture {
                                withAnimation {
                                    noteVM.isMouseIgnoredEnable.toggle()
                                }
                            }
                        if noteVM.isCursorHovering && noteVM.isMouseIgnored {
                            CircularProgressView(progress: noteVM.wakeProgress)
                                .frame(width: 24, height: 24)
                        }
                    }.scaleEffect(noteVM.isMouseIgnored ? 0.75 : 1.0)
                    if !noteVM.isMouseIgnored {
                        Image(systemName: "trash")
                            .bold()
                            .frame(width: 24, height: 24)
                            .foregroundColor(noteVM.iconColor)
                            .overlay {
                                if noteVM.isCursorHovering {
                                    Circle().fill(barColor)
                                }
                            }
                            .onTapGesture {
                                showDeleteTip.toggle()
                            }
                            .popover(isPresented: $showDeleteTip) {
                                VStack {
                                    Text("Tip_delete_note").font(.callout)
                                    Spacer()
                                    Button(action: {
                                        showDeleteTip.toggle()
                                        noteVM.uiCallback?.actionOnClose()
                                    }, label: {
                                        Text("Button_yes")
                                    })
                                }.padding()
                            }
                    }
                }
                .padding(.all, 4)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                
            }
            
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(noteVM.bgColorSmart)
            .cornerRadius(8)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: 1)
                    .background(.clear)
            }
            .onHover { hovering in
                workItem?.cancel()
                workItem = nil
                if hovering {
                    withAnimation {
                        noteVM.isCursorHoveringInMainPanel = hovering
                    }
                } else {
                    workItem = DispatchWorkItem {
                        workItem = nil
                        withAnimation {
                            noteVM.isCursorHoveringInMainPanel = hovering
                            if noteVM.isMouseIgnoredEnable {
                                noteVM.isMouseIgnored = !noteVM.isCursorHovering
                            }
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: workItem!)
                }
                if noteVM.isMouseIgnoredEnable {
                    if noteVM.isMouseIgnored {
                        if (hovering) {
                            noteVM.wakeupTimer.start(totalTime: 3)
                        } else {
                            noteVM.wakeupTimer.stop()
                            noteVM.wakeupTimer.reset()
                            noteVM.wakeProgress = 0
                        }
                    }
                }
                
            }
            .onAppear {
                self.noteVM.uiCallback = self.uiCallback
            }
    }
}
