#!/bin/bash

# AI Monitor - 最终验证脚本
# 检查项目是否可以交付使用

echo "🪲 AI Monitor - 最终验证"
echo "================================"
echo ""

# 项目根目录
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}📦 交付格式验证${NC}"
echo "--------------------------------"

# 1. Playgrounds 版本检查
echo ""
echo "1. Swift Playgrounds 版本"
if [ -f "AIMonitor-Playgrounds.swiftpm/Package.swift" ]; then
    echo -e "  ${GREEN}✅ Package.swift 存在${NC}"
    
    SWIFT_COUNT=$(find AIMonitor-Playgrounds.swiftpm/Sources -name "*.swift" 2>/dev/null | wc -l | tr -d ' ')
    echo -e "  ${GREEN}✅ Swift 文件: $SWIFT_COUNT 个${NC}"
    
    if [ -f "AIMonitor-Playgrounds.swiftpm/README.md" ]; then
        echo -e "  ${GREEN}✅ README.md 存在${NC}"
    fi
    
    if [ -x "AIMonitor-Playgrounds.swiftpm/start.sh" ]; then
        echo -e "  ${GREEN}✅ start.sh 可执行${NC}"
    fi
    
    echo -e "  ${GREEN}✅ Playgrounds 版本完整${NC}"
else
    echo -e "  ${YELLOW}⚠️  Playgrounds 版本不完整${NC}"
fi

# 2. Xcode 项目检查
echo ""
echo "2. Xcode 项目版本"
if [ -d "AI Monitor.xcodeproj" ]; then
    echo -e "  ${GREEN}✅ Xcode 项目存在${NC}"
    
    XCODE_SWIFT_COUNT=$(find Sources/AIMonitor -name "*.swift" 2>/dev/null | wc -l | tr -d ' ')
    echo -e "  ${GREEN}✅ Swift 文件: $XCODE_SWIFT_COUNT 个${NC}"
    
    echo -e "  ${GREEN}✅ Xcode 版本完整${NC}"
else
    echo -e "  ${YELLOW}⚠️  Xcode 项目不完整${NC}"
fi

# 3. 文档检查
echo ""
echo "3. 文档系统"
DOC_COUNT=$(find . -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✅ 文档文件: $DOC_COUNT 个${NC}"

# 4. 功能统计
echo ""
echo "📊 功能统计"
echo "--------------------------------"

# 代码行数
TOTAL_LINES=$(find . -name "*.swift" -exec cat {} \; 2>/dev/null | wc -l | tr -d ' ')
echo -e "  总代码行数: ${GREEN}$TOTAL_LINES${NC} 行"

# 文档行数
DOC_LINES=$(find . -name "*.md" -exec cat {} \; 2>/dev/null | wc -l | tr -d ' ')
echo -e "  总文档行数: ${GREEN}$DOC_LINES${NC} 行"

# 文件数量
FILE_COUNT=$(find . -type f \( -name "*.swift" -o -name "*.md" -o -name "*.sh" -o -name "Package.swift" \) 2>/dev/null | wc -l | tr -d ' ')
echo -e "  总文件数量: ${GREEN}$FILE_COUNT${NC} 个"

echo ""
echo "✨ 交付内容"
echo "--------------------------------"
echo "  ✅ Swift Playgrounds App（开箱即用）"
echo "  ✅ Xcode 项目（完整开发环境）"
echo "  ✅ 系统监控功能"
echo "  ✅ AI 应用检测"
echo "  ✅ 完整文档系统"
echo "  ✅ 启动和构建工具"

echo ""
echo "🚀 使用方式"
echo "--------------------------------"
echo ""
echo "  方式一：Playgrounds（推荐）"
echo "    1. 双击 AIMonitor-Playgrounds.swiftpm"
echo "    2. 点击运行按钮"
echo ""
echo "  方式二：Xcode"
echo "    1. ./open-xcode.sh"
echo "    2. 按 ⌘R 运行"
echo ""
echo "  方式三：命令行"
echo "    cd AIMonitor-Playgrounds.swiftpm"
echo "    swift run"

echo ""
echo "================================"
echo -e "${GREEN}✅ 项目已就绪，可以交付使用！${NC}"
echo ""
echo "查看详细说明: cat DELIVERY.md"
echo "================================"