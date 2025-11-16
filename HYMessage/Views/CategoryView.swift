//
//  CategoryView.swift
//  HYMessage
//
//  Created on 2024
//

import SwiftUI

struct SignatureCategoryView: View {
    @ObservedObject var messageManager: MessageManager
    
    var body: some View {
        NavigationView {
            let grouped = messageManager.messagesGroupedBySignature()
            let sortedSignatures = grouped.keys.sorted()
            
            if messageManager.isLoading {
                ProgressView("加载中...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if sortedSignatures.isEmpty {
                Text("暂无短信")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(sortedSignatures, id: \.self) { signature in
                        Section(header: Text(signature)) {
                            ForEach(grouped[signature] ?? []) { message in
                                NavigationLink(destination: MessageDetailView(message: message, messageManager: messageManager)) {
                                    MessageRowView(message: message)
                                }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
        }
        .navigationTitle("按签名分类")
    }
}

struct AICategoryView: View {
    @ObservedObject var messageManager: MessageManager
    
    var body: some View {
        NavigationView {
            let grouped = messageManager.messagesGroupedByCategory()
            let sortedCategories = MessageCategory.allCases.filter { grouped[$0] != nil }
            
            if messageManager.isLoading {
                ProgressView("加载中...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if sortedCategories.isEmpty {
                Text("暂无短信")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(sortedCategories, id: \.self) { category in
                        Section(header: 
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                                Spacer()
                                Text("\(grouped[category]?.count ?? 0)")
                                    .foregroundColor(.secondary)
                            }
                        ) {
                            ForEach(grouped[category] ?? []) { message in
                                NavigationLink(destination: MessageDetailView(message: message, messageManager: messageManager)) {
                                    MessageRowView(message: message)
                                }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
        }
        .navigationTitle("AI智能分类")
    }
}

struct SettingsView: View {
    @ObservedObject var messageManager: MessageManager
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("数据管理")) {
                    Button(action: {
                        messageManager.loadMessages()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("刷新短信")
                        }
                    }
                    
                    Button(action: {
                        // 清空分类
                        for index in messageManager.messages.indices {
                            messageManager.messages[index].category = nil
                        }
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("清空分类")
                        }
                        .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("统计信息")) {
                    HStack {
                        Text("总短信数")
                        Spacer()
                        Text("\(messageManager.messages.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("已分类")
                        Spacer()
                        Text("\(messageManager.messages.filter { $0.category != nil }.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("签名数")
                        Spacer()
                        Text("\(Set(messageManager.messages.compactMap { $0.signature }).count)")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("说明")
                        Spacer()
                        Text("短信智能管理工具")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}

