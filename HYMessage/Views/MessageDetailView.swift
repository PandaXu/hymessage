//
//  MessageDetailView.swift
//  HYMessage
//
//  Created on 2024
//

import SwiftUI

struct MessageDetailView: View {
    let message: Message
    @ObservedObject var messageManager: MessageManager
    @State private var selectedCategory: MessageCategory?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 发件人信息
                VStack(alignment: .leading, spacing: 8) {
                    Text("发件人")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(message.sender)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // 短信内容
                VStack(alignment: .leading, spacing: 8) {
                    Text("内容")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(message.content)
                        .font(.body)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // 签名信息
                if let signature = message.signature {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("签名")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(signature)
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // 时间信息
                VStack(alignment: .leading, spacing: 8) {
                    Text("时间")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(message.timestamp, style: .date)
                        .font(.body)
                    Text(message.timestamp, style: .time)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // AI建议分类
                if let aiCategory = message.aiSuggestedCategory {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("AI建议分类")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: aiCategory.icon)
                                .foregroundColor(aiCategory.color)
                            Text(aiCategory.rawValue)
                                .font(.body)
                            
                            Spacer()
                            
                            Button(action: {
                                messageManager.applyAICategory(to: message.id)
                            }) {
                                Text("应用")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                
                // 手动分类
                VStack(alignment: .leading, spacing: 12) {
                    Text("分类管理")
                        .font(.headline)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(MessageCategory.allCases, id: \.self) { category in
                            Button(action: {
                                messageManager.setCategory(category, for: message.id)
                                selectedCategory = category
                            }) {
                                HStack {
                                    Image(systemName: category.icon)
                                    Text(category.rawValue)
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    (message.category == category || selectedCategory == category) ?
                                    category.color.opacity(0.3) :
                                    Color(.systemGray5)
                                )
                                .foregroundColor(
                                    (message.category == category || selectedCategory == category) ?
                                    category.color :
                                    .primary
                                )
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                
                // 当前分类
                if let currentCategory = message.category {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("当前分类")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            Image(systemName: currentCategory.icon)
                                .foregroundColor(currentCategory.color)
                            Text(currentCategory.rawValue)
                                .font(.headline)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("短信详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}

