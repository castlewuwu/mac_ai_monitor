#!/bin/bash

# AI Monitor - 完整诊断和修复脚本

echo "🪲 AI Monitor - 诊断工具"
echo "================================"
echo ""

# 检查系统环境
echo "📋 系统检查"
echo "--------------------------------"

# macOS 版本
SW_VERS=$(sw_vers -productVersion 2>/dev/null || echo "未知")
echo "macOS 版本: $SW_VERS"

# Swift 版本
if command -v swift &> /dev/null; then
    SWIFT_VERS=$(swift --version | head -n 1)
    echo "✅ Swift: $SWIFT_VERS"
else
    echo "❌ Swift 未安装"
    echo "   请安装 Xcode 或 Swift 工具链"
    exit 1
fi

echo ""

# 尝试运行不同版本
echo "🚀 尝试运行（按顺序尝试）"
echo "--------------------------------"

# 1. 尝试最简单的单文件版本
echo ""
echo "方式 1: 单文件版本"
echo "命令: swift ai-monitor.swift"
echo ""

if [ -f "ai-monitor.swift" ]; then
    echo "✅ 找到文件，尝试运行..."
    swift ai-monitor.swift
    EXIT_CODE=$?
    
    if [ $EXIT_CODE -eq 0 ]; then
        echo "✅ 运行成功！"
        exit 0
    else
        echo "❌ 运行失败，错误码: $EXIT_CODE"
    fi
else
    echo "❌ 文件不存在: ai-monitor.swift"
fi

# 2. 尝试 Playgrounds 版本
echo ""
echo "方式 2: Playgrounds 版本"
echo "命令: cd AIMonitor-Playgrounds.swiftpm && swift run"
echo ""

if [ -d "AIMonitor-Playgrounds.swiftpm" ]; then
    echo "✅ 找到目录，尝试运行..."
    cd AIMonitor-Playgrounds.swiftpm
    swift run
    EXIT_CODE=$?
    cd ..
    
    if [ $EXIT_CODE -eq 0 ]; then
        echo "✅ 运行成功！"
        exit 0
    else
        echo "❌ 运行失败，错误码: $EXIT_CODE"
    fi
else
    echo "❌ 目录不存在: AIMonitor-Playgrounds.swiftpm"
fi

# 3. 尝试用 Xcode 打开
echo ""
echo "方式 3: 用 Xcode 打开"
echo ""

if [ -d "/Applications/Xcode.app" ]; then
    echo "✅ 找到 Xcode，正在打开..."
    if [ -d "AI Monitor.xcodeproj" ]; then
        open "AI Monitor.xcodeproj"
        echo "✅ 已打开 Xcode 项目"
        echo "💡 在 Xcode 中按 ⌘R 运行"
    else
        echo "❌ Xcode 项目不存在"
    fi
else
    echo "❌ Xcode 未安装"
fi

echo ""
echo "================================"
echo ""
echo "❌ 所有自动运行方式都失败了"
echo ""
echo "🔧 请尝试以下步骤："
echo ""
echo "1. 确保 Xcode 已安装并完整运行过一次"
echo "2. 在终端中运行: xcode-select --install"
echo "3. 重新克隆项目: git clone https://github.com/castlewuwu/mac_ai_monitor.git"
echo "4. 运行: cd mac_ai_monitor && swift ai-monitor.swift"
echo ""
echo "📖 查看详细文档: cat USE_PLAYGROUNDS.md"
echo ""
echo "================================"