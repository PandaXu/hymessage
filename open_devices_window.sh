#!/bin/bash
# 打开 Xcode Devices Window 的脚本

echo "🔍 检查 Xcode 是否安装..."

if [ -d "/Applications/Xcode.app" ]; then
    echo "✅ Xcode 已安装"
    echo ""
    echo "📱 打开 Devices Window 的方法："
    echo "   1. 在 Xcode 中：Window → Devices and Simulators"
    echo "   2. 或按快捷键：⇧⌘2 (Shift + Command + 2)"
    echo ""
    echo "💡 提示："
    echo "   - 确保设备已通过 USB 连接"
    echo "   - 设备已解锁"
    echo "   - 在设备上点击'信任此电脑'"
    echo ""
    
    # 尝试打开 Xcode（如果还没打开）
    if ! pgrep -x "Xcode" > /dev/null; then
        echo "🚀 正在打开 Xcode..."
        open -a Xcode /Users/heytea/HYMessage/HYMessage.xcodeproj
        sleep 2
        echo "✅ Xcode 已打开"
        echo ""
        echo "📝 下一步："
        echo "   在 Xcode 中按 ⇧⌘2 打开 Devices Window"
    else
        echo "✅ Xcode 已在运行"
        echo "📝 请在 Xcode 中按 ⇧⌘2 打开 Devices Window"
    fi
else
    echo "❌ Xcode 未安装"
    echo "请先安装 Xcode"
fi
