//
//  ContentView.swift
//  AI Monitor
//
//  主视图（菜单栏下拉面板）
//

import SwiftUI

struct ContentView: View {
    
    // 从外部传入的观察对象
    @ObservedObject var systemMonitor: SystemMonitor
    @ObservedObject var aiAppMonitor: AIAppMonitor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 系统监控区域
            SystemMetricsView(
                cpuUsage: systemMonitor.cpuUsage,
                memoryUsed: systemMonitor.memoryUsed,
                memoryTotal: systemMonitor.memoryTotal,
                memoryPercentage: systemMonitor.memoryPercentage,
                uploadSpeed: systemMonitor.uploadSpeed,
                downloadSpeed: systemMonitor.downloadSpeed
            )
            
            Divider()
            
            // AI 应用监控区域
            AIAppsView(apps: aiAppMonitor.detectedApps)
            
            Divider()
            
            // 底部操作按钮
            HStack {
                Button("设置") {
                    // TODO: 打开设置窗口
                }
                
                Spacer()
                
                Button("退出") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .padding()
        .frame(width: 320)
    }
}

// MARK: - System Metrics View

struct SystemMetricsView: View {
    let cpuUsage: Double
    let memoryUsed: UInt64
    let memoryTotal: UInt64
    let memoryPercentage: Double
    let uploadSpeed: UInt64
    let downloadSpeed: UInt64
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("系统监控")
                .font(.headline)
                .foregroundColor(.primary)
            
            // CPU 使用率
            MetricRow(
                label: "CPU",
                value: String(format: "%.1f%%", cpuUsage),
                percentage: cpuUsage,
                color: colorForPercentage(cpuUsage)
            )
            
            // 内存使用率
            MetricRow(
                label: "内存",
                value: "\(SystemMonitor.formatBytes(memoryUsed)) / \(SystemMonitor.formatBytes(memoryTotal))",
                percentage: memoryPercentage,
                color: colorForPercentage(memoryPercentage)
            )
            
            // 网络速度
            HStack {
                Text("网络")
                    .frame(width: 50, alignment: .leading)
                
                HStack(spacing: 16) {
                    Label {
                        Text(SystemMonitor.formatSpeed(uploadSpeed))
                            .font(.system(.body, design: .monospaced))
                    } icon: {
                        Image(systemName: "arrow.up")
                            .foregroundColor(.green)
                    }
                    
                    Label {
                        Text(SystemMonitor.formatSpeed(downloadSpeed))
                            .font(.system(.body, design: .monospaced))
                    } icon: {
                        Image(systemName: "arrow.down")
                            .foregroundColor(.blue)
                    }
                }
            }
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

// MARK: - Metric Row

struct MetricRow: View {
    let label: String
    let value: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        HStack(alignment: .center) {
            Text(label)
                .frame(width: 50, alignment: .leading)
            
            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * (percentage / 100.0))
                }
            }
            .frame(height: 8)
            
            Text(value)
                .font(.system(.body, design: .monospaced))
                .frame(width: 100, alignment: .trailing)
        }
    }
}

// MARK: - AI Apps View

struct AIAppsView: View {
    let apps: [AIAppInfo]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AI 应用")
                .font(.headline)
                .foregroundColor(.primary)
            
            if apps.isEmpty {
                Text("未检测到运行中的 AI 应用")
                    .foregroundColor(.secondary)
                    .font(.caption)
            } else {
                ForEach(apps) { app in
                    AIAppRow(app: app)
                }
            }
        }
    }
}

// MARK: - AI App Row

struct AIAppRow: View {
    let app: AIAppInfo
    
    var body: some View {
        HStack(alignment: .top) {
            // 状态指示器
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
                .padding(.top, 3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.body)
                    .fontWeight(.medium)
                
                HStack(spacing: 12) {
                    Label {
                        Text(String(format: "CPU %.1f%%", app.resourceUsage.cpuUsage))
                            .font(.caption)
                    } icon: {
                        Image(systemName: "cpu")
                            .font(.caption)
                    }
                    
                    Label {
                        Text(SystemMonitor.formatBytes(app.resourceUsage.memoryUsed))
                            .font(.caption)
                    } icon: {
                        Image(systemName: "memorychip")
                            .font(.caption)
                    }
                }
                .foregroundColor(.secondary)
                
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var statusColor: Color {
        switch app.status {
        case .idle:
            return .gray
        case .running:
            return .blue
        case .loading:
            return .orange
        case .inference:
            return .green
        case .error:
            return .red
        case .unknown:
            return .gray
        }
    }
    
    private var statusText: String {
        switch app.status {
        case .idle:
            return "空闲中"
        case .running:
            return "运行中"
        case .loading:
            return "加载模型..."
        case .inference:
            return "推理中"
        case .error:
            return "发生错误"
        case .unknown:
            return "状态未知"
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}