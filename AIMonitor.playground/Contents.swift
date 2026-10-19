import AppKit
import SwiftUI
import Combine
import IOKit
import Darwin

// MARK: - 系统监控服务

class SystemMonitor: ObservableObject {
    @Published var cpuUsage: Double = 0.0
    @Published var memoryUsed: UInt64 = 0
    @Published var memoryTotal: UInt64 = 0
    @Published var memoryPercentage: Double = 0.0
    @Published var uploadSpeed: UInt64 = 0
    @Published var downloadSpeed: UInt64 = 0
    
    private var timer: Timer?
    private var previousUpload: UInt64 = 0
    private var previousDownload: UInt64 = 0
    private var previousTime: Date = Date()
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateMetrics()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer?.nil
    }
    
    private func updateMetrics() {
        updateCPUUsage()
        updateMemoryUsage()
        updateNetworkSpeed()
    }
    
    private func updateCPUUsage() {
        var cpuInfo: host_cpu_load_info?
        var count = mach_msg_type_number_t(
            MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size
        )
        
        let result = withUnsafeMutablePointer(to: &cpuInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        
        if result == KERN_SUCCESS, let info = cpuInfo {
            let user = Double(info.cpu_ticks.0)
            let system = Double(info.cpu_ticks.1)
            let idle = Double(info.cpu_ticks.2)
            let nice = Double(info.cpu_ticks.3)
            
            let total = user + system + idle + nice
            let used = user + system + nice
            
            DispatchQueue.main.async {
                self.cpuUsage = (used / total) * 100.0
            }
        }
    }
    
    private func updateMemoryUsage() {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size
        )
        
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let pageSize = UInt64(vm_kernel_page_size)
            let used = UInt64(stats.active_count + stats.wire_count) * pageSize
            
            var totalBytes: UInt64 = 0
            var size = MemoryLayout<UInt64>.size
            sysctlbyname("hw.memsize", &totalBytes, &size, nil, 0)
            
            DispatchQueue.main.async {
                self.memoryUsed = used
                self.memoryTotal = totalBytes
                self.memoryPercentage = totalBytes > 0 ? Double(used) / Double(totalBytes) * 100.0 : 0.0
            }
        }
    }
    
    private func updateNetworkSpeed() {
        var interfaceAddresses: UnsafeMutablePointer<ifaddrs>?
        getifaddrs(&interfaceAddresses)
        
        var currentUpload: UInt64 = 0
        var currentDownload: UInt64 = 0
        
        var pointer = interfaceAddresses
        while pointer != nil {
            let addr = pointer!.pointee
            if addr.ifa_addr.pointee.sa_family == UInt8(AF_LINK) {
                if let data = addr.ifa_data {
                    let networkData = data.assumingMemoryBound(to: if_data.self).pointee
                    currentUpload += UInt64(networkData.ifi_obytes)
                    currentDownload += UInt64(networkData.ifi_ibytes)
                }
            }
            pointer = addr.ifa_next
        }
        
        freeifaddrs(interfaceAddresses)
        
        let currentTime = Date()
        let elapsed = currentTime.timeIntervalSince(previousTime)
        
        if elapsed > 0 {
            let uploadDelta = currentUpload > previousUpload ? currentUpload - previousUpload : 0
            let downloadDelta = currentDownload > previousDownload ? currentDownload - previousDownload : 0
            
            DispatchQueue.main.async {
                self.uploadSpeed = UInt64(Double(uploadDelta) / elapsed)
                self.downloadSpeed = UInt64(Double(downloadDelta) / elapsed)
            }
        }
        
        previousUpload = currentUpload
        previousDownload = currentDownload
        previousTime = currentTime
    }
    
    static func formatBytes(_ bytes: UInt64) -> String {
        let units = ["B", "KB", "MB", "GB", "TB"]
        var value = Double(bytes)
        var unitIndex = 0
        
        while value >= 1024 && unitIndex < units.count - 1 {
            value /= 1024
            unitIndex += 1
        }
        
        return String(format: "%.1f %@", value, units[unitIndex])
    }
    
    static func formatSpeed(_ bytesPerSecond: UInt64) -> String {
        return formatBytes(bytesPerSecond) + "/s"
    }
}

// MARK: - AI 应用监控

enum AIAppStatus {
    case idle, running, inference, error, unknown
}

struct AIAppInfo: Identifiable {
    let id: String
    let name: String
    let bundleId: String
    let pid: Int32
    var cpuUsage: Double
    var memoryUsed: UInt64
    var status: AIAppStatus
}

class AIAppMonitor: ObservableObject {
    @Published var detectedApps: [AIAppInfo] = []
    
    private var timer: Timer?
    
    private let knownAIApps: [String: String] = [
        "com.ollama.ollama": "Ollama",
        "com.lmstudio.lmstudio": "LM Studio",
        "com.openai.chatgpt": "ChatGPT",
        "com.anthropic.claude": "Claude"
    ]
    
    func startMonitoring() {
        scanForAIApps()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.scanForAIApps()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func scanForAIApps() {
        let runningApps = NSWorkspace.shared.runningApplications
        var detected: [AIAppInfo] = []
        
        for app in runningApps {
            guard let bundleId = app.bundleIdentifier,
                  let appName = knownAIApps[bundleId] else { continue }
            
            let appInfo = AIAppInfo(
                id: bundleId,
                name: appName,
                bundleId: bundleId,
                pid: app.processIdentifier,
                cpuUsage: 0,
                memoryUsed: 0,
                status: .running
            )
            detected.append(appInfo)
        }
        
        DispatchQueue.main.async {
            self.detectedApps = detected
        }
    }
}

// MARK: - 主视图

struct ContentView: View {
    @ObservedObject var systemMonitor: SystemMonitor
    @ObservedObject var aiAppMonitor: AIAppMonitor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack {
                Image(systemName: "cpu")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("AI Monitor")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text("实时监控")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 8)
            
            // CPU 监控
            MetricRow(
                label: "CPU",
                value: String(format: "%.1f%%", systemMonitor.cpuUsage),
                percentage: systemMonitor.cpuUsage,
                color: colorForPercentage(systemMonitor.cpuUsage)
            )
            
            // 内存监控
            MetricRow(
                label: "内存",
                value: "\(SystemMonitor.formatBytes(systemMonitor.memoryUsed)) / \(SystemMonitor.formatBytes(systemMonitor.memoryTotal))",
                percentage: systemMonitor.memoryPercentage,
                color: colorForPercentage(systemMonitor.memoryPercentage)
            )
            
            // 网络监控
            VStack(alignment: .leading, spacing: 8) {
                Text("网络速度")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 20) {
                    Label {
                        Text(SystemMonitor.formatSpeed(systemMonitor.uploadSpeed))
                            .font(.system(.body, design: .monospaced))
                    } icon: {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                    }
                    
                    Label {
                        Text(SystemMonitor.formatSpeed(systemMonitor.downloadSpeed))
                            .font(.system(.body, design: .monospaced))
                    } icon: {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Divider()
            
            // AI 应用监控
            VStack(alignment: .leading, spacing: 8) {
                Text("AI 应用")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if aiAppMonitor.detectedApps.isEmpty {
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.secondary)
                        Text("未检测到运行中的 AI 应用")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                } else {
                    ForEach(aiAppMonitor.detectedApps) { app in
                        HStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text(app.name)
                                .font(.body)
                            Spacer()
                            Text("运行中")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            // 说明文字
            VStack(alignment: .leading, spacing: 4) {
                Text("💡 使用说明")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("• 数据每秒自动更新")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("• 绿色 = 正常，黄色 = 中等，红色 = 高负载")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
        }
        .padding(20)
        .frame(width: 400, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 10)
    }
    
    private func colorForPercentage(_ percentage: Double) -> Color {
        if percentage < 50 {
            return .green
        } else if percentage < 80 {
            return .orange
        } else {
            return .red
        }
    }
}

struct MetricRow: View {
    let label: String
    let value: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.headline)
                Spacer()
                Text(value)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.medium)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * min(percentage / 100.0, 1.0))
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - 启动监控器

let systemMonitor = SystemMonitor()
let aiAppMonitor = AIAppMonitor()

systemMonitor.startMonitoring()
aiAppMonitor.startMonitoring()

// 显示界面
let contentView = ContentView(
    systemMonitor: systemMonitor,
    aiAppMonitor: aiAppMonitor
)

// 创建窗口
let window = NSWindow(
    contentRect: NSRect(x: 0, y: 0, width: 400, height: 500),
    styleMask: [.titled, .closable, .miniaturizable],
    backing: .buffered,
    defer: false
)

window.title = "AI Monitor - 系统监控"
window.contentView = NSHostingView(rootView: contentView)
window.center()
window.makeKeyAndOrderFront(nil)
window.level = .floating

// 设置应用为普通应用（显示在 Dock）
NSApp.setActivationPolicy(.regular)
NSApp.activate(ignoringOtherApps: true)

print("✅ AI Monitor 已启动")
print("💡 关闭窗口即可退出应用")