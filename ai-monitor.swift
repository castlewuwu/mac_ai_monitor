// AI Monitor - 超简版
// 直接运行：swift ai-monitor.swift

import AppKit
import SwiftUI

// 监控数据
class Monitor: ObservableObject {
    @Published var cpu: Double = 0
    @Published var memory: String = ""
    
    func start() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
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
            let usedMB = used / 1024 / 1024
            
            var total: UInt64 = 0
            var size = MemoryLayout<UInt64>.size
            sysctlbyname("hw.memsize", &total, &size, nil, 0)
            let totalMB = total / 1024 / 1024
            
            DispatchQueue.main.async {
                self.memory = "\(usedMB) MB / \(totalMB) MB"
            }
        }
    }
}

// 界面
struct ContentView: View {
    @StateObject var monitor = Monitor()
    
    var body: some View {
        VStack(spacing: 30) {
            Text("🪲 AI Monitor")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("CPU:")
                        .frame(width: 60, alignment: .leading)
                    Text(String(format: "%.1f%%", monitor.cpu))
                        .fontWeight(.semibold)
                        .foregroundColor(monitor.cpu < 50 ? .green : (monitor.cpu < 80 ? .orange : .red))
                }
                
                HStack {
                    Text("内存:")
                        .frame(width: 60, alignment: .leading)
                    Text(monitor.memory)
                        .fontWeight(.semibold)
                }
            }
            .font(.title3)
            .padding(30)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            
            Text("数据每秒自动更新")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(50)
        .frame(width: 500, height: 400)
        .onAppear { monitor.start() }
    }
}

// 运行
let app = NSApplication.shared
let window = NSWindow(
    contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
    styleMask: [.titled, .closable, .miniaturizable],
    backing: .buffered,
    defer: false
)

window.title = "AI Monitor"
window.contentView = NSHostingView(rootView: ContentView())
window.center()
window.makeKeyAndOrderFront(nil)

app.setActivationPolicy(.regular)
app.run()