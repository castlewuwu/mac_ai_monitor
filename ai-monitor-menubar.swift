// AI Monitor - 菜单栏常驻版
// 直接运行：swift ai-monitor-menubar.swift

import AppKit
import SwiftUI

// 监控数据
class Monitor: ObservableObject {
    @Published var cpu: Double = 0
    @Published var memoryPercent: Double = 0
    @Published var memoryUsed: String = ""
    
    private var timer: Timer?
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.update()
        }
    }
    
    private func update() {
        // CPU
        var info: host_cpu_load_info?
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)
        
        withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        
        if let i = info {
            let total = Double(i.cpu_ticks.0 + i.cpu_ticks.1 + i.cpu_ticks.2 + i.cpu_ticks.3)
            let used = Double(i.cpu_ticks.0 + i.cpu_ticks.1 + i.cpu_ticks.2)
            DispatchQueue.main.async { self.cpu = (used / total) * 100 }
        }
        
        // 内存
        var stats = vm_statistics64()
        count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        
        withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        
        let used = UInt64(stats.active_count + stats.wire_count) * UInt64(vm_kernel_page_size)
        
        var total: UInt64 = 0
        var size = MemoryLayout<UInt64>.size
        sysctlbyname("hw.memsize", &total, &size, nil, 0)
        
        let percent = Double(used) / Double(total) * 100.0
        let usedGB = Double(used) / 1024.0 / 1024.0 / 1024.0
        
        DispatchQueue.main.async {
            self.memoryPercent = percent
            self.memoryUsed = String(format: "%.1f GB", usedGB)
        }
    }
}

// 菜单栏视图
struct MenuBarView: View {
    @ObservedObject var monitor: Monitor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            HStack {
                Image(systemName: "cpu.fill")
                    .foregroundColor(.blue)
                Text("AI Monitor")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
            }
            
            Divider()
            
            // CPU
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("CPU")
                        .fontWeight(.medium)
                    Spacer()
                    Text(String(format: "%.1f%%", monitor.cpu))
                        .fontWeight(.semibold)
                        .foregroundColor(colorFor(monitor.cpu))
                }
                ProgressView(value: monitor.cpu / 100.0)
                    .tint(colorFor(monitor.cpu))
            }
            
            // 内存
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("内存")
                        .fontWeight(.medium)
                    Spacer()
                    Text(String(format: "%.1f%% (%@)", monitor.memoryPercent, monitor.memoryUsed))
                        .fontWeight(.semibold)
                        .foregroundColor(colorFor(monitor.memoryPercent))
                }
                ProgressView(value: monitor.memoryPercent / 100.0)
                    .tint(colorFor(monitor.memoryPercent))
            }
            
            Divider()
            
            // 说明
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.secondary)
                    .font(.caption)
                Text("数据每秒自动更新")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(width: 280)
    }
    
    private func colorFor(_ value: Double) -> Color {
        if value < 50 { return .green }
        if value < 80 { return .orange }
        return .red
    }
}

// 应用委托
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var monitor: Monitor!
    private var timer: Timer!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 创建监控器
        monitor = Monitor()
        monitor.start()
        
        // 不显示在 Dock
        NSApp.setActivationPolicy(.accessory)
        
        // 创建状态栏项
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "cpu", accessibilityDescription: "AI Monitor")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // 创建弹出视图
        popover = NSPopover()
        popover.contentSize = NSSize(width: 280, height: 240)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: MenuBarView(monitor: monitor))
        
        // 定时更新状态栏显示
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateStatusBar()
        }
    }
    
    private func updateStatusBar() {
        if let button = statusItem.button {
            let cpu = String(format: "%.0f%%", monitor.cpu)
            button.title = cpu
            button.toolTip = "CPU: \(cpu) | 内存: \(String(format: "%.0f%%", monitor.memoryPercent))"
        }
    }
    
    @objc private func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
}

// 运行应用
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()