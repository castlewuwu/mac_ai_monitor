//
//  NotificationManager.swift
//  AI Monitor
//
//  系统通知管理
//

import Foundation
import UserNotifications

/// 通知类型
enum NotificationType {
    case modelDownloadComplete
    case gpuMemoryLow
    case systemMemoryLow
    case inferenceComplete
    case modelLoadFailed
    case cpuUsageHigh
    
    var title: String {
        switch self {
        case .modelDownloadComplete:
            return "✅ 模型下载完成"
        case .gpuMemoryLow:
            return "⚠️ GPU 内存不足"
        case .systemMemoryLow:
            return "⚠️ 系统内存不足"
        case .inferenceComplete:
            return "✨ 推理任务完成"
        case .modelLoadFailed:
            return "❌ 模型加载失败"
        case .cpuUsageHigh:
            return "📊 CPU 使用异常"
        }
    }
    
    var sound: UNNotificationSound {
        switch self {
        case .modelDownloadComplete, .inferenceComplete:
            return .default
        case .gpuMemoryLow, .systemMemoryLow, .modelLoadFailed, .cpuUsageHigh:
            return UNNotificationSound(named: UNNotificationSoundName("alert.aiff"))
        }
    }
}

/// 通知管理器
class NotificationManager: NSObject, ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = NotificationManager()
    
    // MARK: - Published Properties
    
    @Published var isNotificationEnabled: Bool = true
    @Published var pendingNotifications: [String] = []
    
    // MARK: - Private Properties
    
    private let center = UNUserNotificationCenter.current()
    private var lastNotificationTime: [String: Date] = [:]
    private let minInterval: TimeInterval = 60.0 // 最小通知间隔
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        requestAuthorization()
    }
    
    // MARK: - Public Methods
    
    /// 请求通知授权
    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
            DispatchQueue.main.async {
                self.isNotificationEnabled = granted
            }
        }
    }
    
    /// 发送通知
    func sendNotification(
        type: NotificationType,
        body: String,
        identifier: String? = nil
    ) {
        guard isNotificationEnabled else { return }
        
        let notificationId = identifier ?? UUID().uuidString
        
        // 检查通知间隔，避免频繁通知
        if let lastTime = lastNotificationTime[notificationId],
           Date().timeIntervalSince(lastTime) < minInterval {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = type.title
        content.body = body
        content.sound = type.sound
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: notificationId,
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            } else {
                DispatchQueue.main.async {
                    self.lastNotificationTime[notificationId] = Date()
                    self.pendingNotifications.append(notificationId)
                }
            }
        }
    }
    
    /// 取消所有通知
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        
        DispatchQueue.main.async {
            self.pendingNotifications.removeAll()
        }
    }
    
    /// 取消指定通知
    func cancelNotification(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
        
        DispatchQueue.main.async {
            self.pendingNotifications.removeAll { $0 == identifier }
        }
    }
    
    // MARK: - Convenience Methods
    
    /// 模型下载完成通知
    func notifyModelDownloadComplete(modelName: String) {
        sendNotification(
            type: .modelDownloadComplete,
            body: "模型 \(modelName) 已下载完成，可以开始使用了。",
            identifier: "model-\(modelName)"
        )
    }
    
    /// GPU 内存不足警告
    func notifyGPUMemoryLow(usedMB: Int, totalMB: Int) {
        sendNotification(
            type: .gpuMemoryLow,
            body: "GPU 内存已使用 \(usedMB)MB / \(totalMB)MB，建议关闭部分应用。",
            identifier: "gpu-memory-low"
        )
    }
    
    /// 系统内存不足警告
    func notifySystemMemoryLow(percentage: Double) {
        sendNotification(
            type: .systemMemoryLow,
            body: String(format: "系统内存使用率 %.1f%%，建议清理内存。", percentage),
            identifier: "system-memory-low"
        )
    }
    
    /// 推理任务完成通知
    func notifyInferenceComplete(modelName: String) {
        sendNotification(
            type: .inferenceComplete,
            body: "\(modelName) 推理任务已完成。",
            identifier: "inference-\(modelName)-\(Date().timeIntervalSince1970)"
        )
    }
    
    /// 模型加载失败通知
    func notifyModelLoadFailed(modelName: String, error: String) {
        sendNotification(
            type: .modelLoadFailed,
            body: "模型 \(modelName) 加载失败: \(error)",
            identifier: "model-load-failed"
        )
    }
    
    /// CPU 使用率异常通知
    func notifyCPUUsageHigh(processName: String, usage: Double) {
        sendNotification(
            type: .cpuUsageHigh,
            body: String(format: "%@ CPU 使用率 %.1f%%，持续高占用。", processName, usage),
            identifier: "cpu-high-\(processName)"
        )
    }
}