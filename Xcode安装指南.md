# Xcode 安装指南

## 📋 系统信息
- **macOS 版本**: macOS 15.1 (Sequoia)
- **当前状态**: 已安装命令行工具，需要安装完整 Xcode

## 🚀 安装方法

### 方法一：从 App Store 安装（推荐）

这是最简单和推荐的方法：

1. **打开 App Store**
   - 点击 Dock 中的 App Store 图标
   - 或按 `⌘ + 空格` 搜索 "App Store"

2. **搜索 Xcode**
   - 在搜索框中输入 "Xcode"
   - 点击第一个结果（Apple 官方应用）

3. **下载安装**
   - 点击 "获取" 或 "安装" 按钮
   - 输入 Apple ID 密码（如果需要）
   - 等待下载完成（Xcode 约 12-15 GB，需要较长时间）

4. **首次启动配置**
   - 安装完成后，打开 Xcode
   - 接受许可协议
   - 等待安装额外组件（约 5-10 分钟）

### 方法二：从 Apple Developer 网站下载

如果 App Store 下载较慢，可以从开发者网站下载：

1. **访问 Apple Developer**
   - 打开浏览器访问：https://developer.apple.com/download/
   - 使用 Apple ID 登录

2. **下载 Xcode**
   - 找到最新版本的 Xcode
   - 点击下载（需要登录开发者账号）

3. **安装**
   - 下载完成后，双击 `.xip` 文件
   - 等待解压（可能需要几分钟）
   - 将 Xcode 拖拽到 Applications 文件夹

### 方法三：使用命令行（需要先安装 mas-cli）

```bash
# 安装 mas-cli（Mac App Store 命令行工具）
brew install mas

# 登录 App Store（需要输入 Apple ID）
mas signin your@email.com

# 搜索 Xcode 的 ID
mas search Xcode

# 安装 Xcode（ID: 497799835）
mas install 497799835
```

**注意**: 不推荐此方法，因为 Xcode 文件很大，命令行下载可能不稳定。

## ⚙️ 安装后配置

### 1. 接受许可协议

```bash
sudo xcodebuild -license accept
```

### 2. 安装命令行工具

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### 3. 安装额外组件

打开 Xcode，会自动提示安装：
- iOS Simulator
- 其他开发工具

### 4. 验证安装

```bash
# 检查 Xcode 版本
xcodebuild -version

# 检查命令行工具路径
xcode-select -p
# 应该显示: /Applications/Xcode.app/Contents/Developer
```

## 📦 系统要求

- **macOS**: macOS 13.0 (Ventura) 或更高版本
- **磁盘空间**: 至少 20 GB 可用空间（推荐 30 GB+）
- **内存**: 建议 8 GB 或更多
- **网络**: 稳定的网络连接（下载约 12-15 GB）

## ⏱️ 预计时间

- **下载时间**: 30 分钟 - 2 小时（取决于网络速度）
- **安装时间**: 10-20 分钟
- **首次配置**: 5-10 分钟
- **总计**: 约 1-3 小时

## 🔧 常见问题

### 1. 下载速度慢
- 使用稳定的 Wi-Fi 连接
- 考虑在非高峰时段下载
- 或使用 Apple Developer 网站下载

### 2. 磁盘空间不足
- 清理系统缓存和临时文件
- 删除不需要的应用
- 确保至少有 20 GB 可用空间

### 3. 安装失败
- 检查网络连接
- 重启 Mac 后重试
- 确保 macOS 版本符合要求

### 4. 许可协议问题
```bash
# 如果遇到许可协议问题，运行：
sudo xcodebuild -license accept
```

## ✅ 安装完成检查清单

安装完成后，运行以下命令验证：

```bash
# 1. 检查 Xcode 版本
xcodebuild -version

# 2. 检查命令行工具路径
xcode-select -p

# 3. 检查 Swift 版本
swift --version

# 4. 列出可用模拟器
xcrun simctl list devices
```

所有命令都应该正常执行，没有错误。

## 🎯 下一步

安装完成后，你可以：

1. **打开项目**
   ```bash
   cd /Users/heytea/HYMessage
   open HYMessage.xcodeproj
   ```

2. **运行项目**
   - 在 Xcode 中选择模拟器
   - 点击运行按钮（⌘R）

3. **开始开发**
   - 查看 `运行指南.md` 了解详细步骤

---

**提示**: 如果 App Store 下载太慢，可以考虑：
- 使用 Apple Developer 网站下载（需要开发者账号）
- 或使用其他网络环境

安装完成后告诉我，我可以帮你验证安装并运行项目！

