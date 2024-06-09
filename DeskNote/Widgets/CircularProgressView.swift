//
//  A.swift
//  DeskNote
//
//  Created by Beak on 2024/6/9.
//

import SwiftUI

struct CircularProgressView: View {
    var progress: Double
    var lineWidth: CGFloat = 2
    var trackColor: Color = .clear
    var progressColor: Color = .gray

    var body: some View {
        ZStack {
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(progressColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
        }
    }
}
