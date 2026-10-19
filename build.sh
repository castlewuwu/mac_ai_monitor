#!/bin/bash

# AI Monitor - 快速构建脚本

set -e

echo "==================================="
echo "  AI Monitor - 构建工具"
echo "==================================="
echo ""

# 检查 Xcode 是否安装
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ 错误: 未找到 Xcode，请先安装 Xcode"
    exit 1
fi

# 项目根目录
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

# 构建配置
CONFIGURATION="Debug"
SCHEME="AI Monitor"
PROJECT_NAME="AI Monitor.xcodeproj"

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --release)
            CONFIGURATION="Release"
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --run)
            RUN=true
            shift
            ;;
        --help)
            echo "使用方法: $0 [选项]"
            echo ""
            echo "选项:"
            echo "  --release    构建 Release 版本"
            echo "  --clean      清理构建缓存"
            echo "  --run        构建后运行应用"
            echo "  --help       显示帮助信息"
            exit 0
            ;;
        *)
            echo "未知选项: $1"
            exit 1
            ;;
    esac
done

echo "📦 配置: $CONFIGURATION"
echo "🏗️  项目: $PROJECT_NAME"
echo ""

# 清理
if [ "$CLEAN" = true ]; then
    echo "🧹 清理构建缓存..."
    xcodebuild clean \
        -project "$PROJECT_NAME" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION"
    echo "✅ 清理完成"
    echo ""
fi

# 构建
echo "🔨 开始构建..."
xcodebuild build \
    -project "$PROJECT_NAME" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    | xcpretty --color 2>/dev/null || xcodebuild build \
    -project "$PROJECT_NAME" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION"

BUILD_STATUS=$?

echo ""

if [ $BUILD_STATUS -eq 0 ]; then
    echo "✅ 构建成功!"
    
    # 显示构建产物位置
    BUILD_DIR="$PROJECT_DIR/build/$CONFIGURATION"
    if [ -d "$BUILD_DIR" ]; then
        APP_PATH=$(find "$BUILD_DIR" -name "AI Monitor.app" -type d | head -n 1)
        if [ -n "$APP_PATH" ]; then
            echo "📍 应用位置: $APP_PATH"
            echo ""
            
            # 运行应用
            if [ "$RUN" = true ]; then
                echo "🚀 启动应用..."
                open "$APP_PATH"
            fi
        fi
    fi
else
    echo "❌ 构建失败"
    exit 1
fi

echo ""
echo "==================================="
echo "  构建完成"
echo "==================================="