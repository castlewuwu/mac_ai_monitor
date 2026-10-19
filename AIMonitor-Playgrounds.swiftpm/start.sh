#!/bin/bash

# AI Monitor - Playgrounds 启动脚本
# 双击即可打开 AI Monitor

echo "🪲 AI Monitor - 启动中..."
echo ""

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="AIMonitor-Playgrounds.swiftpm"
PROJECT_PATH="$SCRIPT_DIR"

# 检查是否是 macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ 错误: 这只能在 macOS 上运行"
    echo "当前系统: $OSTYPE"
    exit 1
fi

# 检查 Swift Playgrounds 是否安装
PLAYGROUNDS_PATH="/Applications/Swift Playgrounds.app"
XCODE_PATH="/Applications/Xcode.app"

if [ -d "$PLAYGROUNDS_PATH" ]; then
    echo "✅ 使用 Swift Playgrounds 打开..."
    open -a "Swift Playgrounds" "$PROJECT_PATH"
elif [ -d "$XCODE_PATH" ]; then
    echo "✅ 使用 Xcode 打开..."
    open -a "Xcode" "$PROJECT_PATH"
else
    echo "⚠️  未找到 Swift Playgrounds 或 Xcode"
    echo ""
    echo "请安装其中一个:"
    echo "  1. Swift Playgrounds (推荐): https://apps.apple.com/app/swift-playgrounds/id1496833156"
    echo "  2. Xcode: https://apps.apple.com/app/xcode/id497799835"
    echo ""
    echo "或者使用命令行运行:"
    echo "  cd \"$PROJECT_PATH\""
    echo "  swift run"
    exit 1
fi

echo ""
echo "✅ 项目已打开"
echo "💡 在应用中点击 ▶️ 按钮运行"
echo ""