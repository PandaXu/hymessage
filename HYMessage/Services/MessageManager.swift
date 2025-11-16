//
//  MessageManager.swift
//  HYMessage
//
//  Created on 2024
//

import Foundation
import MessageUI
import Contacts
import UniformTypeIdentifiers

class MessageManager: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let classifier = MessageClassifier()
    
    // 加载短信（优先从文件导入，否则使用模拟数据）
    // 注意：iOS系统限制，无法直接读取短信数据库
    func loadMessages() {
        isLoading = true
        errorMessage = nil
        
        // 尝试从本地存储加载
        if let savedMessages = loadMessagesFromStorage(), !savedMessages.isEmpty {
            processMessages(savedMessages)
            return
        }
        
        // 如果没有保存的数据，使用模拟数据
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // 模拟短信数据
            let mockMessages = self.generateMockMessages()
            self.processMessages(mockMessages)
        }
    }
    
    // 处理短信（提取签名和分类）
    private func processMessages(_ rawMessages: [Message]) {
        var processedMessages: [Message] = []
        for var message in rawMessages {
            // 提取签名
            message.signature = self.extractSignature(from: message.content)
            
            // AI分类建议（确保所有消息都有分类，无法分类的归到"其他"）
            let suggestedCategory = self.classifier.classify(message: message)
            message.aiSuggestedCategory = suggestedCategory
            
            // 如果用户没有手动设置分类，使用 AI 建议的分类
            if message.category == nil {
                message.category = suggestedCategory
            }
            
            print("[MessageManager]   处理消息: \(message.sender) -> \(suggestedCategory.rawValue)")
            
            processedMessages.append(message)
        }
        
        self.messages = processedMessages.sorted { $0.timestamp > $1.timestamp }
        self.isLoading = false
        
        // 保存到本地存储
        saveMessagesToStorage(processedMessages)
    }
    
    // 从文件导入短信
    func importMessages(from data: Data, format: ImportFormat) {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            var importedMessages: [Message] = []
            
            switch format {
            case .csv:
                if let csvString = String(data: data, encoding: .utf8) {
                    importedMessages = MessageImporter.importFromCSV(csvString)
                }
            case .json:
                if let messages = MessageImporter.importFromJSON(data) {
                    importedMessages = messages
                }
            }
            
            DispatchQueue.main.async {
                if !importedMessages.isEmpty {
                    self.processMessages(importedMessages)
                    self.errorMessage = nil
                } else {
                    self.errorMessage = "导入失败：无法解析文件格式"
                    self.isLoading = false
                }
            }
        }
    }
    
    // App Group 标识符（用于 Extension 和主应用共享数据）
    private let appGroupIdentifier = "group.com.hytea.HYMessage"
    
    // 获取共享的 UserDefaults
    private var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier) ?? UserDefaults.standard
    }
    
    // 保存短信到本地存储（支持 App Group 共享）
    private func saveMessagesToStorage(_ messages: [Message]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(messages) {
            // 保存到 App Group（Extension 和主应用共享）
            sharedDefaults?.set(encoded, forKey: "savedMessages")
            // 同时保存到标准 UserDefaults（兼容性）
            UserDefaults.standard.set(encoded, forKey: "savedMessages")
        }
    }
    
    // 从本地存储加载短信（支持 App Group 共享）
    private func loadMessagesFromStorage() -> [Message]? {
        // 优先从 App Group 加载
        if let data = sharedDefaults?.data(forKey: "savedMessages") {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let messages = try? decoder.decode([Message].self, from: data) {
                return messages
            }
        }
        // 兼容：从标准 UserDefaults 加载
        if let data = UserDefaults.standard.data(forKey: "savedMessages") {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let messages = try? decoder.decode([Message].self, from: data) {
                return messages
            }
        }
        return nil
    }
    
    // 清空本地存储
    func clearStoredMessages() {
        sharedDefaults?.removeObject(forKey: "savedMessages")
        UserDefaults.standard.removeObject(forKey: "savedMessages")
    }
    
    // 从 Extension 同步分类数据
    func syncFromExtension() {
        print("[MessageManager] 🔄 开始同步 Extension 数据...")
        
        guard let data = sharedDefaults?.data(forKey: "classificationHistory"),
              let classifications = try? JSONDecoder().decode([MessageClassification].self, from: data) else {
            print("[MessageManager] ⚠️ 未找到 Extension 分类数据")
            return
        }
        
        print("[MessageManager] ✅ 找到 \(classifications.count) 条分类记录")
        
        // 将 Extension 的分类数据转换为 Message 对象
        var newMessages: [Message] = []
        for classification in classifications {
            // 确保分类存在，如果 Extension 返回的分类为 nil，使用"其他"
            let category = classification.category
            
            let message = Message(
                sender: classification.sender,
                content: classification.content,
                timestamp: classification.timestamp,
                signature: classification.signature,
                category: category,  // 直接使用 Extension 的分类作为用户分类
                aiSuggestedCategory: category
            )
            newMessages.append(message)
            print("[MessageManager]   同步消息: \(classification.sender) -> \(category.rawValue)")
        }
        
        // 合并到现有消息（去重）
        var existingIds = Set(messages.map { $0.id })
        var addedCount = 0
        for message in newMessages {
            // 使用 sender + content + timestamp 作为唯一标识
            let uniqueId = "\(message.sender)-\(message.content)-\(message.timestamp.timeIntervalSince1970)"
            if !existingIds.contains(uniqueId) {
                existingIds.insert(uniqueId)
                messages.append(message)
                addedCount += 1
            }
        }
        
        print("[MessageManager] ✅ 同步完成，新增 \(addedCount) 条消息")
        
        // 保存更新后的消息
        saveMessagesToStorage(messages)
    }
    
    // 重新分类所有短信（使用最新的分类规则）
    func reclassifyAllMessages() {
        print("[MessageManager] 🤖 开始重新分类所有短信...")
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            var updatedCount = 0
            var processedMessages: [Message] = []
            
            for var message in self.messages {
                // 重新提取签名
                let oldSignature = message.signature
                message.signature = self.extractSignature(from: message.content)
                if oldSignature != message.signature {
                    print("[MessageManager]   更新签名: \(oldSignature ?? "nil") -> \(message.signature ?? "nil")")
                }
                
                // 重新分类（确保所有消息都有分类）
                let oldCategory = message.aiSuggestedCategory ?? .other
                let newCategory = self.classifier.classify(message: message)
                message.aiSuggestedCategory = newCategory
                
                // 如果用户没有手动设置分类，使用 AI 建议的分类
                if message.category == nil {
                    message.category = newCategory
                }
                
                if oldCategory != newCategory {
                    print("[MessageManager]   更新分类: \(oldCategory.rawValue) -> \(newCategory.rawValue)")
                    updatedCount += 1
                }
                
                processedMessages.append(message)
            }
            
            DispatchQueue.main.async {
                self.messages = processedMessages.sorted { $0.timestamp > $1.timestamp }
                self.isLoading = false
                self.saveMessagesToStorage(processedMessages)
                print("[MessageManager] ✅ 重新分类完成，更新了 \(updatedCount) 条短信的分类")
            }
        }
    }
    
    // 同步 Extension 数据并重新分类
    func syncAndReclassify() {
        print("[MessageManager] 🔄 开始同步和重新分类...")
        isLoading = true
        errorMessage = nil
        
        // 如果消息列表为空，先加载消息
        if messages.isEmpty {
            print("[MessageManager] 📥 消息列表为空，先加载消息...")
            if let savedMessages = loadMessagesFromStorage(), !savedMessages.isEmpty {
                messages = savedMessages
                print("[MessageManager] ✅ 从存储加载了 \(savedMessages.count) 条消息")
            } else {
                print("[MessageManager] ⚠️ 没有保存的消息，使用模拟数据")
                let mockMessages = generateMockMessages()
                messages = mockMessages
                print("[MessageManager] ✅ 生成了 \(mockMessages.count) 条模拟消息")
            }
        }
        
        // 先同步 Extension 数据
        syncFromExtension()
        
        // 然后重新分类所有消息
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            if !self.messages.isEmpty {
                self.reclassifyAllMessages()
            } else {
                print("[MessageManager] ⚠️ 消息列表仍为空，跳过重新分类")
                self.isLoading = false
            }
        }
    }
    
    // 提取短信签名
    func extractSignature(from content: String) -> String? {
        // 常见的签名模式
        let patterns = [
            "【.*?】",  // 【签名】
            "\\[.*?\\]",  // [签名]
            "（.*?）",  // （签名）
            "\\(.*?\\)",  // (签名)
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count)),
               let range = Range(match.range, in: content) {
                let signature = String(content[range])
                // 移除括号
                return signature
                    .replacingOccurrences(of: "【", with: "")
                    .replacingOccurrences(of: "】", with: "")
                    .replacingOccurrences(of: "[", with: "")
                    .replacingOccurrences(of: "]", with: "")
                    .replacingOccurrences(of: "（", with: "")
                    .replacingOccurrences(of: "）", with: "")
                    .replacingOccurrences(of: "(", with: "")
                    .replacingOccurrences(of: ")", with: "")
            }
        }
        
        return nil
    }
    
    // 按签名分组
    func messagesGroupedBySignature() -> [String: [Message]] {
        var grouped: [String: [Message]] = [:]
        
        for message in messages {
            let key = message.signature ?? "未知签名"
            if grouped[key] == nil {
                grouped[key] = []
            }
            grouped[key]?.append(message)
        }
        
        return grouped
    }
    
    // 按分类分组
    func messagesGroupedByCategory() -> [MessageCategory: [Message]] {
        var grouped: [MessageCategory: [Message]] = [:]
        
        // 确保"其他"分类总是存在
        grouped[.other] = []
        
        for message in messages {
            // 确保所有消息都有分类，无法分类的归到"其他"
            let category: MessageCategory
            if let userCategory = message.category {
                category = userCategory
            } else if let aiCategory = message.aiSuggestedCategory {
                category = aiCategory
            } else {
                // 如果既没有用户分类也没有 AI 分类，强制分类为"其他"
                category = .other
                print("[MessageManager] ⚠️ 消息无分类，归入'其他': \(message.sender)")
            }
            
            if grouped[category] == nil {
                grouped[category] = []
            }
            grouped[category]?.append(message)
        }
        
        print("[MessageManager] 📊 分类统计:")
        for (category, messages) in grouped.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            print("[MessageManager]   \(category.rawValue): \(messages.count) 条")
        }
        
        return grouped
    }
    
    // 应用AI建议的分类
    func applyAICategory(to messageId: String) {
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            messages[index].category = messages[index].aiSuggestedCategory
        }
    }
    
    // 手动设置分类
    func setCategory(_ category: MessageCategory, for messageId: String) {
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            messages[index].category = category
        }
    }
    
    // 删除单个短信
    func deleteMessage(_ messageId: String) {
        messages.removeAll { $0.id == messageId }
    }
    
    // 批量删除短信
    func deleteMessages(_ messageIds: [String]) {
        messages.removeAll { messageIds.contains($0.id) }
    }
    
    // 删除指定签名的所有短信
    func deleteMessagesBySignature(_ signature: String) {
        messages.removeAll { ($0.signature ?? "未知签名") == signature }
    }
    
    // 删除指定分类的所有短信
    func deleteMessagesByCategory(_ category: MessageCategory) {
        messages.removeAll { 
            ($0.category ?? $0.aiSuggestedCategory ?? .other) == category 
        }
    }
    
    // 删除所有短信
    func deleteAllMessages() {
        messages.removeAll()
        clearStoredMessages()
    }
    
    // 导入格式枚举
    enum ImportFormat {
        case csv
        case json
    }
    
    // 生成模拟数据
    private func generateMockMessages() -> [Message] {
        let mockData: [(sender: String, content: String, daysAgo: Int)] = [
            ("10086", "【中国移动】您的验证码是123456，5分钟内有效，请勿泄露。", 0),
            ("95588", "【工商银行】您尾号1234的银行卡于12:30消费100.00元，余额5000.00元。", 1),
            ("京东", "【京东】您的订单已发货，快递单号：JD123456789，预计明天送达。", 2),
            ("淘宝", "【淘宝】您有新的优惠券到账，满100减20，点击领取。", 3),
            ("微信", "【微信】您的微信账号在异地登录，如非本人操作请及时修改密码。", 4),
            ("支付宝", "【支付宝】您收到一笔转账100.00元，来自张三。", 5),
            ("顺丰", "【顺丰速运】您的包裹已到达配送站，预计今天下午送达。", 6),
            ("美团", "【美团】您的外卖订单已确认，预计30分钟送达。", 7),
            ("滴滴", "【滴滴出行】您的行程已完成，费用25.00元，请及时支付。", 8),
            ("招商银行", "【招商银行】您的信用卡账单已出，本期应还5000.00元。", 9),
            ("12306", "【12306】您的火车票已出票成功，车次G123，座位号05车12A。", 10),
            ("中国联通", "【中国联通】您的话费余额不足，请及时充值。", 11),
        ]
        
        let calendar = Calendar.current
        return mockData.map { data in
            let date = calendar.date(byAdding: .day, value: -data.daysAgo, to: Date()) ?? Date()
            return Message(
                sender: data.sender,
                content: data.content,
                timestamp: date
            )
        }
    }
}

