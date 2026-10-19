//
//  AIAppMonitor.swift
//  AI Monitor
//
//  AI 应用监控服务
//

import Foundation
import AppKit

/// AI 应用信息
struct AIAppInfo: Identifiable {
    let id: String
    let name: String
    let bundleId: String
    let pid: Int32
    var resourceUsage: ProcessResourceUsage
    var status: AIAppStatus
}

/// 进程资源使用情况
struct ProcessResourceUsage {
    var cpuUsage: Double
    var memoryUsed: UInt64
    var threads: Int
}

/// AI 应用状态
enum AIAppStatus {
    case idle           // 空闲
    case running        // 运行中
    case loading        // 加载模型
    case inference      // 推理中
    case error          // 错误
    case unknown        // 未知
}

/// AI 应用监控器
class AIAppMonitor: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var detectedApps: [AIAppInfo] = []
    @Published var isMonitoring: Bool = false
    
    // MARK: - Private Properties
    
    private var timer: Timer?
    
    /// 已知的 AI 应用 Bundle IDs
    private let knownAIApps: [String: String] = [
        "com.ollama.ollama": "Ollama",
        "com.lmstudio.lmstudio": "LM Studio",
        "com.openai.chatgpt": "ChatGPT",
        "com.anthropic.claude": "Claude",
        "com.openai.whisper": "Whisper",
        "org.pytorch.pytorch": "PyTorch",
        "org.tensorflow.tensorflow": "TensorFlow",
        "com.automatic1111.stable-diffusion-webui": "Stable Diffusion WebUI",
        "com.comfyui.comfyui": "ComfyUI",
        // QoderWork 和 Qoder AI 编程助手
        "com.qoderwork.app": "QoderWork",
        "com.qoder.app": "Qoder",
        "com.qoderwork.qoderwork": "QoderWork",
        "com.qoder.qoder": "Qoder"
    ]
    
    // MARK: - Initialization
    
    init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Public Methods
    
    /// 开始监控
    func startMonitoring() {
        isMonitoring = true
        scanForAIApps()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.scanForAIApps()
        }
    }
    
    /// 停止监控
    func stopMonitoring() {
        isMonitoring = false
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Private Methods
    
    /// 扫描运行中的 AI 应用
    private func scanForAIApps() {
        let runningApps = NSWorkspace.shared.runningApplications
        var detected: [AIAppInfo] = []
        
        for app in runningApps {
            guard let bundleId = app.bundleIdentifier else { continue }
            
            if let appName = knownAIApps[bundleId] {
                let pid = app.processIdentifier
                let resourceUsage = getProcessResourceUsage(pid: pid)
                
                let appInfo = AIAppInfo(
                    id: bundleId,
                    name: appName,
                    bundleId: bundleId,
                    pid: pid,
                    resourceUsage: resourceUsage,
                    status: determineAppStatus(pid: pid, bundleId: bundleId)
                )
                
                detected.append(appInfo)
            }
        }
        
        // 额外检查命令行工具（如 ollama 进程）
        if let ollamaProcess = findCommandLineProcess(named: "ollama") {
            let resourceUsage = getProcessResourceUsage(pid: ollamaProcess.pid)
            let appInfo = AIAppInfo(
                id: "cli.ollama",
                name: "Ollama (CLI)",
                bundleId: "cli.ollama",
                pid: ollamaProcess.pid,
                resourceUsage: resourceUsage,
                status: determineAppStatus(pid: ollamaProcess.pid, bundleId: "cli.ollama")
            )
            detected.append(appInfo)
        }
        
        DispatchQueue.main.async {
            self.detectedApps = detected
        }
    }
    
    /// 查找命令行进程
    private func findCommandLineProcess(named name: String) -> (pid: Int32, path: String)? {
        let task = Process()
        task.launchPath = "/usr/bin/pgrep"
        task.arguments = ["-f", name]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        
        if task.terminationStatus == 0 {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8),
               let pid = Int32(output.trimmingCharacters(in: .whitespacesAndNewlines)) {
                return (pid, name)
            }
        }
        
        return nil
    }
    
    /// 获取进程资源使用情况
    private func getProcessResourceUsage(pid: Int32) -> ProcessResourceUsage {
        var taskInfo = task_info_basic_data()
        var count = mach_msg_type_number_t(MemoryLayout<task_info_basic_data>.size / MemoryLayout<natural_t>.size)
        
        let result = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, TASK_INFO_BASIC, $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            // CPU 使用率需要通过线程信息计算
            let cpuUsage = getProcessCPUUsage(pid: pid)
            let memoryUsed = UInt64(taskInfo.resident_size)
            let threads = Int(taskInfo.thread_count)
            
            return ProcessResourceUsage(
                cpuUsage: cpuUsage,
                memoryUsed: memoryUsed,
                threads: threads
            )
        }
        
        return ProcessResourceUsage(cpuUsage: 0, memoryUsed: 0, threads: 0)
    }
    
    /// 获取进程 CPU 使用率
    private func getProcessCPUUsage(pid: Int32) -> Double {
        var threadList: thread_act_array_t?
        var threadCount: mach_msg_type_number_t = 0
        
        let result = task_threads(mach_task_self_, &threadList, &threadCount)
        
        if result == KERN_SUCCESS, let threads = threadList {
            var totalUsage: Double = 0.0
            
            for i in 0..<Int(threadCount) {
                var info = thread_basic_info()
                var count = mach_msg_type_number_t(THREAD_INFO_MAX)
                
                let kr = withUnsafeMutablePointer(to: &info) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                        thread_info(threads[i], thread_flavor_t(THREAD_BASIC_INFO), $0, &count)
                    }
                }
                
                if kr == KERN_SUCCESS && (info.flags & TH_FLAGS_IDLE) == 0 {
                    totalUsage += Double(info.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0
                }
            }
            
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: threads), vm_size_t(Int(threadCount) * MemoryLayout<thread_t>.size))
            
            return totalUsage
        }
        
        return 0.0
    }
    
    /// 判断应用状态
    private func determineAppStatus(pid: Int32, bundleId: String) -> AIAppStatus {
        // 这里可以添加更复杂的逻辑：
        // 1. 解析应用日志
        // 2. 检查网络连接
        // 3. 检查 GPU 使用情况
        
        // 简化版：根据 CPU 使用率判断
        let cpuUsage = getProcessCPUUsage(pid: pid)
        
        if cpuUsage < 5.0 {
            return .idle
        } else if cpuUsage < 30.0 {
            return .running
        } else {
            return .inference
        }
    }
    
    /// 解析 Ollama 日志
    private func parseOllamaLogs() -> [LogEvent] {
        // TODO: 实现 Ollama 日志解析
        // 日志位置: ~/.ollama/logs/
        return []
    }
}

/// 日志事件
struct LogEvent {
    let timestamp: Date
    let message: String
    let type: LogEventType
}

enum LogEventType {
    case modelLoaded
    case modelDownloadStart
    case modelDownloadComplete
    case inferenceStart
    case inferenceComplete
    case error
}