#!/bin/bash
# GitHub 推送脚本

echo "🚀 准备推送到 GitHub..."
echo ""
echo "请选择身份验证方式："
echo "1. 使用 Personal Access Token (HTTPS)"
echo "2. 使用 SSH"
echo ""
read -p "请选择 (1 或 2): " choice

cd /Users/heytea/HYMessage

if [ "$choice" = "1" ]; then
    echo ""
    echo "📝 使用 Personal Access Token 方式"
    echo ""
    echo "如果还没有 Token，请访问："
    echo "https://github.com/settings/tokens"
    echo ""
    echo "然后运行："
    echo "git push -u origin main"
    echo "用户名：PandaXu"
    echo "密码：你的 Personal Access Token"
    echo ""
    read -p "按 Enter 继续推送..." 
    git push -u origin main
    
elif [ "$choice" = "2" ]; then
    echo ""
    echo "📝 使用 SSH 方式"
    echo ""
    
    # 检查 SSH 密钥
    if [ ! -f ~/.ssh/id_ed25519 ] && [ ! -f ~/.ssh/id_rsa ]; then
        echo "⚠️  未找到 SSH 密钥，正在生成..."
        ssh-keygen -t ed25519 -C "github-hymessage"
        echo ""
        echo "✅ SSH 密钥已生成"
        echo ""
        echo "📋 请将以下公钥添加到 GitHub："
        echo "https://github.com/settings/keys"
        echo ""
        cat ~/.ssh/id_ed25519.pub
        echo ""
        read -p "添加完成后按 Enter 继续..."
    fi
    
    # 更改远程 URL
    git remote set-url origin git@github.com:PandaXu/hymessage.git
    
    # 测试连接
    echo "🔍 测试 SSH 连接..."
    ssh -T git@github.com 2>&1 | head -3
    
    # 推送
    echo ""
    echo "🚀 推送代码..."
    git push -u origin main
    
else
    echo "❌ 无效选择"
    exit 1
fi

echo ""
echo "✅ 完成！"
