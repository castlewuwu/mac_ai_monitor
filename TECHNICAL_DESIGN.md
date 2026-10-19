# AI Monitor - 技术设计文档

## 一、架构设计

### 1.1 应用架构
```
┌─────────────────────────────────────────┐
│         MenuBar Controller              │
│  (状态栏图标 + 下拉面板)                   │
└─────────────────┬───────────────────────┘
                  │
        ┌─────────┴─────────┐
        │                   │
   ┌────▼────┐        ┌────▼────┐
   │ System  │        │   AI    │
   │ Monitor │        │ Monitor │
   └────┬────┘        └────┬────┘
        │                   │
        └─────────┬─────────┘
                  │
        ┌─────────▼─────────┐
        │   Notification    │
        │     Manager       │
        └───────────────────┘
```

### 1.2 核心组件

#### SystemMonitor (系统监控)
职责：采集系统级指标
- CPU 使用率（总体 + 各核心）
- 内存使用情况（已用/总量/压力）
- 网络速度（实时上传/下载）
- 磁盘空间

实现方式：
```swift
import IOKit

class SystemMonitor {
    // CPU 使用率：通过 host_processor_info() 获取
    // 内存：通过 vm_statistics64 获取
    // 网络：通过 getifaddrs() 获取接口流量
}
```

#### AIAppMonitor (AI 应用监控)
职责：检测和监控 AI 应用
- 进程扫描（匹配已知 AI 应用）
- 资源占用追踪
- 日志解析（识别关键事件）

实现方式：
```swift
class AIAppMonitor {
    // 1. 进程检测：遍历 NSRunningApplication
    // 2. PID 监控：通过 sysctl 获取进程信息
    // 3. 日志解析：监控应用的 stdout/stderr
}
```

#### NotificationManager (提醒管理)
职责：管理所有提醒逻辑
- 触发条件判断
- 系统通知发送
- 声音提示

实现方式：
```swift
import UserNotifications

class NotificationManager {
    // 使用 UNUserNotificationCenter 发送通知
    // 支持自定义通知内容和声音
}
```

## 二、关键实现

### 2.1 系统指标采集

#### CPU 使用率
```swift
func getCPUUsage() -> Double {
    var cpuInfo: host_cpu_load_info?
    var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)
    
    let result = withUnsafeMutablePointer(to: &cpuInfo) {
        $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
            host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
        }
    }
    
    if result == KERN_SUCCESS, let info = cpuInfo {
        let total = Double(info.cpu_ticks.0 + info.cpu_ticks.1 + info.cpu_ticks.2 + info.cpu_ticks.3)
        let used = Double(info.cpu_ticks.0 + info.cpu_ticks.1 + info.cpu_ticks.2)
        return (used / total) * 100.0
    }
    return 0.0
}
```

#### 内存使用率
```swift
func getMemoryUsage() -> (used: UInt64, total: UInt64, percentage: Double) {
    var stats = vm_statistics64()
    var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
    
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
        let size = MemoryLayout<UInt64>.size
        sysctlbyname("hw.memsize", &totalBytes, &size, nil, 0)
        
        return (used, totalBytes, Double(used) / Double(totalBytes) * 100.0)
    }
    return (0, 0, 0.0)
}
```

#### 网络速度
```swift
func getNetworkSpeed() -> (upload: UInt64, download: UInt64) {
    var interfaceAddresses: UnsafeMutablePointer<ifaddrs>?
    getifaddrs(&interfaceAddresses)
    
    var upload: UInt64 = 0
    var download: UInt64 = 0
    
    var pointer = interfaceAddresses
    while pointer != nil {
        let addr = pointer!.pointee
        if addr.ifa_addr.pointee.sa_family == UInt8(AF_LINK) {
            if let data = addr.ifa_data {
                let networkData = data.assumingMemoryBound(to: if_data.self).pointee
                upload += UInt64(networkData.ifi_obytes)
                download += UInt64(networkData.ifi_ibytes)
            }
        }
        pointer = addr.ifa_next
    }
    
    freeifaddrs(interfaceAddresses)
    return (upload, download)
}
```

### 2.2 AI 应用检测

#### 已知 AI 应用列表
```swift
let knownAIApps = [
    "com.ollama.ollama",           // Ollama
    "com.lmstudio.lmstudio",       // LM Studio
    "com.openai.chatgpt",          // ChatGPT App
    "com.anthropic.claude",        // Claude App
    "com.automatic1111.stable-diffusion-webui",  // SD WebUI
    "com.openai.whisper",          // Whisper
    "org.pytorch.pytorch",         // PyTorch
    "org.tensorflow.tensorflow"    // TensorFlow
]
```

#### 进程扫描
```swift
func detectRunningAIApps() -> [AIAppInfo] {
    let runningApps = NSWorkspace.shared.runningApplications
    var aiApps: [AIAppInfo] = []
    
    for app in runningApps {
        if let bundleId = app.bundleIdentifier,
           knownAIApps.contains(bundleId) {
            let appInfo = AIAppInfo(
                name: app.localizedName ?? "Unknown",
                bundleId: bundleId,
                pid: app.processIdentifier,
                resourceUsage: getResourceUsage(for: app.processIdentifier)
            )
            aiApps.append(appInfo)
        }
    }
    return aiApps
}
```

### 2.3 智能提醒触发条件

| 事件 | 触发条件 | 优先级 |
|------|---------|--------|
| 模型下载完成 | 检测到模型文件写入完成 | 高 |
| GPU 内存不足 | GPU 占用 > 90% | 高 |
| 系统内存不足 | 内存压力 > 90% | 高 |
| 推理任务完成 | 检测到推理日志结束标记 | 中 |
| 模型加载失败 | 解析到错误日志 | 高 |
| CPU 异常占用 | 某进程 CPU > 95% 持续 30s | 中 |

## 三、UI 设计

### 3.1 菜单栏图标
- 常态：显示实时 CPU 使用率数字
- 颜色变化：
  - 绿色：< 50%
  - 黄色：50% - 80%
  - 红色：> 80%

### 3.2 下拉面板
```
┌────────────────────────────────┐
│  系统监控                       │
├────────────────────────────────┤
│  CPU    ████████░░  76%        │
│  内存   ██████░░░░  62%        │
│  网络   ↑ 125KB/s ↓ 3.2MB/s   │
├────────────────────────────────┤
│  AI 应用                        │
├────────────────────────────────┤
│  ● Ollama                      │
│    CPU: 45%  内存: 2.3GB       │
│    正在运行 llama2:7b           │
│                                │
│  ● LM Studio                   │
│    CPU: 12%  内存: 1.1GB       │
│    空闲中                       │
└────────────────────────────────┘
```

## 四、开发计划

### Phase 1: 基础功能 (Week 1)
- [x] 项目框架搭建
- [ ] 系统监控模块（CPU/内存/网络）
- [ ] 菜单栏 UI
- [ ] 基础下拉面板

### Phase 2: AI 应用监控 (Week 2)
- [ ] 进程检测
- [ ] 资源占用追踪
- [ ] 日志解析

### Phase 3: 智能提醒 (Week 3)
- [ ] 提醒系统框架
- [ ] 触发条件逻辑
- [ ] 系统通知集成

### Phase 4: 优化与发布 (Week 4)
- [ ] 性能优化
- [ ] UI 美化
- [ ] 打包发布
- [ ] 文档完善

## 五、测试计划

### 单元测试
- CPU 使用率计算准确性
- 内存指标采集正确性
- 网络速度计算正确性

### 集成测试
- AI 应用检测准确性
- 提醒触发及时性
- UI 响应流畅性

### 性能测试
- 应用启动速度
- 内存占用（目标 < 50MB）
- CPU 占用（目标 < 1%）

## 六、依赖项

- macOS 13.0+
- Xcode 15.0+
- Swift 5.9+

## 七、发布计划

1. GitHub Releases（开源）
2. Homebrew Cask（方便安装）
3. 可选：Mac App Store（如果审核通过）