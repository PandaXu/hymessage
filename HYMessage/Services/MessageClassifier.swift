//
//  MessageClassifier.swift
//  HYMessage
//
//  Created on 2024
//

import Foundation

class MessageClassifier {
    // 关键词字典，用于分类
    private let categoryKeywords: [MessageCategory: [String]] = [
        .verification: ["验证码", "验证", "code", "code", "动态码", "安全码", "激活码"],
        .promotion: ["优惠", "促销", "折扣", "特价", "活动", "优惠券", "红包", "满减", "限时"],
        .notification: ["通知", "提醒", "告警", "警告", "重要", "注意"],
        .finance: ["银行", "支付", "转账", "余额", "账单", "信用卡", "理财", "投资", "股票", "基金"],
        .logistics: ["快递", "物流", "配送", "发货", "送达", "包裹", "订单", "运输"],
        .social: ["好友", "关注", "点赞", "评论", "分享", "动态", "朋友圈"],
        .work: ["会议", "工作", "任务", "项目", "报告", "审批", "打卡"],
    ]
    
    // AI分类主函数
    func classify(message: Message) -> MessageCategory {
        let content = message.content.lowercased()
        let sender = message.sender.lowercased()
        
        // 计算每个分类的匹配分数
        var scores: [MessageCategory: Double] = [:]
        
        for (category, keywords) in categoryKeywords {
            var score: Double = 0
            
            // 检查内容中的关键词
            for keyword in keywords {
                if content.contains(keyword.lowercased()) {
                    score += 1.0
                }
            }
            
            // 检查发件人中的关键词
            for keyword in keywords {
                if sender.contains(keyword.lowercased()) {
                    score += 0.5
                }
            }
            
            // 特殊规则
            if category == .verification {
                // 验证码通常包含数字
                if content.range(of: #"\d{4,6}"#, options: .regularExpression) != nil {
                    score += 2.0
                }
            }
            
            if category == .finance {
                // 金融短信通常包含金额
                if content.range(of: #"[\d,]+\.?\d*元"#, options: .regularExpression) != nil {
                    score += 1.5
                }
            }
            
            if category == .logistics {
                // 物流短信通常包含单号
                if content.range(of: #"[A-Z0-9]{8,}"#, options: .regularExpression) != nil {
                    score += 1.5
                }
            }
            
            scores[category] = score
        }
        
        // 找到得分最高的分类
        if let maxScore = scores.values.max(), maxScore > 0 {
            if let bestCategory = scores.first(where: { $0.value == maxScore })?.key {
                return bestCategory
            }
        }
        
        return .other
    }
    
    // 批量分类
    func classifyBatch(messages: [Message]) -> [Message: MessageCategory] {
        var results: [Message: MessageCategory] = [:]
        for message in messages {
            results[message] = classify(message: message)
        }
        return results
    }
    
    // 获取分类置信度（0-1）
    func getConfidence(message: Message, category: MessageCategory) -> Double {
        let content = message.content.lowercased()
        let sender = message.sender.lowercased()
        
        var score: Double = 0
        var maxPossibleScore: Double = 0
        
        if let keywords = categoryKeywords[category] {
            for keyword in keywords {
                maxPossibleScore += 1.0
                if content.contains(keyword.lowercased()) {
                    score += 1.0
                }
                if sender.contains(keyword.lowercased()) {
                    score += 0.5
                }
            }
        }
        
        if maxPossibleScore > 0 {
            return min(score / maxPossibleScore, 1.0)
        }
        
        return 0.0
    }
}

