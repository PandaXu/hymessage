# macOS 升级指南

## ✅ 好消息

系统检测到有可用的 macOS 更新：
- **macOS Sequoia 15.7.2** (约 6.4 GB) - **推荐升级此版本**
- **macOS Tahoe 26.1** (约 9.3 GB) - 未来版本

升级到 **macOS 15.7.2** 后，就可以安装最新版本的 Xcode 了！

## 🚀 升级步骤

### 方法一：使用命令行（快速）

```bash
# 升级到 macOS 15.7.2
sudo softwareupdate --install "macOS Sequoia 15.7.2-24G325"

# 或者升级所有可用更新
sudo softwareupdate --install --all
```

**注意**: 需要管理员密码，升级过程可能需要 30-60 分钟。

### 方法二：使用系统设置（推荐，更安全）

1. **打开系统设置**
   - 点击苹果菜单 → 系统设置
   - 或运行：`open "x-apple.systempreferences:com.apple.preferences.softwareupdate"`

2. **检查更新**
   - 点击"通用" → "软件更新"
   - 系统会自动检查可用更新

3. **开始升级**
   - 找到 "macOS Sequoia 15.7.2"
   - 点击"立即升级"或"现在升级"
   - 输入管理员密码

4. **等待完成**
   - 下载时间：根据网络速度，约 10-30 分钟
   - 安装时间：约 20-40 分钟
   - 系统会自动重启

## ⚠️ 升级前准备

### 1. 备份重要数据
```bash
# 检查 Time Machine 是否开启
tmutil listlocalsnapshots /
```

### 2. 确保有足够空间
- 需要至少 **15-20 GB** 可用空间
- 检查磁盘空间：
```bash
df -h /
```

### 3. 关闭正在运行的应用
- 保存所有工作
- 关闭不必要的应用

### 4. 连接电源（如果是笔记本）
- 确保 MacBook 连接电源适配器
- 避免升级过程中断电

## 📋 升级过程

1. **下载阶段** (10-30 分钟)
   - 系统在后台下载更新
   - 可以继续使用电脑

2. **准备安装** (5-10 分钟)
   - 系统提示重启
   - 保存所有工作

3. **安装阶段** (20-40 分钟)
   - Mac 会重启
   - 显示进度条
   - **不要中断此过程**

4. **完成**
   - 自动重启
   - 可能需要输入密码
   - 验证升级成功

## ✅ 验证升级

升级完成后，验证版本：

```bash
sw_vers
```

应该显示：
```
ProductVersion: 15.7.2
```

## 🎯 升级后操作

升级完成后：

1. **安装 Xcode**
   ```bash
   # 从 App Store 安装 Xcode
   open -a "App Store"
   # 搜索并安装 Xcode
   ```

2. **配置 Xcode**
   ```bash
   # 接受许可协议
   sudo xcodebuild -license accept
   
   # 设置命令行工具
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   
   # 验证
   xcodebuild -version
   ```

3. **运行项目**
   ```bash
   cd /Users/heytea/HYMessage
   open HYMessage.xcodeproj
   ```

## 🔧 如果遇到问题

### 升级失败
- 检查网络连接
- 确保有足够磁盘空间
- 重启后重试

### 升级后无法启动
- 按住 Option 键启动，选择恢复模式
- 或使用 Time Machine 恢复

### 需要帮助
升级过程中如有问题，可以：
1. 查看系统日志
2. 联系 Apple 支持
3. 或告诉我具体情况

## ⏱️ 预计时间

- **下载**: 10-30 分钟（取决于网络）
- **安装**: 20-40 分钟
- **总计**: 约 30-70 分钟

## 💡 建议

1. **选择合适的时间**: 在不需要使用电脑时进行升级
2. **保持连接**: 确保网络连接稳定
3. **耐心等待**: 不要中断升级过程

---

**下一步**: 
1. 选择升级方法（推荐使用系统设置）
2. 开始升级
3. 升级完成后告诉我，我可以帮你安装和配置 Xcode

