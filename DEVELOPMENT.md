# AI Monitor - 开发者指南

## 快速开始

### 系统要求

- macOS 13.0+
- Xcode 15.0+
- Swift 5.9+

### 项目打开方式

#### 方式一：使用 Xcode（推荐）

```bash
cd ai-monitor-macos
open "AI Monitor.xcodeproj"
```

#### 方式二：使用 Swift Package Manager

```bash
cd ai-monitor-macos
swift build
swift run
```

### 构建运行

1. 在 Xcode 中打开项目
2. 选择目标设备（My Mac）
3. 点击运行按钮（⌘R）

应用会自动启动，并在菜单栏显示图标。

## 项目结构

```
AI Monitor/
├── AI Monitor.xcodeproj/      # Xcode 项目文件
├── Sources/
│   └── AIMonitor/
│       ├── AppDelegate.swift      # 应用委托（菜单栏逻辑）
│       ├── main.swift             # 程序入口
│       ├── Services/              # 服务层
│       │   ├── SystemMonitor.swift     # 系统监控
│       │   ├── AIAppMonitor.swift      # AI 应用监控
│       │   ├── NotificationManager.swift  # 通知管理
│       │   └── AlertEngine.swift       # 智能提醒引擎
│       ├── Views/                 # SwiftUI 视图
│       │   └── ContentView.swift      # 主视图
│       ├── Models/                # 数据模型（待添加）
│       ├── Utils/                 # 工具类（待添加）
│       └── Resources/             # 资源文件
│           └── Info.plist             # 应用配置
├── Package.swift                  # SPM 配置
├── README.md                      # 项目说明
├── TECHNICAL_DESIGN.md            # 技术设计
└── DEVELOPMENT.md                 # 本文档
```

## 核心功能实现

### 1. 系统监控

`SystemMonitor.swift` 负责采集系统指标：

- **CPU 使用率**：通过 `host_processor_info()` 获取
- **内存使用**：通过 `vm_statistics64` 获取
- **网络速度**：通过 `getifaddrs()` 获取接口流量

使用 Combine 的 `@Published` 属性，自动触发 UI 更新。

### 2. AI 应用监控

`AIAppMonitor.swift` 检测和监控 AI 应用：

- **进程扫描**：遍历 `NSRunningApplication`
- **资源追踪**：通过 `task_info` 获取进程信息
- **状态判断**：根据 CPU 使用率和日志分析

已支持的 AI 应用：
- Ollama（App + CLI）
- LM Studio
- ChatGPT App
- Claude App
- Stable Diffusion WebUI
- ComfyUI

### 3. 智能提醒

`AlertEngine.swift` 实现智能提醒逻辑：

#### 提醒触发条件

| 条件 | 阈值 | 说明 |
|------|------|------|
| 系统内存不足 | > 90% | 需要关闭部分应用 |
| CPU 异常占用 | > 95% | 持续高占用警告 |
| GPU 内存不足 | > 90% | 建议释放 GPU 内存 |
| AI 应用错误 | 状态 = error | 需要人工介入 |
| 推理任务完成 | 状态变化 | 任务完成通知 |

#### 提醒方式

- **系统通知**：使用 `UNUserNotificationCenter`
- **声音提示**：可选的提示音
- **应用内提示**：在菜单栏面板显示

### 4. 菜单栏应用

`AppDelegate.swift` 实现菜单栏逻辑：

- **状态栏图标**：显示实时 CPU 使用率
- **颜色变化**：根据使用率动态变色
- **弹出面板**：点击显示详细信息
- **事件监控**：点击外部区域自动关闭

## 扩展开发

### 添加新的监控指标

1. 在 `SystemMonitor.swift` 中添加采集方法
2. 创建 `@Published` 属性
3. 在 `updateMetrics()` 中调用
4. 在 `ContentView.swift` 中添加显示

示例：添加磁盘空间监控

```swift
// SystemMonitor.swift
@Published var diskUsed: UInt64 = 0
@Published var diskTotal: UInt64 = 0

private func updateDiskUsage() {
    let fileManager = FileManager.default
    let homeURL = fileManager.homeDirectoryForCurrentUser
    
    if let attributes = try? fileManager.attributesOfFileSystem(forPath: homeURL.path) {
        diskTotal = (attributes[.systemSize] as? UInt64) ?? 0
        diskUsed = diskTotal - ((attributes[.systemFreeSize] as? UInt64) ?? 0)
    }
}
```

### 添加新的 AI 应用支持

1. 在 `AIAppMonitor.swift` 的 `knownAIApps` 字典中添加：
   ```swift
   private let knownAIApps: [String: String] = [
       // ... 现有应用
       "com.yourapp.bundleid": "Your App Name",
   ]
   ```

2. 如果需要特殊监控逻辑，在 `determineAppStatus()` 中添加：
   ```swift
   if bundleId == "com.yourapp.bundleid" {
       // 特殊检测逻辑
   }
   ```

### 添加新的提醒条件

1. 在 `AlertEngine.swift` 的 `setupAlertConditions()` 中添加：
   ```swift
   AlertCondition(
       id: "your-alert-id",
       name: "提醒名称",
       checkInterval: 5.0
   ) { [weak self] in
       // 返回 true 时触发提醒
       return self?.someCondition ?? false
   } action: { [weak self] in
       // 触发提醒时的操作
       self?.triggerAlert(type: .custom, message: "提醒消息")
   }
   ```

2. 如需新的通知类型，在 `NotificationManager.swift` 中添加：
   ```swift
   enum NotificationType {
       // ... 现有类型
       case custom
   }
   ```

## 测试

### 单元测试

在 `AIMonitorTests` target 中添加测试：

```swift
import XCTest
@testable import AIMonitor

final class SystemMonitorTests: XCTestCase {
    func testCPUUsage() {
        let monitor = SystemMonitor()
        XCTAssertGreaterThan(monitor.cpuUsage, 0)
        XCTAssertLessThan(monitor.cpuUsage, 100)
    }
}
```

### 手动测试清单

- [ ] 应用启动后在菜单栏显示图标
- [ ] 点击图标显示详细信息面板
- [ ] 点击外部区域自动关闭面板
- [ ] CPU/内存/网络数据实时更新
- [ ] 检测到 AI 应用时正确显示
- [ ] 超过阈值时发送系统通知
- [ ] 通知声音正常播放
- [ ] 应用退出后无残留进程

## 性能优化

### 当前性能目标

- **内存占用**：< 50MB
- **CPU 占用**：< 1%
- **启动时间**：< 1 秒

### 优化建议

1. **监控间隔调整**
   - 系统监控：1 秒（可调整为 2-3 秒）
   - AI 应用检测：5 秒（可调整为 10 秒）
   - 提醒检查：5 秒（可调整为 10 秒）

2. **内存优化**
   - 避免频繁创建对象
   - 使用 `weak self` 防止循环引用
   - 及时释放不需要的资源

3. **CPU 优化**
   - 减少不必要的计算
   - 使用缓存避免重复查询
   - 合并相似的监控任务

## 发布准备

### 1. 签名配置

在 Xcode 中配置开发者证书：
1. 选择项目 target
2. 在 Signing & Capabilities 标签
3. 选择你的开发团队
4. 更新 Bundle Identifier

### 2. 版本号更新

在 `Info.plist` 中更新：
- `CFBundleShortVersionString`: 用户可见版本号
- `CFBundleVersion`: 构建号

### 3. 构建发布版本

```bash
# 命令行构建
xcodebuild -project "AI Monitor.xcodeproj" \
  -scheme "AI Monitor" \
  -configuration Release \
  clean build
```

### 4. 归档应用

在 Xcode 中：
1. Product → Archive
2. 选择归档文件
3. Distribute App

## 常见问题

### Q: 为什么应用没有显示在 Dock？

A: 因为 `Info.plist` 中设置了 `LSUIElement = true`，这是菜单栏应用的标准做法。

### Q: 如何查看应用日志？

A: 在控制台应用（Console.app）中过滤 "AI Monitor" 进程。

### Q: 提醒不工作？

A: 检查系统设置 → 通知 → AI Monitor，确保通知已启用。

### Q: 如何添加开机自启动？

A: 可以通过以下方式：
1. 系统设置 → 登录项 → 添加应用
2. 或在代码中实现（需要特殊权限）

## 下一步开发

### 待实现功能

1. **设置面板**
   - 阈值配置
   - 监控间隔调整
   - 通知开关

2. **GPU 监控**
   - Metal Performance HUD
   - GPU 内存使用
   - 计算负载

3. **日志解析增强**
   - Ollama 日志解析
   - LM Studio 状态检测
   - SD WebUI 进度跟踪

4. **历史数据**
   - 指标历史图表
   - 日志记录
   - 导出功能

5. **多语言支持**
   - 英文
   - 日文
   - 其他语言

## 相关资源

- [SwiftUI 官方文档](https://developer.apple.com/documentation/swiftui)
- [macOS Menu Bar Apps](https://developer.apple.com/documentation/appkit/nsstatusitem)
- [User Notifications](https://developer.apple.com/documentation/usernotifications)
- [IOKit Framework](https://developer.apple.com/documentation/iokit)

## 联系与贡献

如有问题或建议，欢迎提交 Issue 或 Pull Request！