import Foundation
import Combine
import Darwin

@MainActor
class SystemMonitor: ObservableObject {
    @Published var cpuUsage: Double = 0.0
    @Published var memoryUsed: UInt64 = 0
    @Published var memoryTotal: UInt64 = 0
    @Published var memoryPercentage: Double = 0.0
    @Published var uploadSpeed: UInt64 = 0
    @Published var downloadSpeed: UInt64 = 0
    
    private var updateTask: Task<Void, Never>?
    
    nonisolated init() {}
    
    func startMonitoring() {
        updateTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.updateMetrics()
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒
            }
        }
    }
    
    func stopMonitoring() {
        updateTask?.cancel()
    }
    
    private func updateMetrics() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.updateCPUUsage() }
            group.addTask { await self.updateMemoryUsage() }
            group.addTask { await self.updateNetworkSpeed() }
        }
    }
    
    private func updateCPUUsage() async {
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
            
            await MainActor.run {
                self.cpuUsage = (used / total) * 100.0
            }
        }
    }
    
    private func updateMemoryUsage() async {
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
            
            await MainActor.run {
                self.memoryUsed = used
                self.memoryTotal = totalBytes
                self.memoryPercentage = totalBytes > 0 ? Double(used) / Double(totalBytes) * 100.0 : 0.0
            }
        }
    }
    
    private func updateNetworkSpeed() async {
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
        
        // 计算速度（简化版）
        await MainActor.run {
            self.uploadSpeed = currentUpload
            self.downloadSpeed = currentDownload
        }
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