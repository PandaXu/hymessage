# 解决 "Type 'Message' does not conform to protocol 'Hashable'" 错误

## ✅ 已修复

代码已经正确实现了 `Hashable` 协议：
- ✅ `Message` 结构体已声明 `Hashable`
- ✅ 实现了 `hash(into:)` 方法
- ✅ 实现了 `==` 操作符
- ✅ `MessageCategory` 也已声明 `Hashable`

## 🔧 如果仍然报错，请尝试以下步骤

### 方法 1: 清理构建（最常用）

在 Xcode 中：
1. **Product → Clean Build Folder** (⇧⌘K)
2. 等待清理完成
3. 重新编译：**Product → Build** (⌘B)
4. 运行：**Product → Run** (⌘R)

### 方法 2: 删除 DerivedData

```bash
# 删除项目的 DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/HYMessage-*

# 或者在 Xcode 中：
# Xcode → Preferences → Locations → Derived Data → 点击箭头打开文件夹
# 删除 HYMessage 相关的文件夹
```

### 方法 3: 重启 Xcode

1. 完全退出 Xcode（⌘Q）
2. 重新打开项目
3. 清理构建（⇧⌘K）
4. 重新编译

### 方法 4: 验证代码

确保 `MessageModel.swift` 包含以下代码：

```swift
struct Message: Identifiable, Codable, Hashable {
    // ... 属性 ...
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Equatable conformance
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
}
```

### 方法 5: 检查文件是否在项目中

1. 在 Xcode 左侧项目导航器中
2. 确保 `MessageModel.swift` 文件存在且没有红色标记
3. 如果文件是红色的，右键 → "Add Files to HYMessage"

## 🎯 快速修复命令

```bash
# 1. 清理 DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/HYMessage-*

# 2. 重新打开项目
cd /Users/heytea/HYMessage
open HYMessage.xcodeproj

# 3. 在 Xcode 中：
# - 按 ⇧⌘K 清理构建
# - 按 ⌘B 重新编译
# - 按 ⌘R 运行
```

## 📋 验证清单

- [ ] `Message` 结构体声明了 `Hashable`
- [ ] 实现了 `hash(into:)` 方法
- [ ] 实现了 `==` 操作符
- [ ] `MessageCategory` 声明了 `Hashable`
- [ ] 已清理构建（⇧⌘K）
- [ ] 已删除 DerivedData
- [ ] Xcode 已重启

## 💡 如果问题仍然存在

1. **检查 Xcode 版本**
   - 确保使用 Xcode 15.0 或更高版本
   - 检查：Xcode → About Xcode

2. **检查 Swift 版本**
   - 项目使用 Swift 5.0
   - 确保 Xcode 支持

3. **查看完整错误信息**
   - 在 Xcode 中点击错误
   - 查看完整的错误描述
   - 告诉我具体的错误信息

---

**当前状态**: ✅ 代码已修复，如果仍有错误，请按照上述步骤清理缓存。

