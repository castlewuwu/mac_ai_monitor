# AI Monitor - 更新日志

## v1.1.2 (2026-10-19)

### Bug 修复
- 🔧 **修复 Xcode 项目无法启动问题**
  - 删除错误的 main.swift 入口
  - 新增 AI_MonitorApp.swift（使用 @main 标记）
  - 更新 AppDelegate.swift（使用 @NSApplicationDelegateAdaptor）
  - 修复"doesn't contain an executable"错误

### 技术改进
- 使用 SwiftUI App 协议作为应用入口
- 正确配置菜单栏应用生命周期
- 添加 XCODE_FIX_GUIDE.md 文档

---

## v1.1.1 (2026-10-19)

### Bug 修复
- 🔧 修复 Playgrounds 版本的并发错误："'async' call in a function that does not support concurrency"
- 🔧 将 SystemMonitor 和 AIAppMonitor 从 async/await 改为 Timer + DispatchQueue.main.async
- 🔧 修复网络速度计算，现在正确显示实时速度

### 技术改进
- 使用传统 Timer 替代 Task，避免并发问题
- 使用 DispatchQueue.main.async 更新 UI，确保线程安全
- 优化内存管理，正确处理 weak self

---

## v1.1.0 (2026-10-19)

### 新增功能
- ✅ 新增 **QoderWork** AI 编程助手检测支持
- ✅ 新增 **Qoder** AI 编程助手检测支持

### 更新内容
- 更新 AI 应用监控服务，添加 QoderWork 和 Qoder 的 Bundle ID 检测
- 更新文档，新增支持的 AI 应用列表

### 支持的 AI 应用（完整列表）

| 应用类型 | 支持的应用 |
|---------|-----------|
| 本地推理 | Ollama, LM Studio, Whisper, LocalAI |
| 训练任务 | PyTorch, TensorFlow, JAX |
| 图像生成 | Stable Diffusion WebUI, ComfyUI |
| 云服务客户端 | ChatGPT App, Claude App |
| **AI 编程助手** | **QoderWork**, **Qoder** |

---

## v1.0.0 (2026-10-19)

### 初始版本
- ✅ 系统监控功能（CPU、内存、网络）
- ✅ AI 应用检测
- ✅ 智能提醒系统
- ✅ Swift Playgrounds App（开箱即用）
- ✅ Xcode 项目（完整开发环境）
- ✅ 完整文档系统

### 支持的 AI 应用
- Ollama
- LM Studio
- ChatGPT App
- Claude App
- PyTorch
- TensorFlow
- Whisper

---

**更新人**: 噬金虫 🪲  
**最新更新时间**: 2026-10-19 19:35 GMT+8