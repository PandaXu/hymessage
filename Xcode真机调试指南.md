# Xcode 真机调试完整指南

## 📱 准备工作

### 1. 系统要求
- ✅ macOS 系统
- ✅ Xcode 已安装
- ✅ iOS 设备（iPhone/iPad）
- ✅ USB 数据线

### 2. 开发者账号
- **免费账号**：可以使用，但有 7 天限制
- **付费账号**（$99/年）：无限制，可发布到 App Store

## 🚀 详细步骤

### 步骤 1: 连接 iOS 设备

1. **使用 USB 数据线连接设备到 Mac**
   - 使用原装或 MFi 认证的数据线
   - 确保数据线支持数据传输（不只是充电）

2. **在设备上信任此电脑**
   - 设备上会弹出提示："要信任此电脑吗？"
   - 点击"信任"
   - 输入设备密码确认

3. **解锁设备**
   - 保持设备解锁状态
   - 如果设备锁屏，Xcode 可能无法识别

### 步骤 2: 在 Xcode 中配置项目

1. **打开项目**
   ```bash
   cd /Users/heytea/HYMessage
   open HYMessage.xcodeproj
   ```

2. **选择项目文件**
   - 在左侧项目导航器中，点击最顶部的 "HYMessage" 项目（蓝色图标）
   - 选择 "HYMessage" Target

3. **配置签名和功能**
   - 点击 "Signing & Capabilities" 标签
   - 勾选 "Automatically manage signing"
   - 选择你的 Team（Apple ID）

### 步骤 3: 选择开发者账号（Team）

1. **添加 Apple ID**
   - 如果没有 Team，点击 "Add Account..."
   - 输入你的 Apple ID 和密码
   - Xcode 会自动下载证书

2. **选择 Team**
   - 在 "Team" 下拉菜单中选择你的账号
   - 如果是免费账号，会显示 "Personal Team"

3. **Bundle Identifier**
   - 确保 Bundle Identifier 是唯一的
   - 当前：`com.hytea.HYMessage`
   - 如果冲突，可以改为：`com.yourname.HYMessage`

### 步骤 4: 在设备上启用开发者模式

1. **首次连接时**
   - 设备上会提示："需要开发者模式"
   - 前往：设置 → 隐私与安全性 → 开发者模式
   - 开启"开发者模式"
   - 重启设备

2. **信任开发者证书**
   - 首次运行时，设备会提示："未受信任的企业级开发者"
   - 前往：设置 → 通用 → VPN与设备管理（或"描述文件与设备管理"）
   - 找到你的开发者证书
   - 点击"信任 [你的名字]"

### 步骤 5: 选择设备并运行

1. **选择设备**
   - 在 Xcode 顶部工具栏，点击设备选择器
   - 选择你连接的 iOS 设备（会显示设备名称，如 "iPhone 15 Pro"）

2. **运行项目**
   - 点击运行按钮（▶️）
   - 或按快捷键 `⌘R`

3. **等待安装**
   - Xcode 会编译项目
   - 自动安装到设备
   - 应用会自动启动

## ⚙️ 详细配置说明

### 签名配置（Signing & Capabilities）

```
项目设置 → Target "HYMessage" → Signing & Capabilities

✅ Automatically manage signing
Team: [你的 Apple ID]
Bundle Identifier: com.hytea.HYMessage
```

### 设备选择

在 Xcode 顶部工具栏：
```
[设备选择器] ▶️ [运行按钮]

点击设备选择器，会看到：
- iPhone 15 Pro (已连接)
- iPhone 14 (模拟器)
- iPad Pro (模拟器)
- ...
```

## 🔧 常见问题解决

### 问题 1: 设备未显示在列表中

**解决方案**：
```bash
# 1. 检查设备连接
system_profiler SPUSBDataType | grep -i iphone

# 2. 重启 Xcode
# 3. 重新插拔 USB 线
# 4. 检查设备是否解锁
# 5. 在设备上点击"信任此电脑"
```

### 问题 2: "No signing certificate found"

**解决方案**：
1. 确保已登录 Apple ID
2. 在 Xcode → Preferences → Accounts 中添加账号
3. 点击 "Download Manual Profiles"
4. 重新选择 Team

### 问题 3: "Failed to register bundle identifier"

**解决方案**：
1. 修改 Bundle Identifier 为唯一值
   - 例如：`com.yourname.HYMessage`
2. 或使用付费开发者账号

### 问题 4: "Developer Mode is disabled"

**解决方案**：
1. 设备：设置 → 隐私与安全性 → 开发者模式
2. 开启开发者模式
3. 重启设备

### 问题 5: "Untrusted Developer"

**解决方案**：
1. 设备：设置 → 通用 → VPN与设备管理
2. 找到你的开发者证书
3. 点击"信任"

### 问题 6: 应用安装后立即崩溃

**解决方案**：
1. 检查 Xcode 控制台的错误信息
2. 确保 Bundle Identifier 正确
3. 检查 Info.plist 配置
4. 清理构建：Product → Clean Build Folder

## 📋 快速检查清单

在运行前，确保：

- [ ] iOS 设备已通过 USB 连接到 Mac
- [ ] 设备已解锁
- [ ] 设备上已信任此电脑
- [ ] 开发者模式已开启（iOS 16+）
- [ ] Xcode 中已选择正确的 Team
- [ ] Bundle Identifier 是唯一的
- [ ] 设备已显示在 Xcode 的设备列表中
- [ ] 设备系统版本 ≥ iOS 17.0（项目要求）

## 🎯 快速命令

### 检查连接的设备
```bash
# 列出所有连接的设备
xcrun xctrace list devices

# 或使用 instruments
instruments -s devices
```

### 查看设备日志
```bash
# 实时查看设备日志
xcrun simctl spawn booted log stream --level=debug
```

## 💡 提示

1. **免费账号限制**
   - 应用 7 天后会过期
   - 需要重新安装
   - 最多可安装 3 个应用

2. **付费账号优势**
   - 无时间限制
   - 可安装更多应用
   - 可发布到 App Store
   - 可使用更多功能（如 Push Notification）

3. **无线调试**（iOS 15+）
   - 首次需要 USB 连接
   - 之后可以在同一 Wi-Fi 下无线调试
   - Window → Devices and Simulators → 启用无线连接

4. **性能优化**
   - 真机调试比模拟器更准确
   - 可以测试真实性能
   - 可以测试设备特定功能（如相机、GPS）

## 🚀 开始调试

1. **连接设备并选择**
   ```bash
   # 打开项目
   cd /Users/heytea/HYMessage
   open HYMessage.xcodeproj
   ```

2. **在 Xcode 中**
   - 选择你的设备
   - 点击运行（⌘R）

3. **首次运行**
   - 设备上会提示信任开发者
   - 按照上述步骤操作

---

**现在就可以开始真机调试了！** 🎉

如果遇到任何问题，告诉我具体的错误信息，我会帮你解决。

