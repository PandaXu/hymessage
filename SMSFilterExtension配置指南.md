# SMS Filter Extension 配置指南

## 📱 功能概述

已集成 **SMS Filter Extension**，实现系统级别的短信分类和过滤功能。

### 主要功能

1. **系统级短信过滤**
   - 在系统级别拦截和分类短信
   - 自动标记垃圾短信
   - 无需用户手动操作

2. **智能分类**
   - 按签名自动分类
   - AI 智能分类（验证码、营销、通知等）
   - 支持自定义分类规则

3. **数据共享**
   - Extension 和主应用通过 App Group 共享数据
   - 自动同步分类结果
   - 统一管理过滤规则

## ✅ 已创建的代码文件

### Extension 代码
- ✅ `SMSFilterExtension/SMSFilterExtension.swift` - Extension 主类
- ✅ `SMSFilterExtension/Info.plist` - Extension 配置文件
- ✅ `SMSFilterExtension/SMSFilterExtension.entitlements` - Extension 权限配置

### 主应用代码
- ✅ `HYMessage/Views/SettingsView.swift` - 设置界面（包含 Extension 管理）
- ✅ `HYMessage/Services/FilterRulesManager.swift` - 过滤规则管理器
- ✅ `HYMessage/Models/MessageClassification.swift` - 分类数据模型
- ✅ `HYMessage/HYMessage.entitlements` - 主应用 App Group 配置
- ✅ 更新 `MessageManager.swift` 支持 App Group 数据共享

## 🔧 在 Xcode 中配置（必须完成）

### 步骤 1: 创建 SMS Filter Extension Target

1. **打开项目**
   ```
   在 Xcode 中打开 HYMessage.xcodeproj
   ```

2. **添加 Target**
   - 菜单：`File → New → Target...`
   - 选择：`iOS → SMS Filter Extension`
   - 点击：`Next`

3. **配置 Target**
   ```
   Product Name: SMSFilterExtension
   Organization Identifier: com.hytea
   Bundle Identifier: com.hytea.HYMessage.SMSFilterExtension
   Language: Swift
   ```

4. **完成创建**
   - 点击 `Finish`
   - 选择 `Activate` 激活 Scheme

### 步骤 2: 配置 App Groups

#### 主应用 Target

1. 选择 Target "HYMessage"
2. 点击 `Signing & Capabilities` 标签
3. 点击 `+ Capability`
4. 添加 `App Groups`
5. 点击 `+` 添加 Group
6. 输入：`group.com.hytea.HYMessage`
7. 确保已勾选

#### Extension Target

1. 选择 Target "SMSFilterExtension"
2. 点击 `Signing & Capabilities` 标签
3. 添加 `App Groups`
4. 选择相同的 Group：`group.com.hytea.HYMessage`
5. 确保已勾选

### 步骤 3: 添加代码文件到 Extension

#### 方法一：在 Xcode 中添加

1. **添加 Extension 文件**
   - 右键点击 Extension Target 文件夹
   - `Add Files to "SMSFilterExtension"...`
   - 选择以下文件：
     - `SMSFilterExtension/SMSFilterExtension.swift`
   - ✅ 勾选 "Copy items if needed"
   - ✅ 勾选 Target "SMSFilterExtension"

2. **共享代码文件**
   - 选择以下文件，在右侧 File Inspector 中：
     - `MessageModel.swift`（需要共享 MessageCategory）
     - `MessageClassification.swift`
   - 在 "Target Membership" 中勾选 "SMSFilterExtension"

3. **配置 Info.plist**
   - 替换 Extension 的 `Info.plist` 内容为已创建的文件

4. **配置 Entitlements**
   - 在 Extension Target 的 Build Settings 中
   - 设置 `Code Signing Entitlements` 为 `SMSFilterExtension/SMSFilterExtension.entitlements`

### 步骤 4: 配置主应用 Entitlements

1. 选择主应用 Target "HYMessage"
2. 在 Build Settings 中
3. 设置 `Code Signing Entitlements` 为 `HYMessage/HYMessage.entitlements`

### 步骤 5: 添加框架依赖

#### Extension Target

1. 选择 Extension Target
2. `Build Phases → Link Binary With Libraries`
3. 添加框架：
   - `IdentityLookup.framework`
   - `IdentityLookupUI.framework`
   - `Foundation.framework`

## 🚀 测试 Extension

### 方法一：运行 Extension Scheme

1. 在 Xcode 顶部选择 Scheme
2. 选择 "SMSFilterExtension"
3. 选择模拟器或设备
4. 点击运行（⌘R）
5. 系统会提示安装 Extension

### 方法二：在主应用中测试

1. 运行主应用
2. Extension 会自动安装
3. 在设置中启用 Extension（见下方说明）

## 📱 启用 Extension

### 在 iOS 设置中启用

1. **打开「设置」应用**
2. **进入「信息」**
3. **选择「未知与过滤信息」**
4. **选择「短信过滤」**
5. **启用「短信智能管理」**

### 在主应用中管理

1. 打开应用
2. 进入「设置」标签
3. 点击「管理短信过滤」
4. 查看 Extension 状态
5. 配置过滤规则

## ⚙️ 配置过滤规则

### 按签名过滤

1. 在设置中进入「过滤规则」
2. 查看已识别的签名列表
3. 开启/关闭特定签名的过滤

### 按分类过滤

1. 在设置中进入「过滤规则
2. 选择要过滤的分类：
   - 验证码
   - 营销推广（默认开启）
   - 通知提醒
   - 金融理财
   - 物流快递
   - 社交娱乐
   - 工作相关
   - 其他

### 自动过滤营销短信

- 在设置中开启「自动过滤营销短信」
- 系统会自动过滤所有营销推广类短信

## 🔄 数据同步

### Extension → 主应用

1. Extension 在系统级别分类短信
2. 分类结果保存到 App Group
3. 在主应用中点击「同步 Extension 数据」
4. 分类结果会显示在主应用中

### 主应用 → Extension

1. 在主应用中配置过滤规则
2. 规则保存到 App Group
3. Extension 自动读取并应用规则

## 📋 工作原理

### 短信过滤流程

```
收到短信
    ↓
系统调用 Extension
    ↓
Extension 提取签名
    ↓
Extension AI 分类
    ↓
根据规则决定过滤操作
    ↓
保存分类结果到 App Group
    ↓
系统执行过滤（标记为垃圾/允许通过）
```

### App Group 数据共享

```swift
// 共享的数据
- filterRules: 过滤规则
- classificationHistory: 分类历史
- savedMessages: 保存的短信数据
```

## ⚠️ 重要说明

### SMS Filter Extension 的限制

1. **只能过滤，不能读取**
   - Extension 只能拦截和分类短信
   - 无法读取设备上的历史短信
   - 只能处理新收到的短信

2. **需要用户授权**
   - 必须在系统设置中启用 Extension
   - 用户需要明确授权才能使用

3. **系统级运行**
   - Extension 运行在系统级别
   - 对性能要求较高
   - 需要快速响应

### 与文件导入的关系

- **文件导入**：用于导入历史短信数据
- **SMS Filter Extension**：用于实时过滤新短信
- 两者可以配合使用，提供完整的短信管理方案

## 🔧 常见问题

### Q: Extension 无法启用？

**A**: 
1. 检查 App Group 是否配置正确
2. 确保主应用和 Extension 使用相同的 Group ID
3. 检查签名配置是否正确
4. 确保在系统设置中手动启用

### Q: Extension 不工作？

**A**:
1. 检查 Extension 是否在系统设置中启用
2. 检查过滤规则是否配置正确
3. 查看 Extension 日志（Xcode Console）

### Q: 分类数据不同步？

**A**:
1. 检查 App Group 配置
2. 在主应用中点击「同步 Extension 数据」
3. 确保 Extension 和主应用都使用相同的 Group ID

### Q: 编译错误？

**A**:
1. 确保所有共享文件都添加到 Extension Target
2. 检查框架依赖是否正确
3. 确保 Info.plist 配置正确
4. 检查 entitlements 文件路径

## 📋 配置检查清单

- [ ] 创建 SMS Filter Extension Target
- [ ] 配置 App Groups（主应用和 Extension）
- [ ] 添加 Extension 代码文件到 Target
- [ ] 共享必要的代码文件到 Extension Target
- [ ] 配置 Extension 的 Info.plist
- [ ] 配置 Extension 的 entitlements
- [ ] 配置主应用的 entitlements
- [ ] 添加必要的框架依赖
- [ ] 在系统设置中启用 Extension
- [ ] 测试 Extension 功能

---

**总结**：SMS Filter Extension 代码已创建，需要在 Xcode 中完成 Target 配置。Extension 可以在系统级别对短信进行分类和过滤，提供更好的用户体验。

