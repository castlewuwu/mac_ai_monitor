#!/bin/bash

# AI Monitor - 一键启动（推荐使用）
# 自动使用 Playgrounds 版本

echo "🪲 AI Monitor - 启动中..."
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 方式一：尝试用 Swift Playgrounds 打开
if [ -d "/Applications/Swift Playgrounds.app" ]; then
    echo "✅ 使用 Swift Playgrounds 打开..."
    open -a "Swift Playgrounds" "$SCRIPT_DIR/AIMonitor-Playgrounds.swiftpm"
    echo "✅ 已打开，点击运行按钮即可使用"
    exit 0
fi

# 方式二：尝试用 Xcode 打开
if [ -d "/Applications/Xcode.app" ]; then
    echo "✅ 使用 Xcode 打开 Playgrounds..."
    open -a "Xcode" "$SCRIPT_DIR/AIMonitor-Playgrounds.swiftpm"
    echo "✅ 已打开，点击运行按钮即可使用"
    exit 0
fi

# 方式三：命令行运行
echo "⚠️  未找到 Swift Playgrounds 或 Xcode"
echo "尝试使用命令行运行..."
cd "$SCRIPT_DIR/AIMonitor-Playgrounds.swiftpm"
swift run

echo ""
echo "💡 提示："
echo "  如果无法运行，请安装 Swift Playgrounds:"
echo "  https://apps.apple.com/app/swift-playgrounds/id1496833156"