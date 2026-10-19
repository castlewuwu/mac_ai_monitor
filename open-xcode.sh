#!/bin/bash

# AI Monitor - 快速打开 Xcode 项目

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "🪲 AI Monitor - 打开 Xcode 项目..."

if [ -d "AI Monitor.xcodeproj" ]; then
    open "AI Monitor.xcodeproj"
    echo "✅ Xcode 项目已打开"
else
    echo "❌ 错误: 未找到 Xcode 项目文件"
    echo "   正在尝试使用 Swift Package Manager..."
    
    if command -v swift &> /dev/null; then
        echo "🔨 使用 SPM 构建..."
        swift build
        echo "🚀 运行应用..."
        swift run
    else
        echo "❌ 错误: 未找到 Swift 编译器"
        exit 1
    fi
fi