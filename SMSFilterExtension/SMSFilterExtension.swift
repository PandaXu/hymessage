//
//  SMSFilterExtension.swift
//  SMSFilterExtension
//
//  Created on 2024
//

import Foundation
import IdentityLookup
import IdentityLookupUI

/// SMS Filter Extension 主类
/// 实现短信过滤和分类功能
final class SMSFilterExtension: ILMessageFilterExtension {
    
    // App Group 标识符（用于与主应用共享数据）
    private let appGroupIdentifier = "group.com.hytea.HYMessage"
    
    // 获取共享的 UserDefaults
    private var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier) ?? UserDefaults.standard
    }
    
    // 分类器实例
    private let classifier = MessageFilterClassifier()
    
    // 签名提取器
    private let signatureExtractor = SignatureExtractor()
    
    override init() {
        super.init()
        NSLog("[SMSFilterExtension] Extension 初始化")
        NSLog("[SMSFilterExtension] App Group ID: \(appGroupIdentifier)")
        if let defaults = UserDefaults(suiteName: appGroupIdentifier) {
            NSLog("[SMSFilterExtension] App Group UserDefaults 可用")
        } else {
            NSLog("[SMSFilterExtension] ⚠️ App Group UserDefaults 不可用，使用标准 UserDefaults")
        }
    }
}

// MARK: - ILMessageFilterCapabilitiesQueryHandling

extension SMSFilterExtension: ILMessageFilterCapabilitiesQueryHandling {
    
    /// 处理能力查询请求
    /// 系统会调用此方法来查询 Extension 支持的功能
    /// - Parameters:
    ///   - capabilitiesQueryRequest: 能力查询请求
    ///   - context: 查询上下文
    ///   - completion: 完成回调，返回能力响应
    func handle(_ capabilitiesQueryRequest: ILMessageFilterCapabilitiesQueryRequest,
                context: ILMessageFilterExtensionContext,
                completion: @escaping (ILMessageFilterCapabilitiesQueryResponse) -> Void) {
        
        NSLog("[SMSFilterExtension] 🔍 收到能力查询请求")
        
        let response = ILMessageFilterCapabilitiesQueryResponse()
        
        // 配置支持的子操作类型
        // 交易类子操作
        response.transactionalSubActions = [
            .transactionalFinance,      // 金融交易
            .transactionalOrders,        // 订单交易
            .transactionalOthers,        // 其他交易
            .transactionalReminders,     // 提醒
            .transactionalHealth,        // 健康
            .transactionalWeather,       // 天气
            .transactionalCarrier,       // 运营商
            .transactionalRewards,       // 奖励
            .transactionalPublicServices // 公共服务
        ]
        
        // 促销类子操作
        response.promotionalSubActions = [
            .promotionalOffers,          // 促销优惠
            .promotionalCoupons,         // 优惠券
            .promotionalOthers           // 其他促销
        ]
        
        NSLog("[SMSFilterExtension] ✅ 能力查询响应:")
        NSLog("[SMSFilterExtension]   交易类子操作: \(response.transactionalSubActions.count) 种")
        NSLog("[SMSFilterExtension]   促销类子操作: \(response.promotionalSubActions.count) 种")
        
        completion(response)
    }
}

// MARK: - ILMessageFilterQueryHandling

extension SMSFilterExtension: ILMessageFilterQueryHandling {
    
    /// 处理短信过滤查询
    /// - Parameters:
    ///   - queryRequest: 查询请求，包含短信内容
    ///   - context: 查询上下文
    ///   - completion: 完成回调，返回过滤操作
    func handle(_ queryRequest: ILMessageFilterQueryRequest,
                context: ILMessageFilterExtensionContext,
                completion: @escaping (ILMessageFilterQueryResponse) -> Void) {
        
        NSLog("[SMSFilterExtension] ========== 收到短信过滤查询 ==========")
        
        // 创建响应
        let response = ILMessageFilterQueryResponse()
        
        // 获取短信信息
        let messageBody = queryRequest.messageBody ?? ""
        let sender = queryRequest.sender ?? ""
        
        NSLog("[SMSFilterExtension] 📨 短信信息:")
        NSLog("[SMSFilterExtension]   发件人: \(sender)")
        NSLog("[SMSFilterExtension]   内容长度: \(messageBody.count) 字符")
        NSLog("[SMSFilterExtension]   内容预览: \(messageBody.prefix(50))\(messageBody.count > 50 ? "..." : "")")
        
        // 提取签名
        NSLog("[SMSFilterExtension] 🔍 开始提取签名...")
        let signature = signatureExtractor.extract(from: messageBody)
        if let signature = signature {
            NSLog("[SMSFilterExtension] ✅ 提取到签名: \(signature)")
        } else {
            NSLog("[SMSFilterExtension] ⚠️ 未提取到签名")
        }
        
        // AI 分类
        NSLog("[SMSFilterExtension] 🤖 开始 AI 分类...")
        let category = classifier.classify(sender: sender, content: messageBody)
        NSLog("[SMSFilterExtension] ✅ 分类结果: \(category.rawValue)")
        
        // 保存分类信息到 App Group（供主应用使用）
        NSLog("[SMSFilterExtension] 💾 保存分类信息到 App Group...")
        saveClassification(sender: sender, content: messageBody, signature: signature, category: category)
        
        // 根据分类规则决定过滤操作
        NSLog("[SMSFilterExtension] 🔎 检查过滤规则...")
        let action = determineFilterAction(signature: signature, category: category, content: messageBody)
        NSLog("[SMSFilterExtension] ✅ 过滤操作: \(action == .filter ? "过滤" : "允许")")
        
        // 设置响应
        response.action = action
        
        // 如果标记为垃圾短信，可以根据分类设置不同的子操作
        if action == .filter {
            NSLog("[SMSFilterExtension] 🚫 设置子操作...")
            // 根据分类设置相应的子操作
            switch category {
            case .promotion:
                response.subAction = .promotionalOffers
                NSLog("[SMSFilterExtension]   子操作: promotionalOffers")
            case .finance:
                response.subAction = .transactionalFinance
                NSLog("[SMSFilterExtension]   子操作: transactionalFinance")
            case .logistics:
                response.subAction = .transactionalOrders
                NSLog("[SMSFilterExtension]   子操作: transactionalOrders")
            case .verification:
                response.subAction = .transactionalOthers
                NSLog("[SMSFilterExtension]   子操作: transactionalOthers")
            default:
                response.subAction = .none
                NSLog("[SMSFilterExtension]   子操作: none")
            }
        } else {
            NSLog("[SMSFilterExtension] ✅ 允许通过，无需设置子操作")
        }
        
        NSLog("[SMSFilterExtension] 📤 返回响应: action=\(action == .filter ? "filter" : "allow"), subAction=\(response.subAction)")
        NSLog("[SMSFilterExtension] ========== 处理完成 ==========")
        
        completion(response)
    }
    
    /// 确定过滤操作
    private func determineFilterAction(signature: String?, category: MessageCategory, content: String) -> ILMessageFilterAction {
        
        NSLog("[SMSFilterExtension] 🔎 determineFilterAction 开始")
        NSLog("[SMSFilterExtension]   参数: signature=\(signature ?? "nil"), category=\(category.rawValue)")
        
        // 从 App Group 读取用户设置的过滤规则
        NSLog("[SMSFilterExtension] 📖 加载过滤规则...")
        if let filterRules = loadFilterRules() {
            NSLog("[SMSFilterExtension] ✅ 成功加载过滤规则")
            NSLog("[SMSFilterExtension]   签名规则数量: \(filterRules.signatureRules.count)")
            NSLog("[SMSFilterExtension]   分类规则数量: \(filterRules.categoryRules.count)")
            
            // 检查签名过滤规则
            if let signature = signature {
                NSLog("[SMSFilterExtension] 🔍 检查签名规则: \(signature)")
                if let rules = filterRules.signatureRules[signature] {
                    NSLog("[SMSFilterExtension] ✅ 找到签名规则: action=\(rules.action.rawValue), enabled=\(rules.enabled)")
                    if rules.action == .filter && rules.enabled {
                        NSLog("[SMSFilterExtension] 🚫 根据签名规则过滤")
                        return .filter
                    } else {
                        NSLog("[SMSFilterExtension] ✅ 签名规则允许通过")
                    }
                } else {
                    NSLog("[SMSFilterExtension] ⚠️ 未找到签名规则")
                }
            } else {
                NSLog("[SMSFilterExtension] ⚠️ 无签名，跳过签名规则检查")
            }
            
            // 检查分类过滤规则
            NSLog("[SMSFilterExtension] 🔍 检查分类规则: \(category.rawValue)")
            if let rules = filterRules.categoryRules[category] {
                NSLog("[SMSFilterExtension] ✅ 找到分类规则: action=\(rules.action.rawValue), enabled=\(rules.enabled)")
                if rules.action == .filter && rules.enabled {
                    NSLog("[SMSFilterExtension] 🚫 根据分类规则过滤")
                    return .filter
                } else {
                    NSLog("[SMSFilterExtension] ✅ 分类规则允许通过")
                }
            } else {
                NSLog("[SMSFilterExtension] ⚠️ 未找到分类规则")
            }
        } else {
            NSLog("[SMSFilterExtension] ⚠️ 无法加载过滤规则，使用默认规则")
        }
        
        // 默认规则：营销推广类短信标记为垃圾
        if category == .promotion {
            NSLog("[SMSFilterExtension] 🚫 默认规则：营销推广类短信自动过滤")
            return .filter
        }
        
        // 其他短信允许通过
        NSLog("[SMSFilterExtension] ✅ 默认规则：允许通过")
        return .allow
    }
    
    /// 保存分类信息到 App Group
    private func saveClassification(sender: String, content: String, signature: String?, category: MessageCategory) {
        NSLog("[SMSFilterExtension] 💾 saveClassification 开始")
        
        let classification = MessageClassification(
            sender: sender,
            content: content,
            signature: signature,
            category: category,
            timestamp: Date()
        )
        
        NSLog("[SMSFilterExtension]   创建分类对象: sender=\(sender), category=\(category.rawValue), signature=\(signature ?? "nil")")
        
        // 保存到 App Group
        NSLog("[SMSFilterExtension] 📝 编码分类数据...")
        if let data = try? JSONEncoder().encode(classification) {
            NSLog("[SMSFilterExtension] ✅ 编码成功，数据大小: \(data.count) 字节")
            
            // 保存最后一条分类
            sharedDefaults?.set(data, forKey: "lastClassification")
            NSLog("[SMSFilterExtension] ✅ 已保存到 lastClassification")
            
            // 保存到分类历史记录
            NSLog("[SMSFilterExtension] 📚 加载分类历史...")
            var history = loadClassificationHistory()
            let oldCount = history.count
            NSLog("[SMSFilterExtension]   当前历史记录数: \(oldCount)")
            
            history.append(classification)
            NSLog("[SMSFilterExtension] ✅ 添加新记录，总数: \(history.count)")
            
            // 只保留最近 1000 条记录
            if history.count > 1000 {
                let removed = history.count - 1000
                history.removeFirst(removed)
                NSLog("[SMSFilterExtension] 🗑️ 清理旧记录，删除 \(removed) 条，保留 1000 条")
            }
            
            NSLog("[SMSFilterExtension] 📝 编码历史数据...")
            if let historyData = try? JSONEncoder().encode(history) {
                NSLog("[SMSFilterExtension] ✅ 历史数据编码成功，大小: \(historyData.count) 字节")
                sharedDefaults?.set(historyData, forKey: "classificationHistory")
                NSLog("[SMSFilterExtension] ✅ 已保存到 classificationHistory")
            } else {
                NSLog("[SMSFilterExtension] ❌ 历史数据编码失败")
            }
        } else {
            NSLog("[SMSFilterExtension] ❌ 分类数据编码失败")
        }
        
        NSLog("[SMSFilterExtension] 💾 saveClassification 完成")
    }
    
    /// 加载过滤规则
    private func loadFilterRules() -> FilterRules? {
        NSLog("[SMSFilterExtension] 📖 loadFilterRules 开始")
        
        guard let data = sharedDefaults?.data(forKey: "filterRules") else {
            NSLog("[SMSFilterExtension] ⚠️ 未找到 filterRules 数据")
            return nil
        }
        
        NSLog("[SMSFilterExtension] ✅ 找到 filterRules 数据，大小: \(data.count) 字节")
        
        guard let rules = try? JSONDecoder().decode(FilterRules.self, from: data) else {
            NSLog("[SMSFilterExtension] ❌ filterRules 解码失败")
            return nil
        }
        
        NSLog("[SMSFilterExtension] ✅ filterRules 解码成功")
        NSLog("[SMSFilterExtension]   签名规则: \(rules.signatureRules.keys.joined(separator: ", "))")
        NSLog("[SMSFilterExtension]   分类规则: \(rules.categoryRules.keys.map { $0.rawValue }.joined(separator: ", "))")
        
        return rules
    }
    
    /// 加载分类历史
    private func loadClassificationHistory() -> [MessageClassification] {
        NSLog("[SMSFilterExtension] 📚 loadClassificationHistory 开始")
        
        guard let data = sharedDefaults?.data(forKey: "classificationHistory") else {
            NSLog("[SMSFilterExtension] ⚠️ 未找到 classificationHistory 数据，返回空数组")
            return []
        }
        
        NSLog("[SMSFilterExtension] ✅ 找到 classificationHistory 数据，大小: \(data.count) 字节")
        
        guard let history = try? JSONDecoder().decode([MessageClassification].self, from: data) else {
            NSLog("[SMSFilterExtension] ❌ classificationHistory 解码失败，返回空数组")
            return []
        }
        
        NSLog("[SMSFilterExtension] ✅ classificationHistory 解码成功，记录数: \(history.count)")
        
        return history
    }
}

// MARK: - Supporting Types

/// 过滤规则
struct FilterRules: Codable {
    var signatureRules: [String: FilterRule] = [:]
    var categoryRules: [MessageCategory: FilterRule] = [:]
}

/// 单个过滤规则
struct FilterRule: Codable {
    let action: FilterAction
    let enabled: Bool
}

/// 过滤操作
enum FilterAction: String, Codable {
    case allow = "allow"      // 允许通过
    case filter = "filter"    // 过滤（标记为垃圾）
}

// MARK: - Signature Extractor

/// 签名提取器
class SignatureExtractor {
    /// 从短信内容中提取签名
    func extract(from content: String) -> String? {
        NSLog("[SignatureExtractor] 🔍 开始提取签名，内容长度: \(content.count)")
        
        // 常见的签名模式
        let patterns = [
            ("【.*?】", "【签名】"),
            ("\\[.*?\\]", "[签名]"),
            ("（.*?）", "（签名）"),
            ("\\(.*?\\)", "(签名)")
        ]
        
        NSLog("[SignatureExtractor]   尝试 \(patterns.count) 种模式")
        
        for (pattern, description) in patterns {
            NSLog("[SignatureExtractor]   尝试模式: \(description) (\(pattern))")
            
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
                NSLog("[SignatureExtractor]     ❌ 正则表达式创建失败")
                continue
            }
            
            let range = NSRange(location: 0, length: content.utf16.count)
            guard let match = regex.firstMatch(in: content, options: [], range: range) else {
                NSLog("[SignatureExtractor]     ⚠️ 未匹配")
                continue
            }
            
            guard let swiftRange = Range(match.range, in: content) else {
                NSLog("[SignatureExtractor]     ❌ 范围转换失败")
                continue
            }
            
            let signature = String(content[swiftRange])
            NSLog("[SignatureExtractor]     ✅ 匹配到: \(signature)")
            
            // 移除括号
            let cleaned = signature
                .replacingOccurrences(of: "【", with: "")
                .replacingOccurrences(of: "】", with: "")
                .replacingOccurrences(of: "[", with: "")
                .replacingOccurrences(of: "]", with: "")
                .replacingOccurrences(of: "（", with: "")
                .replacingOccurrences(of: "）", with: "")
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: ")", with: "")
            
            NSLog("[SignatureExtractor] ✅ 提取成功: \(cleaned)")
            return cleaned
        }
        
        NSLog("[SignatureExtractor] ⚠️ 未提取到签名")
        return nil
    }
}

// MARK: - Message Filter Classifier

/// 短信过滤分类器（AI 分类逻辑）
class MessageFilterClassifier {
    // 关键词字典，用于分类
    private let categoryKeywords: [MessageCategory: [String]] = [
        .verification: ["验证码", "验证", "code", "动态码", "安全码", "激活码"],
        .promotion: ["优惠", "促销", "折扣", "特价", "活动", "优惠券", "红包", "满减", "限时"],
        .notification: ["通知", "提醒", "告警", "警告", "重要", "注意"],
        .finance: ["银行", "支付", "转账", "余额", "账单", "信用卡", "理财", "投资", "股票", "基金"],
        .logistics: ["快递", "物流", "配送", "发货", "送达", "包裹", "订单", "运输"],
        .social: ["好友", "关注", "点赞", "评论", "分享", "动态", "朋友圈"],
        .work: ["会议", "工作", "任务", "项目", "报告", "审批", "打卡"],
    ]
    
    /// 分类短信
    func classify(sender: String, content: String) -> MessageCategory {
        NSLog("[MessageFilterClassifier] 🤖 开始分类")
        NSLog("[MessageFilterClassifier]   发件人: \(sender)")
        NSLog("[MessageFilterClassifier]   内容长度: \(content.count) 字符")
        
        let contentLower = content.lowercased()
        let senderLower = sender.lowercased()
        
        // 计算每个分类的匹配分数
        var scores: [MessageCategory: Double] = [:]
        
        NSLog("[MessageFilterClassifier] 📊 开始计算分类分数...")
        
        for (category, keywords) in categoryKeywords {
            var score: Double = 0
            var matchedKeywords: [String] = []
            
            NSLog("[MessageFilterClassifier]   检查分类: \(category.rawValue) (关键词数: \(keywords.count))")
            
            // 检查内容中的关键词
            for keyword in keywords {
                if contentLower.contains(keyword.lowercased()) {
                    score += 1.0
                    matchedKeywords.append(keyword)
                    NSLog("[MessageFilterClassifier]     ✅ 内容匹配关键词: \(keyword) (+1.0)")
                }
            }
            
            // 检查发件人中的关键词
            for keyword in keywords {
                if senderLower.contains(keyword.lowercased()) {
                    score += 0.5
                    matchedKeywords.append("发件人:\(keyword)")
                    NSLog("[MessageFilterClassifier]     ✅ 发件人匹配关键词: \(keyword) (+0.5)")
                }
            }
            
            // 特殊规则
            if category == .verification {
                // 验证码通常包含数字
                if content.range(of: #"\d{4,6}"#, options: .regularExpression) != nil {
                    score += 2.0
                    NSLog("[MessageFilterClassifier]     ✅ 验证码特殊规则: 包含4-6位数字 (+2.0)")
                }
            }
            
            if category == .finance {
                // 金融短信通常包含金额
                if content.range(of: #"[\d,]+\.?\d*元"#, options: .regularExpression) != nil {
                    score += 1.5
                    NSLog("[MessageFilterClassifier]     ✅ 金融特殊规则: 包含金额 (+1.5)")
                }
            }
            
            if category == .logistics {
                // 物流短信通常包含单号
                if content.range(of: #"[A-Z0-9]{8,}"#, options: .regularExpression) != nil {
                    score += 1.5
                    NSLog("[MessageFilterClassifier]     ✅ 物流特殊规则: 包含单号 (+1.5)")
                }
            }
            
            scores[category] = score
            if score > 0 {
                NSLog("[MessageFilterClassifier]   📈 \(category.rawValue) 总分: \(score) (匹配: \(matchedKeywords.joined(separator: ", ")))")
            }
        }
        
        // 找到得分最高的分类
        NSLog("[MessageFilterClassifier] 🏆 查找最高分...")
        if let maxScore = scores.values.max(), maxScore > 0 {
            if let bestCategory = scores.first(where: { $0.value == maxScore })?.key {
                NSLog("[MessageFilterClassifier] ✅ 分类结果: \(bestCategory.rawValue) (分数: \(maxScore))")
                
                // 打印所有分数
                let sortedScores = scores.sorted { $0.value > $1.value }
                NSLog("[MessageFilterClassifier] 📊 所有分类分数:")
                for (category, score) in sortedScores {
                    if score > 0 {
                        NSLog("[MessageFilterClassifier]   \(category.rawValue): \(score)")
                    }
                }
                
                return bestCategory
            }
        }
        
        NSLog("[MessageFilterClassifier] ⚠️ 未找到匹配分类，返回: 其他")
        return .other
    }
}

