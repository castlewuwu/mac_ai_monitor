#!/bin/bash

# AI Monitor - 状态检查脚本

echo "🪲 AI Monitor - 项目状态检查"
echo "================================"
echo ""

# 检查系统要求
echo "📋 系统环境检查:"
echo ""

# macOS 版本
SW_VERS=$(sw_vers -productVersion 2>/dev/null || echo "未知")
echo "  macOS 版本: $SW_VERS"

# Xcode
if command -v xcodebuild &> /dev/null; then
    XCODE_VERSION=$(xcodebuild -version | head -n 1)
    echo "  ✅ Xcode: $XCODE_VERSION"
else
    echo "  ❌ Xcode: 未安装"
fi

# Swift
if command -v swift &> /dev/null; then
    SWIFT_VERSION=$(swift --version | head -n 1)
    echo "  ✅ Swift: $SWIFT_VERSION"
else
    echo "  ❌ Swift: 未安装"
fi

echo ""

# 检查项目文件
echo "📁 项目文件检查:"
echo ""

# 项目根目录
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

# Xcode 项目
if [ -d "AI Monitor.xcodeproj" ]; then
    echo "  ✅ Xcode 项目文件存在"
else
    echo "  ❌ Xcode 项目文件缺失"
fi

# 源代码文件
SWIFT_COUNT=$(find Sources/AIMonitor -name "*.swift" 2>/dev/null | wc -l)
echo "  Swift 文件数: $SWIFT_COUNT"

if [ "$SWIFT_COUNT" -gt 0 ]; then
    echo "  ✅ 源代码文件完整"
else
    echo "  ❌ 源代码文件缺失"
fi

# 文档文件
DOC_COUNT=$(find . -maxdepth 1 -name "*.md" 2>/dev/null | wc -l)
echo "  文档文件数: $DOC_COUNT"

# 构建脚本
if [ -x "build.sh" ]; then
    echo "  ✅ 构建脚本可执行"
else
    echo "  ⚠️  构建脚本需要 chmod +x"
fi

echo ""

# 代码统计
echo "📊 代码统计:"
echo ""

TOTAL_LINES=$(find Sources/AIMonitor -name "*.swift" -exec wc -l {} + 2>/dev/null | tail -n 1 | awk '{print $1}')
echo "  总代码行数: $TOTAL_LINES 行"

SERVICE_LINES=$(find Sources/AIMonitor/Services -name "*.swift" -exec wc -l {} + 2>/dev/null | tail -n 1 | awk '{print $1}')
echo "  服务层代码: $SERVICE_LINES 行"

VIEW_LINES=$(find Sources/AIMonitor/Views -name "*.swift" -exec wc -l {} + 2>/dev/null | tail -n 1 | awk '{print $1}')
echo "  视图层代码: $VIEW_LINES 行"

echo ""

# 功能列表
echo "✨ 已实现功能:"
echo ""
echo "  ✅ 系统监控 (CPU/内存/网络)"
echo "  ✅ AI 应用检测和监控"
echo "  ✅ 智能提醒系统"
echo "  ✅ 菜单栏应用界面"
echo ""

# 下一步操作
echo "🚀 下一步操作:"
echo ""
echo "  1. 打开项目: ./open-xcode.sh"
echo "  2. 运行应用: 在 Xcode 中按 ⌘R"
echo "  3. 查看文档: cat QUICK_START.md"
echo ""

echo "================================"
echo "✅ 检查完成"