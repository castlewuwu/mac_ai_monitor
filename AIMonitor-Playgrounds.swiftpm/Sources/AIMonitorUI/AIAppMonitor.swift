import Foundation
import Combine
import AppKit

enum AIAppStatus: String {
    case idle = "空闲"
    case running = "运行中"
    case inference = "推理中"
    case error = "错误"
    case unknown = "未知"
}

struct AIAppInfo: Identifiable {
    let id: String
    let name: String
    let bundleId: String
    let pid: Int32
    var status: AIAppStatus
}

class AIAppMonitor: ObservableObject {
    @Published var detectedApps: [AIAppInfo] = []
    
    private var timer: Timer?
    
    private let knownAIApps: [String: String] = [
        "com.ollama.ollama": "Ollama",
        "com.lmstudio.lmstudio": "LM Studio",
        "com.openai.chatgpt": "ChatGPT",
        "com.anthropic.claude": "Claude",
        "com.whisper.whisper": "Whisper",
        "org.pytorch.pytorch": "PyTorch",
        "org.tensorflow.tensorflow": "TensorFlow",
        // QoderWork 和 Qoder AI 编程助手
        "com.qoderwork.app": "QoderWork",
        "com.qoder.app": "Qoder"
    ]
    
    init() {}
    
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
                status: .running
            )
            detected.append(appInfo)
        }
        
        DispatchQueue.main.async {
            self.detectedApps = detected
        }
    }
}