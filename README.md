# AI Monitor - macOS 菜单栏监控工具

一个轻量级的 macOS 菜单栏应用，用于监控系统资源和 AI 应用状态。

## 功能特性

### 系统监控
- ✅ CPU 使用率实时监控
- ✅ 内存使用情况
- ✅ 网络速度（上传/下载）

### AI 应用监控
- 🔍 自动检测运行中的 AI 应用
- 📊 监控 AI 应用资源占用
- 📝 解析应用日志识别关键事件

### 智能提醒
- 📢 模型下载完成提醒
- ⚠️ GPU/内存不足警告
- ✨ 推理任务完成通知
- 🚫 模型加载失败提示

## 支持的 AI 应用

| 应用类型 | 支持的应用 |
|---------|-----------|
| 本地推理 | Ollama, LM Studio, Whisper, LocalAI |
| 训练任务 | PyTorch, TensorFlow, JAX |
| 图像生成 | Stable Diffusion WebUI, ComfyUI |
| 云服务客户端 | ChatGPT App, Claude App |

## 技术栈

- Swift 5.9
- SwiftUI
- Combine
- IOKit (系统指标采集)

## 项目结构

```
AI Monitor/
├── AI Monitor App/
│   ├── Models/          # 数据模型
│   ├── Views/           # SwiftUI 视图
│   ├── Services/        # 监控服务
│   │   ├── SystemMonitor.swift
│   │   ├── AIAppMonitor.swift
│   │   └── NetworkMonitor.swift
│   ├── Utils/           # 工具类
│   └── Resources/       # 资源文件
├── AI Monitor.xcodeproj
└── README.md
```

## 开发进度

- [ ] 项目初始化
- [ ] 系统监控功能
- [ ] AI 应用检测
- [ ] 智能提醒系统
- [ ] UI 界面优化
- [ ] 测试与发布

## 许可证

MIT License