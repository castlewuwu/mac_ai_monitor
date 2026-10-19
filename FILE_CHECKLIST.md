# AI Monitor - 项目文件清单

## ✅ 已创建的文件

### 📁 项目配置文件
- [x] `AI Monitor.xcodeproj/project.pbxproj` - Xcode 项目配置
- [x] `Package.swift` - Swift Package Manager 配置
- [x] `.gitignore` - Git 忽略规则

### 📝 文档文件
- [x] `README.md` - 项目说明和功能介绍
- [x] `PROJECT_OVERVIEW.md` - 项目概览和结构说明
- [x] `QUICK_START.md` - 5 分钟快速入门指南
- [x] `DEVELOPMENT.md` - 详细开发指南
- [x] `TECHNICAL_DESIGN.md` - 技术架构设计文档

### 🔧 构建脚本
- [x] `build.sh` - 构建脚本（支持 --release, --clean, --run 参数）
- [x] `open-xcode.sh` - 快速打开 Xcode 项目

### 💻 源代码文件

#### 核心文件
- [x] `Sources/AIMonitor/main.swift` - 程序入口
- [x] `Sources/AIMonitor/AppDelegate.swift` - 应用委托（菜单栏逻辑）

#### 服务层 (Services/)
- [x] `Sources/AIMonitor/Services/SystemMonitor.swift` - 系统监控服务
  - CPU 使用率采集
  - 内存使用监控
  - 网络速度监控
  - 数据格式化工具

- [x] `Sources/AIMonitor/Services/AIAppMonitor.swift` - AI 应用监控服务
  - 进程扫描和检测
  - 已知 AI 应用识别
  - 资源占用追踪
  - 状态判断逻辑

- [x] `Sources/AIMonitor/Services/NotificationManager.swift` - 通知管理服务
  - 系统通知发送
  - 提醒类型定义
  - 通知间隔控制
  - 便捷通知方法

- [x] `Sources/AIMonitor/Services/AlertEngine.swift` - 智能提醒引擎
  - 提醒条件配置
  - 状态变化检测
  - 人工介入判断
  - 提醒触发逻辑

#### 视图层 (Views/)
- [x] `Sources/AIMonitor/Views/ContentView.swift` - 主视图
  - 系统监控组件
  - AI 应用列表组件
  - 进度条和状态显示
  - 底部操作按钮

#### 资源文件 (Resources/)
- [x] `Sources/AIMonitor/Resources/Info.plist` - 应用配置
  - 不显示在 Dock
  - 通知权限配置
  - 应用标识信息

### 📂 待创建目录（空目录）
- [ ] `Sources/AIMonitor/Models/` - 数据模型（预留）
- [ ] `Sources/AIMonitor/Utils/` - 工具类（预留）
- [ ] `Sources/AIMonitor/Resources/Assets.xcassets/` - 资源目录（预留）

## 📊 代码统计

| 类别 | 文件数 | 预估代码行数 |
|------|--------|-------------|
| 核心逻辑 | 2 | ~150 行 |
| 服务层 | 4 | ~1000 行 |
| 视图层 | 1 | ~250 行 |
| 配置文件 | 3 | ~200 行 |
| **总计** | **10** | **~1600 行** |

## ✨ 已实现的功能

### 系统监控 ✅
- [x] CPU 使用率实时监控
- [x] 内存使用率监控
- [x] 网络上传/下载速度
- [x] 数据自动刷新（每秒）
- [x] 数据格式化显示

### AI 应用监控 ✅
- [x] 自动检测运行中的 AI 应用
- [x] 显示应用资源占用
- [x] 判断应用状态（空闲/运行/推理/错误）
- [x] 支持常见 AI 应用：
  - Ollama
  - LM Studio
  - ChatGPT App
  - Claude App
  - Stable Diffusion WebUI
  - ComfyUI

### 智能提醒 ✅
- [x] 系统内存不足提醒（> 90%）
- [x] CPU 异常占用警告（> 95%）
- [x] AI 应用错误提醒
- [x] 推理任务完成通知
- [x] 提醒间隔控制（避免频繁打扰）
- [x] 系统通知集成

### UI 界面 ✅
- [x] 菜单栏图标显示
- [x] 图标颜色动态变化
- [x] 点击显示下拉面板
- [x] 点击外部自动关闭
- [x] 进度条可视化
- [x] 应用状态指示器

## 🚧 待开发功能

### Phase 2: 增强功能
- [ ] 设置面板
  - [ ] 阈值配置
  - [ ] 监控间隔调整
  - [ ] 通知开关
  - [ ] 开机自启动选项

- [ ] GPU 监控
  - [ ] GPU 使用率
  - [ ] GPU 内存占用
  - [ ] Metal 性能 HUD

- [ ] 日志解析增强
  - [ ] Ollama 日志解析
  - [ ] LM Studio 状态检测
  - [ ] SD WebUI 进度跟踪
  - [ ] 错误信息提取

### Phase 3: 高级功能
- [ ] 历史数据
  - [ ] 指标历史图表
  - [ ] 日志记录
  - [ ] 导出功能

- [ ] 多语言支持
  - [ ] 英文
  - [ ] 日文
  - [ ] 其他语言

- [ ] 云同步
  - [ ] 配置同步
  - [ ] 历史数据备份

## 🎯 下一步行动

### 立即可做
1. ✅ 打开项目：`./open-xcode.sh`
2. ✅ 运行应用：在 Xcode 中按 ⌘R
3. ✅ 测试功能：监控 CPU/内存/网络

### 短期任务（1-2 天）
1. [ ] 完善资源目录（添加应用图标）
2. [ ] 添加基础单元测试
3. [ ] 优化 UI 样式
4. [ ] 添加设置面板基础框架

### 中期任务（1 周）
1. [ ] 实现 GPU 监控
2. [ ] 增强 AI 应用检测逻辑
3. [ ] 添加日志解析功能
4. [ ] 完善错误处理

### 长期任务（2-4 周）
1. [ ] 添加历史数据功能
2. [ ] 实现多语言支持
3. [ ] 优化性能
4. [ ] 准备发布

## 📋 快速检查清单

使用前请确认：

- [ ] macOS 13.0+ 系统
- [ ] Xcode 15.0+ 已安装
- [ ] Swift 5.9+ 已安装
- [ ] 项目可以成功构建
- [ ] 应用可以在菜单栏显示
- [ ] 系统监控数据正常更新
- [ ] 通知权限已授予

## 🔗 相关链接

- [SwiftUI 官方文档](https://developer.apple.com/documentation/swiftui)
- [macOS App 开发指南](https://developer.apple.com/documentation/appkit)
- [User Notifications 框架](https://developer.apple.com/documentation/usernotifications)

---

**当前版本**: v1.0.0  
**创建日期**: 2026-10-19  
**开发者**: 噬金虫 🪲  
**状态**: ✅ 核心功能已完成，可运行测试