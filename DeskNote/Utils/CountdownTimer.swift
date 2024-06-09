//
//  CountdownTimer.swift
//  DeskNote
//
//  Created by Beak on 2024/6/9.
//

import Cocoa

class CountdownTimer {
    private var remainingTime: Int = 0
    private var timer: Timer?
    
    var onUpdate: ((Int) -> Void)?
    var onFinish: (() -> Void)?
    
    // 启动倒计时器
    func start(totalTime: Int) {
        // 检查参数合法性
        guard totalTime > 0 else {
            print("倒计时时间必须是正整数")
            return
        }
        
        stop() // 确保没有正在运行的计时器
        remainingTime = totalTime
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        onUpdate?(remainingTime) // 更新UI显示初始时间
    }
    
    // 停止倒计时器
    func stop() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    // 重置倒计时器
    func reset() {
        stop()
        remainingTime = 0
        onUpdate?(remainingTime) // 更新UI显示重置后的时间
    }
    
    // 定时器触发时的回调
    @objc private func timerFired() {
        if remainingTime > 0 {
            remainingTime -= 1
            onUpdate?(remainingTime)
        } else {
            stop()
            onFinish?()
        }
    }
}
