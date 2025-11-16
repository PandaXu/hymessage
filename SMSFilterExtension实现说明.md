# SMS Filter Extension 实现说明

## 🎯 实现目标

使用 **SMS Filter Extension** 实现系统级别的短信分类和过滤功能，支持：
1. 按短信签名进行分类
2. 按 AI 建议进行短信分类管理
3. 系统级自动过滤垃圾短信

## 📁 文件结构

```
HYMessage/
├── SMSFilterExtension/
│   ├── SMSFilterExtension.swift          # Extension 主类
│   ├── Info.plist                        # Extension 配置
│   └── SMSFilterExtension.entitlements   # Extension 权限
├── HYMessage/
│   ├── Views/
│   │   └── SettingsView.swift           # 设置界面（包含 Extension 管理）
│   ├── Services/
│   │   ├── MessageManager.swift          # 消息管理器（已更新支持 App Group）
│   │   └── FilterRulesManager.swift      # 过滤规则管理器
│   ├── Models/
│   │   └── MessageClassification.swift    # 分类数据模型
│   └── HYMessage.entitlements            # 主应用 App Group 配置
└── SMSFilterExtension配置指南.md         # 配置文档
```

## 🔧 核心实现

### 1. SMSFilterExtension.swift

**功能**：
- 实现 `ILMessageFilterQueryHandling` 协议
- 处理系统发送的短信过滤查询
- 提取签名、AI 分类、应用过滤规则

**关键方法**：
```swift
func handle(_ queryRequest: ILMessageFilterQueryRequest,
            context: ILMessageFilterExtensionContext,
            completion: @escaping (ILMessageFilterQueryResponse) -> Void)
```

**工作流程**：
1. 接收短信查询请求
2. 提取签名（使用 `SignatureExtractor`）
3. AI 分类（使用 `MessageFilterClassifier`）
4. 根据规则决定过滤操作
5. 保存分类结果到 App Group
6. 返回过滤响应

### 2. FilterRulesManager.swift

**功能**：
- 管理过滤规则（签名规则、分类规则）
- 通过 App Group 与 Extension 共享规则
- 提供规则增删改查接口

**数据结构**：
```swift
struct FilterRules {
    var signatureRules: [String: FilterRule]      // 按签名过滤
    var categoryRules: [MessageCategory: FilterRule] // 按分类过滤
}
```

### 3. MessageManager.swift（更新）

**新增功能**：
- App Group 数据共享
- `syncFromExtension()` - 从 Extension 同步分类数据

**数据共享**：
- 使用 `UserDefaults(suiteName: "group.com.hytea.HYMessage")`
- 共享数据：`savedMessages`、`filterRules`、`classificationHistory`

### 4. SettingsView.swift

**功能**：
- Extension 状态查看和管理
- 过滤规则配置界面
- 数据同步功能
- Extension 启用指引

## 🔄 数据流程

### Extension → 主应用

```
收到短信
    ↓
Extension 分类
    ↓
保存到 App Group (classificationHistory)
    ↓
主应用同步 (syncFromExtension)
    ↓
显示在主应用中
```

### 主应用 → Extension

```
用户配置规则
    ↓
保存到 App Group (filterRules)
    ↓
Extension 读取规则
    ↓
应用过滤规则
```

## 🎨 UI 界面

### 设置界面

1. **短信过滤扩展**
   - Extension 状态显示
   - 管理短信过滤按钮
   - 启用指引

2. **过滤规则**
   - 按签名过滤规则列表
   - 按分类过滤规则列表
   - 自动过滤营销短信开关

3. **数据管理**
   - 导入短信
   - 重新加载
   - 同步 Extension 数据
   - 清空分类/数据

4. **统计信息**
   - 总短信数
   - 已分类数
   - 签名数

## 🔐 权限配置

### App Groups

**标识符**：`group.com.hytea.HYMessage`

**用途**：
- 主应用和 Extension 共享数据
- 存储过滤规则
- 存储分类历史
- 存储短信数据

### Entitlements

**主应用**：`HYMessage/HYMessage.entitlements`
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.hytea.HYMessage</string>
</array>
```

**Extension**：`SMSFilterExtension/SMSFilterExtension.entitlements`
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.hytea.HYMessage</string>
</array>
```

## 🤖 AI 分类逻辑

### MessageFilterClassifier

**分类规则**：
- 验证码：包含"验证码"、"code"等关键词，通常包含4-6位数字
- 营销推广：包含"优惠"、"促销"、"折扣"等关键词
- 通知提醒：包含"通知"、"提醒"等关键词
- 金融理财：包含"银行"、"支付"、"转账"等关键词，通常包含金额
- 物流快递：包含"快递"、"物流"等关键词，通常包含单号
- 社交娱乐：包含"好友"、"关注"等关键词
- 工作相关：包含"会议"、"工作"等关键词

**评分机制**：
- 内容匹配：+1.0 分
- 发件人匹配：+0.5 分
- 特殊规则匹配：+1.5-2.0 分
- 选择得分最高的分类

## 📋 过滤规则

### 默认规则

- **营销推广**：默认过滤（标记为垃圾）

### 自定义规则

用户可以在设置中：
1. 为特定签名设置过滤规则
2. 为特定分类设置过滤规则
3. 开启/关闭自动过滤营销短信

## ⚠️ 注意事项

### 1. Extension 限制

- **只能过滤新短信**：无法读取历史短信
- **需要用户授权**：必须在系统设置中启用
- **系统级运行**：对性能要求高，需要快速响应

### 2. 数据同步

- Extension 和主应用通过 App Group 异步共享数据
- 需要手动触发同步（点击"同步 Extension 数据"）
- 建议定期同步以获取最新分类结果

### 3. 分类准确性

- AI 分类基于关键词匹配，可能不够精确
- 用户可以手动调整分类
- 建议结合签名分类提高准确性

## 🚀 使用流程

1. **配置 Extension**
   - 在 Xcode 中创建 SMS Filter Extension Target
   - 配置 App Groups
   - 添加代码文件

2. **启用 Extension**
   - 运行应用安装 Extension
   - 在系统设置中启用 Extension

3. **配置规则**
   - 在主应用中进入设置
   - 配置过滤规则
   - 开启自动过滤

4. **使用功能**
   - Extension 自动分类新短信
   - 在主应用中查看分类结果
   - 定期同步 Extension 数据

## 📊 性能优化

1. **快速响应**：Extension 必须在短时间内返回结果
2. **缓存规则**：在 Extension 中缓存过滤规则
3. **批量处理**：避免频繁访问 App Group
4. **异步处理**：分类历史保存使用异步方式

## 🔍 调试技巧

1. **查看 Extension 日志**：在 Xcode Console 中查看
2. **检查 App Group 数据**：使用 UserDefaults 查看器
3. **测试过滤规则**：在设置中修改规则并测试
4. **验证数据同步**：检查主应用和 Extension 的数据一致性

---

**总结**：SMS Filter Extension 实现了系统级别的短信分类和过滤功能，通过 App Group 与主应用共享数据，提供完整的短信管理解决方案。

