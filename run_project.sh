#!/bin/bash
# HYMessage 项目运行脚本

echo "🔍 检查运行环境..."

# 检查 Xcode
if [ -d "/Applications/Xcode.app" ]; then
    echo "✅ Xcode 已安装"
    
    # 配置路径
    echo "⚙️  配置 Xcode 路径..."
    sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer 2>/dev/null
    
    # 检查版本
    XCODE_VERSION=$(xcodebuild -version 2>/dev/null | head -1)
    echo "📱 $XCODE_VERSION"
    
    # 打开项目
    echo "🚀 打开项目..."
    cd "$(dirname "$0")"
    open HYMessage.xcodeproj
    
    echo ""
    echo "✅ 项目已打开！"
    echo "📝 下一步："
    echo "   1. 在 Xcode 顶部选择 iOS 模拟器（如 iPhone 15 Pro）"
    echo "   2. 点击运行按钮（▶️）或按 ⌘R"
    echo ""
else
    echo "❌ Xcode 未安装"
    echo ""
    echo "📋 需要先安装 Xcode："
    echo "   1. 确保 macOS 版本 ≥ 15.6"
    echo "   2. 从 App Store 安装 Xcode"
    echo ""
    echo "🔗 正在打开 App Store..."
    open -a "App Store"
    
    echo ""
    echo "💡 提示："
    echo "   - 如果 macOS 版本不够，请先升级系统"
    echo "   - 查看 '升级macOS指南.md' 了解详情"
fi
