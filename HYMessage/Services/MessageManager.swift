//
//  MessageManager.swift
//  HYMessage
//
//  Created on 2024
//

import Foundation
import MessageUI
import Contacts

class MessageManager: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let classifier = MessageClassifier()
    
    // 模拟短信数据（实际应用中需要从系统读取）
    // 注意：iOS系统限制，无法直接读取短信，这里使用模拟数据
    func loadMessages() {
        isLoading = true
        errorMessage = nil
        
        // 模拟加载延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // 模拟短信数据
            let mockMessages = self.generateMockMessages()
            
            // 提取签名并分类
            var processedMessages: [Message] = []
            for var message in mockMessages {
                // 提取签名
                message.signature = self.extractSignature(from: message.content)
                
                // AI分类建议
                message.aiSuggestedCategory = self.classifier.classify(message: message)
                
                processedMessages.append(message)
            }
            
            self.messages = processedMessages.sorted { $0.timestamp > $1.timestamp }
            self.isLoading = false
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
        
        for message in messages {
            let category = message.category ?? message.aiSuggestedCategory ?? .other
            if grouped[category] == nil {
                grouped[category] = []
            }
            grouped[category]?.append(message)
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

