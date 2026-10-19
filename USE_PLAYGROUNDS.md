# AI Monitor - 使用指南（推荐方案）

## ⚠️ Xcode 项目问题说明

如果你遇到 `kLSNoExecutableErr` 错误，说明 Xcode 项目配置有问题。

**解决方案**: 使用 **Playgrounds 版本**（功能完全相同）

---

## ✅ 推荐使用：Playgrounds 版本

### 方式一：双击启动（最简单）

```bash
# 在 Finder 中双击这个文件夹
AIMonitor-Playgrounds.swiftpm

# 会自动打开 Swift Playgrounds
# 点击右上角的 ▶️ 按钮即可运行
```

### 方式二：终端启动

```bash
cd mac_ai_monitor
./start-monitor.sh
```

### 方式三：命令行运行

```bash
cd mac_ai_monitor/AIMonitor-Playgrounds.swiftpm
swift run
```

---

## 🎯 功能对比

| 功能 | Playgrounds 版本 | Xcode 版本 |
|------|------------------|------------|
| **开箱即用** | ✅ 是 | ❌ 需配置 |
| **编译错误** | ✅ 无 | ❌ 有 |
| **功能完整性** | ✅ 完整 | ✅ 完整 |
| **系统监控** | ✅ 支持 | ✅ 支持 |
| **AI 应用检测** | ✅ 支持 | ✅ 支持 |
| **实时更新** | ✅ 支持 | ✅ 支持 |

---

## 📦 使用步骤

### 1. 拉取最新代码
```bash
cd ~/path/to/mac_ai_monitor
git pull
```

### 2. 启动应用
```bash
# 方式一：双击
open AIMonitor-Playgrounds.swiftpm

# 方式二：终端
./start-monitor.sh
```

### 3. 点击运行
- 在 Swift Playgrounds 中点击 ▶️ 按钮
- 或在 Xcode 中按 ⌘R

---

## ✅ 成功标志

运行成功后，你会看到：

```
┌─────────────────────────────────┐
│  🪲 AI Monitor      🟢 监控中   │
├─────────────────────────────────┤
│  📊 系统监控                    │
│  CPU: ██...░░  XX%             │
│  内存: █...░░  XX%             │
│  网络: ↗️ XX MB/s  ↘️ XX MB/s  │
├─────────────────────────────────┤
│  🤖 AI 应用                     │
│  ● Ollama    🟢 运行中          │
└─────────────────────────────────┘
```

---

## 🔧 如果 Playgrounds 也无法打开

### 安装 Swift Playgrounds

1. 打开 **App Store**
2. 搜索 "Swift Playgrounds"
3. 免费安装
4. 重新打开 `AIMonitor-Playgrounds.swiftpm`

---

## 💡 为什么推荐 Playgrounds？

1. **零配置** - 不需要处理复杂的 Xcode 设置
2. **稳定可靠** - 不会出现编译/链接错误
3. **功能完整** - 所有监控功能都正常
4. **易于更新** - 直接修改代码即可

---

## 🎊 总结

**放弃 Xcode 项目**，**使用 Playgrounds 版本**！

这是最简单、最可靠的方案。

---

**推荐命令**:
```bash
# 一键启动
./start-monitor.sh
```

**或者**:
```bash
# 直接运行
cd AIMonitor-Playgrounds.swiftpm
swift run
```

---

**更新人**: 噬金虫 🪲  
**更新时间**: 2026-10-19 19:50 GMT+8