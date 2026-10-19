//
//  SystemMonitor.swift
//  AI Monitor
//
//  系统资源监控服务
//

import Foundation
import IOKit

/// 系统资源监控器
class SystemMonitor: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var cpuUsage: Double = 0.0
    @Published var memoryUsed: UInt64 = 0
    @Published var memoryTotal: UInt64 = 0
    @Published var memoryPercentage: Double = 0.0
    @Published var networkUpload: UInt64 = 0
    @Published var networkDownload: UInt64 = 0
    @Published var uploadSpeed: UInt64 = 0
    @Published var downloadSpeed: UInt64 = 0
    
    // MARK: - Private Properties
    
    private var timer: Timer?
    private var previousUpload: UInt64 = 0
    private var previousDownload: UInt64 = 0
    private var previousTime: Date = Date()
    
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
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateMetrics()
        }
    }
    
    /// 停止监控
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Private Methods
    
    /// 更新所有指标
    private func updateMetrics() {
        updateCPUUsage()
        updateMemoryUsage()
        updateNetworkSpeed()
    }
    
    /// 更新 CPU 使用率
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
    
    /// 更新内存使用率
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
            let free = UInt64(stats.free_count) * pageSize
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
    
    /// 更新网络速度
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
                self.networkUpload = currentUpload
                self.networkDownload = currentDownload
            }
        }
        
        previousUpload = currentUpload
        previousDownload = currentDownload
        previousTime = currentTime
    }
    
    // MARK: - Helper Methods
    
    /// 格式化字节大小
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
    
    /// 格式化速度
    static func formatSpeed(_ bytesPerSecond: UInt64) -> String {
        return formatBytes(bytesPerSecond) + "/s"
    }
}