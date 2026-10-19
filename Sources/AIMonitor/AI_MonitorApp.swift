//
//  AI_MonitorApp.swift
//  AI Monitor
//
//  应用入口
//

import SwiftUI

@main
struct AI_MonitorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // 菜单栏应用不需要窗口
        Settings {
            EmptyView()
        }
    }
}