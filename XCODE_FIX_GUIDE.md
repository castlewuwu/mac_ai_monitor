# AI Monitor - Xcode 项目配置修复指南

## ❌ 问题：无法启动应用

**错误信息**:
```
The bundle doesn't contain an executable.
Please check your project settings and build log.
```

**原因**: 
- main.swift 入口点配置不正确
- 项目缺少正确的 @main 标记

## ✅ 已修复

### 修改内容

1. **删除** `main.swift`
2. **新增** `AI_MonitorApp.swift`（使用 SwiftUI App 协议）
3. **更新** `AppDelegate.swift`（使用 @NSApplicationDelegateAdaptor）

### 新的应用入口

```swift
// AI_MonitorApp.swift
import SwiftUI

@main
struct AI_MonitorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
```

## 🚀 重新构建

### 步骤 1: 清理构建
```bash
# 在 Xcode 中
Product → Clean Build Folder (⇧⌘K)
```

### 步骤 2: 删除 DerivedData
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/AI_Monitor-*
```

### 步骤 3: 重新构建
```bash
# 在 Xcode 中
Product → Build (⌘B)
```

### 步骤 4: 运行
```bash
# 在 Xcode 中
Product → Run (⌘R)
```

## 📋 项目结构

```
Sources/AIMonitor/
├── AI_MonitorApp.swift       ✅ 应用入口（新）
├── AppDelegate.swift          ✅ 应用委托（已更新）
├── Services/
│   ├── SystemMonitor.swift
│   ├── AIAppMonitor.swift
│   ├── NotificationManager.swift
│   └── AlertEngine.swift
├── Views/
│   └── ContentView.swift
└── Resources/
    └── Info.plist
```

## 🎯 验证清单

构建成功后，检查：

- [ ] 应用出现在菜单栏（CPU 图标）
- [ ] 点击图标显示监控面板
- [ ] CPU/内存/网络数据正常显示
- [ ] AI 应用检测正常工作
- [ ] 点击外部区域自动关闭面板

## ⚠️ 如果仍然失败

### 检查 Build Settings

1. **Product Name**
   - Build Settings → Packaging → Product Name
   - 应该是 "AI Monitor"

2. **Bundle Identifier**
   - Build Settings → Packaging → Product Bundle Identifier
   - 应该是 "com.aimonitor.app"

3. **Executable Prefix**
   - Build Settings → Packaging → Executive Prefix
   - 应该为空

4. **Info.plist Path**
   - Build Settings → Packaging → Info.plist File
   - 应该是 "Sources/AIMonitor/Resources/Info.plist"

### 检查 Target

1. 选择项目 target "AI Monitor"
2. 确保是 macOS App target
3. 确保所有 Swift 文件都包含在 target 中

## 💡 替代方案

如果 Xcode 项目仍有问题，可以使用：

### Playgrounds 版本
```bash
open AIMonitor-Playgrounds.swiftpm
```

### 命令行运行
```bash
cd AIMonitor-Playgrounds.swiftpm
swift run
```

---

**更新人**: 噬金虫 🪲  
**更新时间**: 2026-10-19 19:35 GMT+8