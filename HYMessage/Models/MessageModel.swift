//
//  MessageModel.swift
//  HYMessage
//
//  Created on 2024
//

import Foundation
import SwiftUI

struct Message: Identifiable, Codable, Hashable {
    let id: String
    let sender: String
    let content: String
    let timestamp: Date
    var signature: String?
    var category: MessageCategory?
    var aiSuggestedCategory: MessageCategory?
    
    init(id: String = UUID().uuidString, 
         sender: String, 
         content: String, 
         timestamp: Date = Date(),
         signature: String? = nil,
         category: MessageCategory? = nil,
         aiSuggestedCategory: MessageCategory? = nil) {
        self.id = id
        self.sender = sender
        self.content = content
        self.timestamp = timestamp
        self.signature = signature
        self.category = category
        self.aiSuggestedCategory = aiSuggestedCategory
    }
    
    // Hashable conformance - 使用 id 作为唯一标识
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Equatable conformance (Hashable 需要 Equatable)
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
}

enum MessageCategory: String, Codable, CaseIterable, Hashable {
    case verification = "验证码"
    case promotion = "营销推广"
    case notification = "通知提醒"
    case finance = "金融理财"
    case logistics = "物流快递"
    case social = "社交娱乐"
    case work = "工作相关"
    case other = "其他"
    
    var icon: String {
        switch self {
        case .verification: return "key.fill"
        case .promotion: return "tag.fill"
        case .notification: return "bell.fill"
        case .finance: return "dollarsign.circle.fill"
        case .logistics: return "shippingbox.fill"
        case .social: return "person.2.fill"
        case .work: return "briefcase.fill"
        case .other: return "folder.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .verification: return .blue
        case .promotion: return .orange
        case .notification: return .green
        case .finance: return .yellow
        case .logistics: return .purple
        case .social: return .pink
        case .work: return .indigo
        case .other: return .gray
        }
    }
}

