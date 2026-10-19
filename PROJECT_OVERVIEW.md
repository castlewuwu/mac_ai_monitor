# AI Monitor - 项目概览

> macOS 菜单栏 AI 应用监控工具

## 📋 项目信息

- **项目名称**: AI Monitor
- **版本**: 1.0.0
- **开发语言**: Swift 5.9
- **UI 框架**: SwiftUI
- **最低系统**: macOS 13.0+
- **开发环境**: Xcode 15.0+

## 🎯 核心功能

### 1. 系统监控 ✅
- CPU 使用率实时监控（总体 + 各核心）
- 内存使用情况（已用/总量/压力状态）
- 网络速度（实时上传/下载）
- 数据每秒更新一次

### 2. AI 应用监控 🔍
自动检测并监控以下 AI 应用：

| 应用类型 | 支持的应用 |
|---------|-----------|
| 本地推理 | Ollama, LM Studio, Whisper |
| 图像生成 | Stable Diffusion WebUI, ComfyUI |
| 云服务 | ChatGPT App, Claude App |
| 训练框架 | PyTorch, TensorFlow |

监控信息：
- 进程状态（空闲/运行/推理/错误）
- CPU 和内存占用
- 运行状态判断

### 3. 智能提醒系统 📢
自动识别需要人工介入的情况：

| 提醒类型 | 触发条件 | 优先级 |
|---------|---------|--------|
| 系统内存不足 | 内存使用 > 90% | 高 |
| CPU 异常占用 | CPU > 95% 持续 | 中 |
| AI 应用错误 | 应用状态 = error | 高 |
| 推理任务完成 | 状态变化 | 中 |
| GPU 内存不足 | GPU 显存 > 90% | 高 |

提醒方式：
- macOS 系统通知
- 自定义提示音
- 应用内状态显示

## 📁 项目结构

```
ai-monitor-macos/
├── AI Monitor.xcodeproj/          # Xcode 项目文件
│   └── project.pbxproj
│
├── Sources/
│   └── AIMonitor/
│       ├── AppDelegate.swift          # 应用委托（菜单栏逻辑）
│       ├── main.swift                 # 程序入口
│       │
│       ├── Services/                  # 核心服务
│       │   ├── SystemMonitor.swift         # 系统监控
│       │   ├── AIAppMonitor.swift          # AI 应用监控
│       │   ├── NotificationManager.swift   # 通知管理
│       │   └── AlertEngine.swift           # 智能提醒引擎
│       │
│       ├── Views/                     # SwiftUI 视图
│       │   └── ContentView.swift           # 主视图
│       │
│       ├── Models/                    # 数据模型（待扩展）
│       ├── Utils/                     # 工具类（待扩展）
│       │
│       └── Resources/                 # 资源文件
│           ├── Info.plist                 # 应用配置
│           └── Assets.xcassets            # 资源目录
│
├── Package.swift                  # Swift Package Manager 配置
│
├── README.md                      # 项目说明
├── TECHNICAL_DESIGN.md            # 技术设计文档
├── DEVELOPMENT.md                 # 开发者指南
├── QUICK_START.md                 # 快速入门
│
├── build.sh                       # 构建脚本
├── open-xcode.sh                  # 打开 Xcode 脚本
└── .gitignore                     # Git 忽略规则
```

## 🏗️ 架构设计

```
┌─────────────────────────────────────┐
│      AppDelegate (菜单栏控制)        │
│   - 状态栏图标管理                   │
│   - 弹出窗口控制                     │
│   - 应用生命周期                     │
└──────────────┬──────────────────────┘
               │
       ┌───────┴───────┐
       │               │
┌──────▼──────┐ ┌─────▼──────┐
│ System      │ │ AI App     │
│ Monitor     │ │ Monitor    │
└──────┬──────┘ └─────┬──────┘
       │               │
       │   ┌───────────▼───────────┐
       │   │   AlertEngine         │
       │   │   - 条件检测          │
       │   │   - 状态判断          │
       │   └───────────┬───────────┘
       │               │
       └───────────────▼───────────────┐
               NotificationManager      │
               - 系统通知               │
               - 声音提示               │
               └────────────────────────┘
```

## 🔧 关键技术点

### 系统指标采集

- **CPU 使用率**: `host_processor_info()`
- **内存使用**: `vm_statistics64`
- **网络速度**: `getifaddrs()`
- **进程信息**: `task_info`, `NSRunningApplication`

### 数据更新机制

- 使用 Combine 的 `@Published` 属性
- Timer 定时刷新（1-5 秒间隔）
- 自动触发 SwiftUI UI 更新

### 菜单栏应用特性

- `LSUIElement = true` 不显示在 Dock
- `NSStatusItem` 创建状态栏图标
- `NSPopover` 显示详细信息面板
- `NSEvent` 监听点击外部区域

## 📊 性能指标

### 目标性能
- **内存占用**: < 50MB
- **CPU 占用**: < 1%
- **启动时间**: < 1 秒
- **刷新延迟**: < 100ms

### 优化措施
- 定时器间隔可调整（默认 1 秒）
- 使用 `weak self` 避免循环引用
- 缓存进程信息减少查询
- 延迟初始化非必需组件

## 🚀 快速开始

### 方式一：Xcode
```bash
./open-xcode.sh
# 在 Xcode 中按 ⌘R 运行
```

### 方式二：命令行
```bash
./build.sh --run
```

### 方式三：Swift Package Manager
```bash
swift build
swift run
```

## 📖 文档索引

| 文档 | 说明 |
|------|------|
| `README.md` | 项目介绍和功能说明 |
| `QUICK_START.md` | 5 分钟快速入门 |
| `DEVELOPMENT.md` | 详细开发指南 |
| `TECHNICAL_DESIGN.md` | 技术架构和实现细节 |

## 🎨 UI 预览

### 菜单栏图标
- 显示实时 CPU 使用率数字
- 颜色动态变化：
  - 🟢 绿色：CPU < 50%
  - 🟡 黄色：CPU 50-80%
  - 🔴 红色：CPU > 80%

### 下拉面板
```
┌────────────────────────────────┐
│  系统监控                       │
│  CPU    ████████░░  76%        │
│  内存   ██████░░░░  62%        │
│  网络   ↑ 125KB/s ↓ 3.2MB/s   │
├────────────────────────────────┤
│  AI 应用                        │
│  ● Ollama                      │
│    CPU: 45%  内存: 2.3GB       │
│    正在运行 llama2:7b           │
│                                │
│  ● LM Studio                   │
│    CPU: 12%  内存: 1.1GB       │
│    空闲中                       │
└────────────────────────────────┘
```

## 🛠️ 扩展开发

### 添加新的监控指标
编辑 `Sources/AIMonitor/Services/SystemMonitor.swift`

### 添加新的 AI 应用支持
编辑 `Sources/AIMonitor/Services/AIAppMonitor.swift`

### 添加新的提醒条件
编辑 `Sources/AIMonitor/Services/AlertEngine.swift`

详细说明请参考 `DEVELOPMENT.md`。

## 📝 开发进度

- [x] 项目框架搭建
- [x] 系统监控功能
- [x] AI 应用检测
- [x] 智能提醒系统
- [x] 菜单栏 UI
- [x] 下拉面板 UI
- [ ] 设置面板
- [ ] GPU 监控
- [ ] 历史数据图表
- [ ] 日志解析增强
- [ ] 多语言支持

## 📜 许可证

MIT License

## 👨‍💻 作者

由噬金虫 🪲 为 castle 开发

---

**立即开始使用**: `./open-xcode.sh` 或阅读 `QUICK_START.md` 🚀