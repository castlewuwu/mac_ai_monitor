#!/bin/bash

# AI Monitor - 快速修复脚本
# 创建一个最小可工作的 Xcode 项目

echo "🪲 AI Monitor - 创建修复版项目"
echo "================================"

cd "$(dirname "$0")"

# 创建新的项目目录
mkdir -p AI-Monitor-Fixed

# 创建 Package.swift
cat > AI-Monitor-Fixed/Package.swift << 'EOF'
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AI-Monitor",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "AI-Monitor", targets: ["AI-Monitor"])
    ],
    targets: [
        .executableTarget(
            name: "AI-Monitor",
            path: "Sources"
        )
    ]
)
EOF

# 创建源代码目录
mkdir -p AI-Monitor-Fixed/Sources

# 创建 main.swift
cat > AI-Monitor-Fixed/Sources/main.swift << 'EOF'
import AppKit
import SwiftUI

// 简化版监控器
class SimpleMonitor: ObservableObject {
    @Published var cpuUsage: Double = 0
    @Published var memoryUsed: UInt64 = 0
    @Published var memoryTotal: UInt64 = 0
    
    private var timer: Timer?
    
    func start() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.update()
        }
    }
    
    private func update() {
        // CPU
        var cpuInfo: host_cpu_load_info?
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)
        
        withUnsafeMutablePointer(to: &cpuInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        
        if let info = cpuInfo {
            let total = Double(info.cpu_ticks.0 + info.cpu_ticks.1 + info.cpu_ticks.2 + info.cpu_ticks.3)
            let used = Double(info.cpu_ticks.0 + info.cpu_ticks.1 + info.cpu_ticks.2)
            DispatchQueue.main.async {
                self.cpuUsage = (used / total) * 100
            }
        }
        
        // Memory
        var stats = vm_statistics64()
        count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        
        withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        
        let pageSize = UInt64(vm_kernel_page_size)
        let used = UInt64(stats.active_count + stats.wire_count) * pageSize
        
        var total: UInt64 = 0
        var size = MemoryLayout<UInt64>.size
        sysctlbyname("hw.memsize", &total, &size, nil, 0)
        
        DispatchQueue.main.async {
            self.memoryUsed = used
            self.memoryTotal = total
        }
    }
}

// 主视图
struct MonitorView: View {
    @StateObject var monitor = SimpleMonitor()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("AI Monitor")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("CPU: \(String(format: "%.1f", monitor.cpuUsage))%")
                Text("内存: \(monitor.memoryUsed / 1024 / 1024) MB / \(monitor.memoryTotal / 1024 / 1024) MB")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding(40)
        .frame(width: 400, height: 300)
        .onAppear { monitor.start() }
    }
}

// 创建窗口并运行
let app = NSApplication.shared
let window = NSWindow(
    contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
    styleMask: [.titled, .closable],
    backing: .buffered,
    defer: false
)

window.title = "AI Monitor"
window.contentView = NSHostingView(rootView: MonitorView())
window.center()
window.makeKeyAndOrderFront(nil)

app.setActivationPolicy(.regular)
app.run()
EOF

echo ""
echo "✅ 修复版项目已创建在: AI-Monitor-Fixed/"
echo ""
echo "运行方式："
echo "  cd AI-Monitor-Fixed"
echo "  swift run"
echo ""

# 创建启动脚本
cat > AI-Monitor-Fixed/start.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
swift run
EOF

chmod +x AI-Monitor-Fixed/start.sh

echo "或直接运行: ./AI-Monitor-Fixed/start.sh"