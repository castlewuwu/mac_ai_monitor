import SwiftUI

struct ContentView: View {
    @StateObject private var systemMonitor = SystemMonitor()
    @StateObject private var aiAppMonitor = AIAppMonitor()
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HeaderView()
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 系统监控区域
                    SystemMonitorSection(systemMonitor: systemMonitor)
                    
                    Divider()
                    
                    // AI 应用监控区域
                    AIAppSection(aiAppMonitor: aiAppMonitor)
                    
                    Divider()
                    
                    // 使用说明
                    InstructionsView()
                }
                .padding(20)
            }
        }
        .frame(minWidth: 450, minHeight: 600)
        .onAppear {
            systemMonitor.startMonitoring()
            aiAppMonitor.startMonitoring()
        }
        .onDisappear {
            systemMonitor.stopMonitoring()
            aiAppMonitor.stopMonitoring()
        }
    }
}

// MARK: - Header View

struct HeaderView: View {
    var body: some View {
        HStack {
            Image(systemName: "cpu.fill")
                .font(.title)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("AI Monitor")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("系统资源与AI应用监控")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 状态指示器
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                Text("监控中")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(20)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - System Monitor Section

struct SystemMonitorSection: View {
    @ObservedObject var systemMonitor: SystemMonitor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "系统监控", icon: "chart.bar.fill")
            
            // CPU
            MetricCard(
                label: "CPU 使用率",
                value: String(format: "%.1f%%", systemMonitor.cpuUsage),
                percentage: systemMonitor.cpuUsage,
                color: colorForPercentage(systemMonitor.cpuUsage),
                icon: "cpu.fill"
            )
            
            // 内存
            MetricCard(
                label: "内存使用",
                value: "\(SystemMonitor.formatBytes(systemMonitor.memoryUsed)) / \(SystemMonitor.formatBytes(systemMonitor.memoryTotal))",
                percentage: systemMonitor.memoryPercentage,
                color: colorForPercentage(systemMonitor.memoryPercentage),
                icon: "memorychip.fill"
            )
            
            // 网络
            NetworkCard(
                upload: SystemMonitor.formatBytes(systemMonitor.uploadSpeed),
                download: SystemMonitor.formatBytes(systemMonitor.downloadSpeed)
            )
        }
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

// MARK: - AI App Section

struct AIAppSection: View {
    @ObservedObject var aiAppMonitor: AIAppMonitor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "AI 应用", icon: "brain.head.profile")
            
            if aiAppMonitor.detectedApps.isEmpty {
                EmptyAppsView()
            } else {
                ForEach(aiAppMonitor.detectedApps) { app in
                    AIAppCard(app: app)
                }
            }
        }
    }
}

// MARK: - Component Views

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
        }
    }
}

struct MetricCard: View {
    let label: String
    let value: String
    let percentage: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(value)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)
            }
            
            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color, color.opacity(0.7)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * min(percentage / 100.0, 1.0), height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct NetworkCard: View {
    let upload: String
    let download: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "network")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("网络流量")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            HStack(spacing: 24) {
                // 上传
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                        Text("上传")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text(upload)
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.primary)
                }
                
                Divider()
                    .frame(height: 40)
                
                // 下载
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.blue)
                        Text("下载")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text(download)
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct AIAppCard: View {
    let app: AIAppInfo
    
    var body: some View {
        HStack {
            // 状态指示器
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("PID: \(app.pid)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(app.status.rawValue)
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(statusColor)
                .cornerRadius(8)
        }
        .padding(14)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private var statusColor: Color {
        switch app.status {
        case .idle: return .gray
        case .running: return .blue
        case .inference: return .green
        case .error: return .red
        case .unknown: return .gray
        }
    }
}

struct EmptyAppsView: View {
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
                
                Text("未检测到运行中的 AI 应用")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("支持检测：Ollama、LM Studio、ChatGPT 等")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(30)
            Spacer()
        }
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct InstructionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("使用说明")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                InstructionRow(icon: "arrow.clockwise", text: "数据每秒自动更新")
                InstructionRow(icon: "paintpalette", text: "颜色指示：绿色=正常，橙色=中等，红色=高负载")
                InstructionRow(icon: "app.connected.to.app.below.fill", text: "自动检测常见的 AI 应用")
                InstructionRow(icon: "bell.fill", text: "高负载时会发送系统通知")
            }
        }
        .padding(16)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

struct InstructionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.caption)
            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}