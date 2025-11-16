//
//  MessageClassification.swift
//  HYMessage
//
//  Created on 2024
//

import Foundation

/// 短信分类信息（与 Extension 共享）
struct MessageClassification: Codable {
    let sender: String
    let content: String
    let signature: String?
    let category: MessageCategory
    let timestamp: Date
}

