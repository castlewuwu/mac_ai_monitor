//
//  AlertEngine.swift
//  AI Monitor
//
//  智能提醒引擎
//

import Foundation
import Combine

/// 提醒条件
struct AlertCondition {
    let id: String
    let name: String
    let checkInterval: TimeInterval
    let condition: () -> Bool
    let action: () -> Void
}

/// 智能提醒引擎
class AlertEngine: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = AlertEngine()
    
    // MARK: - Published Properties
    
    @Published var activeAlerts: [AlertInfo] = []
    @Published var alertHistory: [AlertInfo] = []
    
    // MARK: - Private Properties
    
    // 监控器引用（由外部设置）
    private weak var systemMonitor: SystemMonitor?
    private weak var aiAppMonitor: AIAppMonitor?
    private let notificationManager = NotificationManager.shared
    
    private var timer: Timer?
    private var alertConditions: [AlertCondition] = []
    
    // 阈值配置
    private var config = AlertConfig()
    
    // MARK: - Initialization
    
    private init() {
        setupAlertConditions()
    }
    
    // MARK: - Configuration
    
    /// 设置监控器引用
    func setMonitors(system: SystemMonitor, aiApp: AIAppMonitor) {
        self.systemMonitor = system
        self.aiAppMonitor = aiApp
    }
    
    // MARK: - Public Methods
    
    /// 开始监控
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: config.checkInterval, repeats: true) { [weak self] _ in
            self?.checkAllConditions()
        }
    }
    
    /// 停止监控
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    /// 更新配置
    func updateConfig(_ newConfig: AlertConfig) {
        config = newConfig
    }
    
    // MARK: - Private Methods
    
    /// 设置提醒条件
    private func setupAlertConditions() {
        alertConditions = [
            // 系统内存不足
            AlertCondition(
                id: "memory-low",
                name: "系统内存不足",
                checkInterval: 5.0
            ) { [weak self] in
                guard let self = self,
                      let systemMonitor = self.systemMonitor else { return false }
                return systemMonitor.memoryPercentage > self.config.memoryWarningThreshold
            } action: { [weak self] in
                guard let self = self,
                      let systemMonitor = self.systemMonitor else { return }
                self.triggerAlert(
                    type: .systemMemoryLow,
                    message: String(
                        format: "系统内存使用率 %.1f%%，已超过阈值 %.0f%%",
                        systemMonitor.memoryPercentage,
                        self.config.memoryWarningThreshold
                    )
                )
            },
            
            // CPU 异常占用
            AlertCondition(
                id: "cpu-high",
                name: "CPU 异常占用",
                checkInterval: 10.0
            ) { [weak self] in
                guard let self = self,
                      let systemMonitor = self.systemMonitor else { return false }
                return systemMonitor.cpuUsage > self.config.cpuWarningThreshold
            } action: { [weak self] in
                guard let self = self,
                      let systemMonitor = self.systemMonitor else { return }
                self.triggerAlert(
                    type: .cpuUsageHigh,
                    message: String(
                        format: "CPU 使用率 %.1f%%，持续高占用",
                        systemMonitor.cpuUsage
                    )
                )
            },
            
            // AI 应用异常
            AlertCondition(
                id: "ai-app-error",
                name: "AI 应用异常",
                checkInterval: 5.0
            ) { [weak self] in
                guard let self = self,
                      let aiAppMonitor = self.aiAppMonitor else { return false }
                return aiAppMonitor.detectedApps.contains { $0.status == .error }
            } action: { [weak self] in
                guard let self = self,
                      let aiAppMonitor = self.aiAppMonitor else { return }
                let errorApps = aiAppMonitor.detectedApps.filter { $0.status == .error }
                for app in errorApps {
                    self.triggerAlert(
                        type: .modelLoadFailed,
                        message: "\(app.name) 发生错误，需要人工介入"
                    )
                }
            },
            
            // GPU 内存不足（如果检测到）
            AlertCondition(
                id: "gpu-memory-low",
                name: "GPU 内存不足",
                checkInterval: 5.0
            ) { [weak self] in
                // TODO: 实现 GPU 内存检测
                return false
            } action: { [weak self] in
                self?.triggerAlert(
                    type: .gpuMemoryLow,
                    message: "GPU 内存不足，建议关闭部分应用"
                )
            }
        ]
    }
    
    /// 检查所有条件
    private func checkAllConditions() {
        guard systemMonitor != nil && aiAppMonitor != nil else {
            // 监控器未设置，跳过检查
            return
        }
        
        for condition in alertConditions {
            if condition.condition() {
                condition.action()
            }
        }
        
        // 检查 AI 应用特定事件
        checkAIAppEvents()
    }
    
    /// 检查 AI 应用特定事件
    private func checkAIAppEvents() {
        guard let aiAppMonitor = aiAppMonitor else { return }
        
        for app in aiAppMonitor.detectedApps {
            // 检查进程状态变化
            if let lastStatus = getLastStatus(for: app.id), lastStatus != app.status {
                handleStatusChange(app: app, from: lastStatus, to: app.status)
            }
            
            // 更新状态记录
            updateLastStatus(for: app.id, status: app.status)
            
            // 检查是否需要人工介入
            if needsHumanIntervention(app: app) {
                triggerAlert(
                    type: .modelLoadFailed,
                    message: "\(app.name) 需要人工介入：\(getAppInterventionReason(app: app))"
                )
            }
        }
    }
    
    /// 获取上次状态
    private func getLastStatus(for appId: String) -> AIAppStatus? {
        let key = "lastStatus_\(appId)"
        if let statusString = UserDefaults.standard.string(forKey: key),
           let status = AIAppStatus.fromString(statusString) {
            return status
        }
        return nil
    }
    
    /// 更新状态记录
    private func updateLastStatus(for appId: String, status: AIAppStatus) {
        let key = "lastStatus_\(appId)"
        UserDefaults.standard.set(status.toString(), forKey: key)
    }
    
    /// 处理状态变化
    private func handleStatusChange(app: AIAppInfo, from: AIAppStatus, to: AIAppStatus) {
        switch to {
        case .idle:
            if from == .inference {
                // 推理完成
                triggerAlert(
                    type: .inferenceComplete,
                    message: "\(app.name) 推理任务已完成"
                )
            }
            
        case .error:
            // 发生错误
            triggerAlert(
                type: .modelLoadFailed,
                message: "\(app.name) 发生错误"
            )
            
        default:
            break
        }
    }
    
    /// 判断是否需要人工介入
    private func needsHumanIntervention(app: AIAppInfo) -> Bool {
        switch app.status {
        case .error:
            return true
        case .loading:
            // 如果加载时间过长，需要介入
            // TODO: 实现加载时间检测
            return false
        default:
            return false
        }
    }
    
    /// 获取需要介入的原因
    private func getAppInterventionReason(app: AIAppInfo) -> String {
        switch app.status {
        case .error:
            return "应用发生错误"
        case .loading:
            return "模型加载时间过长"
        default:
            return "未知原因"
        }
    }
    
    /// 触发提醒
    private func triggerAlert(type: NotificationType, message: String) {
        let alertInfo = AlertInfo(
            id: UUID().uuidString,
            type: type,
            message: message,
            timestamp: Date()
        )
        
        DispatchQueue.main.async {
            self.activeAlerts.append(alertInfo)
            self.alertHistory.append(alertInfo)
        }
        
        // 发送系统通知
        notificationManager.sendNotification(type: type, body: message)
    }
}

// MARK: - Supporting Types

/// 提醒配置
struct AlertConfig {
    var checkInterval: TimeInterval = 5.0
    var memoryWarningThreshold: Double = 90.0
    var cpuWarningThreshold: Double = 95.0
    var gpuWarningThreshold: Double = 90.0
}

/// 提醒信息
struct AlertInfo: Identifiable {
    let id: String
    let type: NotificationType
    let message: String
    let timestamp: Date
    var isRead: Bool = false
}

// MARK: - AIAppStatus Extension

extension AIAppStatus {
    func toString() -> String {
        switch self {
        case .idle: return "idle"
        case .running: return "running"
        case .loading: return "loading"
        case .inference: return "inference"
        case .error: return "error"
        case .unknown: return "unknown"
        }
    }
    
    static func fromString(_ string: String) -> AIAppStatus? {
        switch string {
        case "idle": return .idle
        case "running": return .running
        case "loading": return .loading
        case "inference": return .inference
        case "error": return .error
        case "unknown": return .unknown
        default: return nil
        }
    }
}