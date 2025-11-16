//
//  FilterRulesManager.swift
//  HYMessage
//
//  Created on 2024
//

import Foundation

/// 过滤规则管理器
/// 管理 SMS Filter Extension 的过滤规则
class FilterRulesManager: ObservableObject {
    static let shared = FilterRulesManager()
    
    @Published var rules: FilterRules
    @Published var autoFilterPromotion: Bool {
        didSet {
            if autoFilterPromotion {
                updateCategoryRule(category: .promotion, action: .filter)
            }
        }
    }
    
    // App Group 标识符
    private let appGroupIdentifier = "group.com.hytea.HYMessage"
    
    // 获取共享的 UserDefaults
    private var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier) ?? UserDefaults.standard
    }
    
    private init() {
        self.rules = FilterRules()
        self.autoFilterPromotion = false
        loadRules()
    }
    
    /// 加载过滤规则
    func loadRules() {
        guard let data = sharedDefaults?.data(forKey: "filterRules"),
              let loadedRules = try? JSONDecoder().decode(FilterRules.self, from: data) else {
            // 默认规则：营销推广类短信自动过滤
            rules = FilterRules()
            autoFilterPromotion = true
            updateCategoryRule(category: .promotion, action: .filter)
            return
        }
        
        rules = loadedRules
        autoFilterPromotion = rules.categoryRules[.promotion]?.action == .filter
    }
    
    /// 保存过滤规则
    func saveRules() {
        if let data = try? JSONEncoder().encode(rules) {
            sharedDefaults?.set(data, forKey: "filterRules")
            sharedDefaults?.synchronize()
        }
    }
    
    /// 更新签名过滤规则
    func updateSignatureRule(signature: String, action: FilterAction) {
        rules.signatureRules[signature] = FilterRule(action: action, enabled: true)
        saveRules()
    }
    
    /// 更新分类过滤规则
    func updateCategoryRule(category: MessageCategory, action: FilterAction) {
        rules.categoryRules[category] = FilterRule(action: action, enabled: true)
        saveRules()
    }
    
    /// 删除签名规则
    func removeSignatureRule(signature: String) {
        rules.signatureRules.removeValue(forKey: signature)
        saveRules()
    }
    
    /// 删除分类规则
    func removeCategoryRule(category: MessageCategory) {
        rules.categoryRules.removeValue(forKey: category)
        saveRules()
    }
    
    /// 从消息列表中自动提取签名并创建规则
    func createRulesFromMessages(_ messages: [Message]) {
        print("[FilterRulesManager] 🔍 从消息中提取签名规则...")
        
        // 统计每个签名的消息数量
        var signatureCounts: [String: Int] = [:]
        for message in messages {
            if let signature = message.signature, !signature.isEmpty {
                signatureCounts[signature, default: 0] += 1
            }
        }
        
        print("[FilterRulesManager]   找到 \(signatureCounts.count) 个不同的签名")
        
        // 为出现次数较多的签名创建规则（可选：只对出现3次以上的签名创建规则）
        for (signature, count) in signatureCounts {
            if count >= 3 && rules.signatureRules[signature] == nil {
                // 默认不自动过滤，让用户手动决定
                print("[FilterRulesManager]   📝 发现新签名: \(signature) (出现 \(count) 次)")
            }
        }
    }
    
    /// 批量应用分类规则
    func applyCategoryRulesToMessages(_ messages: [Message]) -> Int {
        print("[FilterRulesManager] 🔄 批量应用分类规则...")
        var appliedCount = 0
        
        for category in MessageCategory.allCases {
            if let rule = rules.categoryRules[category], rule.action == .filter && rule.enabled {
                print("[FilterRulesManager]   🚫 分类规则: \(category.rawValue) -> 过滤")
                appliedCount += 1
            }
        }
        
        print("[FilterRulesManager] ✅ 应用了 \(appliedCount) 个分类规则")
        return appliedCount
    }
    
    /// 验证规则是否已保存
    func verifyRulesSaved() -> Bool {
        guard let data = sharedDefaults?.data(forKey: "filterRules") else {
            print("[FilterRulesManager] ⚠️ 规则未保存")
            return false
        }
        
        if let decodedRules = try? JSONDecoder().decode(FilterRules.self, from: data) {
            print("[FilterRulesManager] ✅ 规则验证成功")
            print("[FilterRulesManager]   签名规则: \(decodedRules.signatureRules.count) 条")
            print("[FilterRulesManager]   分类规则: \(decodedRules.categoryRules.count) 条")
            return true
        }
        
        print("[FilterRulesManager] ❌ 规则验证失败")
        return false
    }
    
    /// 获取规则统计信息
    func getRulesStatistics() -> (signatureCount: Int, categoryCount: Int, enabledCount: Int) {
        let signatureCount = rules.signatureRules.count
        let categoryCount = rules.categoryRules.count
        let enabledCount = rules.signatureRules.values.filter { $0.enabled }.count +
                          rules.categoryRules.values.filter { $0.enabled }.count
        
        return (signatureCount, categoryCount, enabledCount)
    }
}

/// 过滤规则（与 Extension 共享）
struct FilterRules: Codable {
    var signatureRules: [String: FilterRule] = [:]
    var categoryRules: [MessageCategory: FilterRule] = [:]
}

/// 单个过滤规则（与 Extension 共享）
struct FilterRule: Codable {
    let action: FilterAction
    let enabled: Bool
}

/// 过滤操作（与 Extension 共享）
enum FilterAction: String, Codable {
    case allow = "allow"      // 允许通过
    case filter = "filter"    // 过滤（标记为垃圾）
}

