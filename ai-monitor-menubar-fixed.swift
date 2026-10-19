// AI Monitor - 菜单栏常驻版（修复 CPU 计算问题）
// 直接运行：swift ai-monitor-menubar-fixed.swift

import AppKit
import SwiftUI

// 监控数据
class Monitor: ObservableObject {
    @Published var cpu: Double = 0
    @Published var memoryPercent: Double = 0
    @Published var memoryUsed: String = ""
    
    private var timer: Timer?
    private var previousTicks: (user: UInt64, system: UInt64, idle: UInt64, nice: UInt64)?
    
    func start() {
        // 先获取初始值
        update()
        
        // 然后启动定时器
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.update()
        }
        
        // 确保定时器在主运行循环中
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func update() {
        updateCPU()
        updateMemory()
    }
    
    private func updateCPU() {
        var cpuInfo = host_cpu_load_info()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)
        
        let result = withUnsafeMutablePointer(to: &cpuInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else { return }
        
        let user = UInt64(cpuInfo.cpu_ticks.0)
        let system = UInt64(cpuInfo.cpu_ticks.1)
        let idle = UInt64(cpuInfo.cpu_ticks.2)
        let nice = UInt64(cpuInfo.cpu_ticks.3)
        
        // 计算差值
        if let prev = previousTicks {
            let userDelta = Double(user - prev.user)
            let systemDelta = Double(system - prev.system)
            let idleDelta = Double(idle - prev.idle)
            let niceDelta = Double(nice - prev.nice)
            
            let totalDelta = userDelta + systemDelta + idleDelta + niceDelta
            let usedDelta = userDelta + systemDelta + niceDelta
            
            if totalDelta > 0 {
                let usage = (usedDelta / totalDelta) * 100.0
                DispatchQueue.main.async {
                    self.cpu = usage
                }
            }
        }
        
        // 保存当前值
        previousTicks = (user: user, system: system, idle: idle, nice: nice)
    }
    
    private func updateMemory() {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else { return }
        
        let pageSize = UInt64(vm_kernel_page_size)
        let used = UInt64(stats.active_count + stats.wire_count) * pageSize
        
        var total: UInt64 = 0
        var size = MemoryLayout<UInt64>.size
        sysctlbyname("hw.memsize", &total, &size, nil, 0)
        
        let percent = total > 0 ? Double(used) / Double(total) * 100.0 : 0
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
    private var statusTimer: Timer!
    
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
        statusTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateStatusBar()
        }
        RunLoop.main.add(statusTimer, forMode: .common)
        
        // 立即更新一次
        updateStatusBar()
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