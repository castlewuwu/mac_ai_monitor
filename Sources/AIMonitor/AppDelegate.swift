//
//  AppDelegate.swift
//  AI Monitor
//
//  应用委托
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Properties
    
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var eventMonitor: EventMonitor?
    
    // 系统监控器（应用级别，整个应用生命周期）
    private let systemMonitor = SystemMonitor()
    private let aiAppMonitor = AIAppMonitor()
    private let alertEngine = AlertEngine.shared
    
    // MARK: - Application Lifecycle
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 设置为菜单栏应用（不显示在 Dock）
        NSApp.setActivationPolicy(.accessory)
        
        // 创建状态栏项
        createStatusItem()
        
        // 创建弹出窗口
        createPopover()
        
        // 设置事件监控器（点击外部区域关闭弹出窗口）
        eventMonitor = EventMonitor { [weak self] in
            self?.closePopover()
        }
        
        // 配置并启动监控
        systemMonitor.startMonitoring()
        aiAppMonitor.startMonitoring()
        
        // 配置 AlertEngine
        alertEngine.setMonitors(system: systemMonitor, aiApp: aiAppMonitor)
        alertEngine.startMonitoring()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // 停止监控
        systemMonitor.stopMonitoring()
        aiAppMonitor.stopMonitoring()
    }
    
    // MARK: - Status Bar
    
    private func createStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "cpu", accessibilityDescription: "AI Monitor")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // 更新状态栏显示
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateStatusItem()
        }
    }
    
    @objc private func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                closePopover()
            } else {
                showPopover(at: button)
            }
        }
    }
    
    private func updateStatusItem() {
        let cpu = String(format: "%.0f%%", systemMonitor.cpuUsage)
        
        if let button = statusItem?.button {
            // 根据使用率设置颜色
            let color: NSColor
            if systemMonitor.cpuUsage < 50 {
                color = .systemGreen
            } else if systemMonitor.cpuUsage < 80 {
                color = .systemOrange
            } else {
                color = .systemRed
            }
            
            // 更新按钮标题和工具提示
            button.title = cpu
            button.toolTip = "CPU: \(cpu) | 内存: \(String(format: "%.0f%%", systemMonitor.memoryPercentage))"
        }
    }
    
    // MARK: - Popover
    
    private func createPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 340, height: 500)
        popover?.behavior = .transient
        
        // 创建 ContentView，传入监控器实例
        let contentView = ContentView(
            systemMonitor: systemMonitor,
            aiAppMonitor: aiAppMonitor
        )
        
        popover?.contentViewController = NSHostingController(rootView: contentView)
    }
    
    private func showPopover(at sender: NSView) {
        eventMonitor?.start()
        popover?.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
    }
    
    private func closePopover() {
        popover?.performClose(nil)
        eventMonitor?.stop()
    }
}

// MARK: - Event Monitor

class EventMonitor {
    private var monitor: Any?
    private let handler: () -> Void
    
    init(handler: @escaping () -> Void) {
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    func start() {
        // 监听全局点击事件
        monitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.handler()
        }
    }
    
    func stop() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}