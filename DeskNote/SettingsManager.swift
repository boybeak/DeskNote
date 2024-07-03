//
//  SettingsManager.swift
//  DeskNote
//
//  Created by Beak on 2024/7/3.
//

import Foundation
import AppKit
import WinToEdge

class SettingsManager: NSObject {
    
    static let shared = SettingsManager()
    
    let edgeSubMenu: NSMenu
    private let dockLeftItem: NSMenuItem
    private let dockRightItem: NSMenuItem
    private let dockBottomItem: NSMenuItem
    
    private let legacySmallItem: NSMenuItem
    private let legacyMediumItem: NSMenuItem
    private let legacyLargeItem: NSMenuItem
    
    var isDockLeftEnabled: Bool {
        return UserDefaults.standard.bool(forKey: UserDefaults.Keys.DOCK_LEFT)
    }
    
    var isDockRightEnabled: Bool {
        return UserDefaults.standard.bool(forKey: UserDefaults.Keys.DOCK_RIGHT)
    }
    
    var isDockBottomEnabled: Bool {
        return UserDefaults.standard.bool(forKey: UserDefaults.Keys.DOCK_BOTTOM)
    }
    
    var snapEdges: [EdgePosition] {
        var edges = [EdgePosition]()
        
        if isDockLeftEnabled {
            edges.append(.left)
        }
        
        if isDockRightEnabled {
            edges.append(.right)
        }
        
        if isDockBottomEnabled {
            edges.append(.bottom)
        }
        
        return edges
    }
    
    var legacy: Int {
        return UserDefaults.standard.integer(forKey: UserDefaults.Keys.LEGACY)
    }
    
    // 定义回调类型
    typealias DockEdgesCallback = (EdgePosition, Bool) -> Void
    typealias LegacyCallback = (Legacy) -> Void
    
    // 存储回调
    private var dockEdgesCallbacks = [UUID : DockEdgesCallback]()
    private var legacySizeCallbacks = [UUID : LegacyCallback]()
    
    private override init () {
        edgeSubMenu = NSMenu()
        
        dockLeftItem = NSMenuItem(title: NSLocalizedString("Menu_item_edge_dock_left", comment: ""), action: #selector(onLeftAction), keyEquivalent: "")
        dockRightItem = NSMenuItem(title: NSLocalizedString("Menu_item_edge_dock_right", comment: ""), action: #selector(onRightAction), keyEquivalent: "")
        dockBottomItem = NSMenuItem(title: NSLocalizedString("Menu_item_edge_dock_bottom", comment: ""), action: #selector(onBottomAction), keyEquivalent: "")
        
        legacySmallItem = NSMenuItem(title: NSLocalizedString("Menu_item_legacy_small", comment: ""), action: #selector(onLegacyAction(_:)), keyEquivalent: "")
        legacyMediumItem = NSMenuItem(title: NSLocalizedString("Menu_item_legacy_medium", comment: ""), action: #selector(onLegacyAction(_:)), keyEquivalent: "")
        legacyLargeItem = NSMenuItem(title: NSLocalizedString("Menu_item_legacy_large", comment: ""), action: #selector(onLegacyAction(_:)), keyEquivalent: "")
        
        super.init()
        
        dockLeftItem.target = self
        dockRightItem.target = self
        dockBottomItem.target = self
        legacySmallItem.target = self
        legacyMediumItem.target = self
        legacyLargeItem.target = self
        
        dockLeftItem.state = isDockLeftEnabled ? .on : .off
        dockRightItem.state = isDockRightEnabled ? .on : .off
        dockBottomItem.state = isDockBottomEnabled ? .on : .off
        
        let legacyValue = if UserDefaults.standard.object(forKey: UserDefaults.Keys.LEGACY) != nil {
            UserDefaults.standard.integer(forKey: UserDefaults.Keys.LEGACY)
        } else {
            Legacy.small.rawValue
        }
        let _ = onLegacyChanged(legacyValue: legacyValue)
        
        edgeSubMenu.addItem(.sectionHeader(title: "Edge"))
        edgeSubMenu.addItem(dockLeftItem)
        edgeSubMenu.addItem(dockRightItem)
        edgeSubMenu.addItem(dockBottomItem)
        
        edgeSubMenu.addItem(.sectionHeader(title: "Legacy"))
        edgeSubMenu.addItem(legacySmallItem)
        edgeSubMenu.addItem(legacyMediumItem)
        edgeSubMenu.addItem(legacyLargeItem)
        
        dockLeftItem.isEnabled = true
        dockRightItem.isEnabled = true
        dockBottomItem.isEnabled = true
        legacySmallItem.isEnabled = true
        legacyMediumItem.isEnabled = true
        legacyLargeItem.isEnabled = true
        
        UserDefaults.standard.addObserver(self, forKeyPath: UserDefaults.Keys.DOCK_LEFT, options: [.new, .initial], context: nil)
        UserDefaults.standard.addObserver(self, forKeyPath: UserDefaults.Keys.DOCK_RIGHT, options: [.new, .initial], context: nil)
        UserDefaults.standard.addObserver(self, forKeyPath: UserDefaults.Keys.DOCK_BOTTOM, options: [.new, .initial], context: nil)
        UserDefaults.standard.addObserver(self, forKeyPath: UserDefaults.Keys.LEGACY, options: [.new, .initial], context: nil)
    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: UserDefaults.Keys.DOCK_LEFT)
        UserDefaults.standard.removeObserver(self, forKeyPath: UserDefaults.Keys.DOCK_RIGHT)
        UserDefaults.standard.removeObserver(self, forKeyPath: UserDefaults.Keys.DOCK_BOTTOM)
        UserDefaults.standard.removeObserver(self, forKeyPath: UserDefaults.Keys.LEGACY)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case UserDefaults.Keys.DOCK_LEFT:
            let isEnable = isDockLeftEnabled
            dockLeftItem.state = isEnable ? .on : .off
            dockEdgesCallbacks.forEach { _, callback in
                callback(.left, isEnable)
            }
            break
        case UserDefaults.Keys.DOCK_RIGHT:
            let isEnable = isDockRightEnabled
            dockRightItem.state = isEnable ? .on : .off
            dockEdgesCallbacks.forEach { _, callback in
                callback(.right, isEnable)
            }
            break
        case UserDefaults.Keys.DOCK_BOTTOM:
            let isEnable = isDockBottomEnabled
            dockBottomItem.state = isEnable ? .on : .off
            dockEdgesCallbacks.forEach { _, callback in
                callback(.bottom, isEnable)
            }
            break
        case UserDefaults.Keys.LEGACY:
            let legacyValue = UserDefaults.standard.integer(forKey: UserDefaults.Keys.LEGACY)
            let legacy = onLegacyChanged(legacyValue: legacyValue)
            legacySizeCallbacks.forEach { _, callback in
                callback(legacy)
            }
            break
        case .none:
            break
        case .some(_):
            break
        }
    }
    
    @objc private func onLeftAction() {
        var docked = isDockLeftEnabled
        docked.toggle()
        UserDefaults.standard.setValue(docked, forKey: UserDefaults.Keys.DOCK_LEFT)
    }
    
    @objc private func onRightAction() {
        var docked = isDockRightEnabled
        docked.toggle()
        UserDefaults.standard.setValue(docked, forKey: UserDefaults.Keys.DOCK_RIGHT)
    }
    
    @objc private func onBottomAction() {
        var docked = isDockBottomEnabled
        docked.toggle()
        UserDefaults.standard.setValue(docked, forKey: UserDefaults.Keys.DOCK_BOTTOM)
    }
    
    @objc private func onLegacyAction(_ sender: NSMenuItem) {
        let legacy: Legacy
        switch sender {
        case legacySmallItem:
            legacy = .small
            break
        case legacyMediumItem:
            legacy = .medium
            break
        case legacyLargeItem:
            legacy = .large
            break
        default:
            legacy = .small
            break
        }
        UserDefaults.standard.setValue(legacy.rawValue, forKey: UserDefaults.Keys.LEGACY)
    }
    
    private func onLegacyChanged(legacyValue: Int)-> Legacy {
        if let legacy = Legacy(rawValue: legacyValue) {
            legacySmallItem.state = legacy == .small ? .on : .off
            legacyMediumItem.state = legacy == .medium ? .on : .off
            legacyLargeItem.state = legacy == .large ? .on : .off
            
            return legacy
        }
        
        return .small
    }
    
    // 注册回调
    func registerDockEdgesCallback(_ callback: @escaping DockEdgesCallback)-> UUID {
        let id = UUID()
        dockEdgesCallbacks[id] = callback
        return id
    }
    
    func registerLegacyCallback(_ callback: @escaping LegacyCallback)-> UUID {
        let id = UUID()
        legacySizeCallbacks[id] = callback
        return id
    }
    
    // 取消注册回调
    func unregisterDockEdgesCallback(id: UUID) {
        dockEdgesCallbacks.removeValue(forKey: id)
    }
    
    func unregisterLegacyCallback(id: UUID) {
        legacySizeCallbacks.removeValue(forKey: id)
    }
    
}

extension UserDefaults {
    enum Keys {
        static let DOCK_LEFT = "dock-left", DOCK_RIGHT = "dock-right", DOCK_BOTTOM = "dock-bottom"
        static let LEGACY = "legacy"
    }
}

enum Legacy: Int {
    case small = 16, medium = 32, large = 48
}
