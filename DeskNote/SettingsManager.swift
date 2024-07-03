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
    
    let edgeDockSubMenu: NSMenu
    private let dockLeftItem: NSMenuItem
    private let dockRightItem: NSMenuItem
    private let dockBottomItem: NSMenuItem
    
    var isDockLeftEnabled: Bool {
        return UserDefaults.standard.bool(forKey: UserDefaults.Keys.DOCK_LEFT)
    }
    
    var isDockRightEnabled: Bool {
        return UserDefaults.standard.bool(forKey: UserDefaults.Keys.DOCK_RIGHT)
    }
    
    var isDockBottomEnabled: Bool {
        return UserDefaults.standard.bool(forKey: UserDefaults.Keys.DOCK_BOTTOM)
    }
    
    var snapEdges: [Edge] {
        var edges = [Edge]()
        
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
    
    private override init () {
        edgeDockSubMenu = NSMenu()
        dockLeftItem = NSMenuItem(title: NSLocalizedString("Menu_item_edge_dock_left", comment: ""), action: #selector(onLeftAction), keyEquivalent: "")
        dockRightItem = NSMenuItem(title: NSLocalizedString("Menu_item_edge_dock_right", comment: ""), action: #selector(onRightAction), keyEquivalent: "")
        dockBottomItem = NSMenuItem(title: NSLocalizedString("Menu_item_edge_dock_bottom", comment: ""), action: #selector(onBottomAction), keyEquivalent: "")
        
        super.init()
        
        dockLeftItem.target = self
        dockRightItem.target = self
        dockBottomItem.target = self
        
        dockLeftItem.state = isDockLeftEnabled ? .on : .off
        dockRightItem.state = isDockRightEnabled ? .on : .off
        dockBottomItem.state = isDockBottomEnabled ? .on : .off
        
        edgeDockSubMenu.addItem(dockLeftItem)
        edgeDockSubMenu.addItem(dockRightItem)
        edgeDockSubMenu.addItem(dockBottomItem)
        
        dockLeftItem.isEnabled = true
        dockRightItem.isEnabled = true
        dockBottomItem.isEnabled = true
        
        UserDefaults.standard.addObserver(self, forKeyPath: UserDefaults.Keys.DOCK_LEFT, options: [.new, .initial], context: nil)
        UserDefaults.standard.addObserver(self, forKeyPath: UserDefaults.Keys.DOCK_RIGHT, options: [.new, .initial], context: nil)
        UserDefaults.standard.addObserver(self, forKeyPath: UserDefaults.Keys.DOCK_BOTTOM, options: [.new, .initial], context: nil)
    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: UserDefaults.Keys.DOCK_LEFT)
        UserDefaults.standard.removeObserver(self, forKeyPath: UserDefaults.Keys.DOCK_RIGHT)
        UserDefaults.standard.removeObserver(self, forKeyPath: UserDefaults.Keys.DOCK_BOTTOM)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case UserDefaults.Keys.DOCK_LEFT:
            dockLeftItem.state = isDockLeftEnabled ? .on : .off
            break
        case UserDefaults.Keys.DOCK_RIGHT:
            dockRightItem.state = isDockRightEnabled ? .on : .off
            break
        case UserDefaults.Keys.DOCK_BOTTOM:
            dockBottomItem.state = isDockBottomEnabled ? .on : .off
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
    
}

extension UserDefaults {
    enum Keys {
        static let DOCK_LEFT = "dock-left", DOCK_RIGHT = "dock-right", DOCK_BOTTOM = "dock-bottom"
    }
}
