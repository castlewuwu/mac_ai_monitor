#!/bin/bash

# AI Monitor - 项目文件自检脚本（跨平台）
# 只检查文件结构和代码逻辑，不尝试编译

echo "🪲 AI Monitor - 项目文件自检"
echo "================================"
echo ""

# 项目根目录
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查函数
check_pass() {
    echo -e "${GREEN}✅ $1${NC}"
}

check_fail() {
    echo -e "${RED}❌ $1${NC}"
}

check_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

check_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 1. 项目结构检查
echo "📁 1. 项目结构检查"
echo "--------------------------------"

if [ -d "AI Monitor.xcodeproj" ]; then
    check_pass "Xcode 项目文件存在"
else
    check_fail "Xcode 项目文件缺失"
fi

if [ -f "Package.swift" ]; then
    check_pass "Package.swift 存在"
else
    check_fail "Package.swift 缺失"
fi

if [ -d "Sources/AIMonitor" ]; then
    check_pass "源代码目录存在"
else
    check_fail "源代码目录缺失"
fi

echo ""

# 2. 核心文件检查
echo "📄 2. 核心文件检查"
echo "--------------------------------"

CORE_OK=0
CORE_TOTAL=0

# main.swift
CORE_TOTAL=$((CORE_TOTAL + 1))
if [ -f "Sources/AIMonitor/main.swift" ]; then
    check_pass "程序入口 (main.swift)"
    CORE_OK=$((CORE_OK + 1))
else
    check_fail "程序入口 (main.swift) 缺失"
fi

# AppDelegate.swift
CORE_TOTAL=$((CORE_TOTAL + 1))
if [ -f "Sources/AIMonitor/AppDelegate.swift" ]; then
    check_pass "应用委托 (AppDelegate.swift)"
    CORE_OK=$((CORE_OK + 1))
else
    check_fail "应用委托 (AppDelegate.swift) 缺失"
fi

# ContentView.swift
CORE_TOTAL=$((CORE_TOTAL + 1))
if [ -f "Sources/AIMonitor/Views/ContentView.swift" ]; then
    check_pass "主视图 (ContentView.swift)"
    CORE_OK=$((CORE_OK + 1))
else
    check_fail "主视图 (ContentView.swift) 缺失"
fi

# SystemMonitor.swift
CORE_TOTAL=$((CORE_TOTAL + 1))
if [ -f "Sources/AIMonitor/Services/SystemMonitor.swift" ]; then
    check_pass "系统监控 (SystemMonitor.swift)"
    CORE_OK=$((CORE_OK + 1))
else
    check_fail "系统监控 (SystemMonitor.swift) 缺失"
fi

# AIAppMonitor.swift
CORE_TOTAL=$((CORE_TOTAL + 1))
if [ -f "Sources/AIMonitor/Services/AIAppMonitor.swift" ]; then
    check_pass "AI应用监控 (AIAppMonitor.swift)"
    CORE_OK=$((CORE_OK + 1))
else
    check_fail "AI应用监控 (AIAppMonitor.swift) 缺失"
fi

# NotificationManager.swift
CORE_TOTAL=$((CORE_TOTAL + 1))
if [ -f "Sources/AIMonitor/Services/NotificationManager.swift" ]; then
    check_pass "通知管理 (NotificationManager.swift)"
    CORE_OK=$((CORE_OK + 1))
else
    check_fail "通知管理 (NotificationManager.swift) 缺失"
fi

# AlertEngine.swift
CORE_TOTAL=$((CORE_TOTAL + 1))
if [ -f "Sources/AIMonitor/Services/AlertEngine.swift" ]; then
    check_pass "智能提醒 (AlertEngine.swift)"
    CORE_OK=$((CORE_OK + 1))
else
    check_fail "智能提醒 (AlertEngine.swift) 缺失"
fi

# Info.plist
CORE_TOTAL=$((CORE_TOTAL + 1))
if [ -f "Sources/AIMonitor/Resources/Info.plist" ]; then
    check_pass "应用配置 (Info.plist)"
    CORE_OK=$((CORE_OK + 1))
else
    check_fail "应用配置 (Info.plist) 缺失"
fi

echo ""

# 3. 代码逻辑检查
echo "🔍 3. 代码逻辑检查"
echo "--------------------------------"

# ContentView 检查
if [ -f "Sources/AIMonitor/Views/ContentView.swift" ]; then
    if grep -q "@ObservedObject" "Sources/AIMonitor/Views/ContentView.swift" 2>/dev/null; then
        check_pass "ContentView 使用 @ObservedObject（正确）"
    else
        check_fail "ContentView 应使用 @ObservedObject"
    fi
fi

# AppDelegate 检查
if [ -f "Sources/AIMonitor/AppDelegate.swift" ]; then
    if grep -q "ContentView(" "Sources/AIMonitor/AppDelegate.swift" 2>/dev/null; then
        check_pass "AppDelegate 正确传递监控器实例"
    else
        check_fail "AppDelegate 未传递监控器实例"
    fi
    
    if grep -q "applicationWillTerminate" "Sources/AIMonitor/AppDelegate.swift" 2>/dev/null; then
        check_pass "生命周期管理完整"
    else
        check_warn "建议添加 applicationWillTerminate 方法"
    fi
fi

# AlertEngine 检查
if [ -f "Sources/AIMonitor/Services/AlertEngine.swift" ]; then
    if grep -q "weak var" "Sources/AIMonitor/Services/AlertEngine.swift" 2>/dev/null; then
        check_pass "AlertEngine 使用弱引用（避免循环引用）"
    else
        check_fail "AlertEngine 应使用 weak 引用监控器"
    fi
    
    if grep -q "setMonitors" "Sources/AIMonitor/Services/AlertEngine.swift" 2>/dev/null; then
        check_pass "AlertEngine 有配置方法"
    else
        check_warn "AlertEngine 缺少配置方法"
    fi
fi

echo ""

# 4. 配置文件检查
echo "⚙️  4. 配置文件检查"
echo "--------------------------------"

if [ -f "Sources/AIMonitor/Resources/Info.plist" ]; then
    if grep -q "LSUIElement" "Sources/AIMonitor/Resources/Info.plist" 2>/dev/null; then
        check_pass "LSUIElement 设置（不显示在 Dock）"
    else
        check_fail "Info.plist 缺少 LSUIElement 配置"
    fi
else
    check_fail "Info.plist 缺失"
fi

if [ -f ".gitignore" ]; then
    check_pass ".gitignore 存在"
else
    check_warn ".gitignore 缺失"
fi

echo ""

# 5. 文档检查
echo "📚 5. 文档检查"
echo "--------------------------------"

DOC_OK=0
DOC_TOTAL=0

DOC_TOTAL=$((DOC_TOTAL + 1))
if [ -f "README.md" ]; then
    check_pass "项目说明"
    DOC_OK=$((DOC_OK + 1))
else
    check_warn "项目说明缺失"
fi

DOC_TOTAL=$((DOC_TOTAL + 1))
if [ -f "QUICK_START.md" ]; then
    check_pass "快速入门"
    DOC_OK=$((DOC_OK + 1))
else
    check_warn "快速入门缺失"
fi

DOC_TOTAL=$((DOC_TOTAL + 1))
if [ -f "DEVELOPMENT.md" ]; then
    check_pass "开发指南"
    DOC_OK=$((DOC_OK + 1))
else
    check_warn "开发指南缺失"
fi

DOC_TOTAL=$((DOC_TOTAL + 1))
if [ -f "TECHNICAL_DESIGN.md" ]; then
    check_pass "技术设计"
    DOC_OK=$((DOC_OK + 1))
else
    check_warn "技术设计缺失"
fi

DOC_TOTAL=$((DOC_TOTAL + 1))
if [ -f "CODE_REVIEW.md" ]; then
    check_pass "代码审查"
    DOC_OK=$((DOC_OK + 1))
else
    check_warn "代码审查缺失"
fi

DOC_TOTAL=$((DOC_TOTAL + 1))
if [ -f "PROJECT_SUMMARY.md" ]; then
    check_pass "项目总结"
    DOC_OK=$((DOC_OK + 1))
else
    check_warn "项目总结缺失"
fi

echo ""

# 6. 构建工具检查
echo "🛠️  6. 构建工具检查"
echo "--------------------------------"

if [ -x "build.sh" ]; then
    check_pass "build.sh 可执行"
else
    check_warn "build.sh 需要 chmod +x"
fi

if [ -x "open-xcode.sh" ]; then
    check_pass "open-xcode.sh 可执行"
else
    check_warn "open-xcode.sh 需要 chmod +x"
fi

if [ -x "check-project.sh" ]; then
    check_pass "check-project.sh 可执行"
else
    check_warn "check-project.sh 需要 chmod +x"
fi

echo ""

# 7. 代码统计
echo "📊 7. 代码统计"
echo "--------------------------------"

SWIFT_COUNT=$(find Sources/AIMonitor -name "*.swift" 2>/dev/null | wc -l | tr -d ' ')
echo -e "  Swift 文件: ${GREEN}$SWIFT_COUNT${NC} 个"

if [ "$SWIFT_COUNT" -gt 0 ]; then
    TOTAL_LINES=$(find Sources/AIMonitor -name "*.swift" -exec cat {} \; 2>/dev/null | wc -l | tr -d ' ')
    echo -e "  总代码行数: ${GREEN}$TOTAL_LINES${NC} 行"
    
    SERVICE_LINES=$(find Sources/AIMonitor/Services -name "*.swift" -exec cat {} \; 2>/dev/null | wc -l | tr -d ' ')
    echo -e "  服务层代码: ${GREEN}$SERVICE_LINES${NC} 行"
    
    VIEW_LINES=$(find Sources/AIMonitor/Views -name "*.swift" -exec cat {} \; 2>/dev/null | wc -l | tr -d ' ')
    echo -e "  视图层代码: ${GREEN}$VIEW_LINES${NC} 行"
else
    check_fail "未找到 Swift 文件"
fi

DOC_LINES=$(find . -maxdepth 1 -name "*.md" -exec cat {} \; 2>/dev/null | wc -l | tr -d ' ')
echo -e "  文档总行数: ${GREEN}$DOC_LINES${NC} 行"

echo ""

# 8. 功能完成度
echo "✨ 8. 功能完成度"
echo "--------------------------------"

echo "  已实现功能:"
echo "    ✅ 系统监控（CPU/内存/网络）"
echo "    ✅ AI 应用检测"
echo "    ✅ 智能提醒系统"
echo "    ✅ 菜单栏 UI"
echo "    ✅ 下拉面板 UI"
echo ""
echo "  待实现功能:"
echo "    ⏳ 设置面板"
echo "    ⏳ GPU 监控"
echo "    ⏳ 历史数据"
echo "    ⏳ 多语言支持"

echo ""

# 9. 最终结果
echo "================================"
echo ""

if [ "$CORE_OK" -eq "$CORE_TOTAL" ]; then
    echo -e "${GREEN}✅ 项目文件自检通过！${NC}"
    echo ""
    echo -e "  核心文件: ${GREEN}$CORE_OK/$CORE_TOTAL${NC}"
    echo -e "  文档文件: ${GREEN}$DOC_OK/$DOC_TOTAL${NC}"
    echo -e "  代码行数: ${GREEN}$TOTAL_LINES${NC} 行"
    echo ""
    check_info "这是 macOS 项目，需要在 macOS 系统上编译运行"
    echo ""
    echo "🚀 在 macOS 上运行："
    echo "  1. 传输项目到 Mac"
    echo "  2. 打开项目: ./open-xcode.sh"
    echo "  3. 运行应用: 在 Xcode 中按 ⌘R"
else
    echo -e "${YELLOW}⚠️  项目文件自检发现问题${NC}"
    echo ""
    echo -e "  核心文件: ${YELLOW}$CORE_OK/$CORE_TOTAL${NC}"
    echo -e "  文档文件: ${YELLOW}$DOC_OK/$DOC_TOTAL${NC}"
    echo ""
    echo "💡 建议："
    echo "  1. 检查缺失的核心文件"
    echo "  2. 参考 CODE_REVIEW.md 修复问题"
    echo "  3. 重新运行自检: ./check-project.sh"
fi

echo ""
echo "================================"
echo "自检完成 - $(date '+%Y-%m-%d %H:%M:%S')"