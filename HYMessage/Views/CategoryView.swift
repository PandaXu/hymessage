//
//  CategoryView.swift
//  HYMessage
//
//  Created on 2024
//

import SwiftUI

struct SignatureCategoryView: View {
    @ObservedObject var messageManager: MessageManager
    @State private var selectedMessages: Set<String> = []
    @State private var isEditMode: EditMode = .inactive
    @State private var showDeleteAlert = false
    @State private var deleteTarget: String? = nil
    
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
                List(selection: $selectedMessages) {
                    ForEach(sortedSignatures, id: \.self) { signature in
                        Section(header: 
                            HStack {
                                Text(signature)
                                Spacer()
                                if isEditMode == .active {
                                    Button(action: {
                                        deleteTarget = signature
                                        showDeleteAlert = true
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                } else {
                                    Text("\(grouped[signature]?.count ?? 0)条")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        ) {
                            ForEach(grouped[signature] ?? []) { message in
                                if isEditMode == .active {
                                    MessageRowView(message: message)
                                        .tag(message.id)
                                } else {
                                    NavigationLink(destination: MessageDetailView(message: message, messageManager: messageManager)) {
                                        MessageRowView(message: message)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .environment(\.editMode, $isEditMode)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            if isEditMode == .active {
                                Button("取消") {
                                    isEditMode = .inactive
                                    selectedMessages.removeAll()
                                }
                                
                                if !selectedMessages.isEmpty {
                                    Button("删除(\(selectedMessages.count))") {
                                        messageManager.deleteMessages(Array(selectedMessages))
                                        selectedMessages.removeAll()
                                        if messageManager.messages.isEmpty {
                                            isEditMode = .inactive
                                        }
                                    }
                                    .foregroundColor(.red)
                                }
                                
                                Button("全选") {
                                    let allIds = grouped.values.flatMap { $0.map { $0.id } }
                                    selectedMessages = Set(allIds)
                                }
                                
                                Button("全部删除") {
                                    showDeleteAlert = true
                                    deleteTarget = "all"
                                }
                                .foregroundColor(.red)
                            } else {
                                Button("编辑") {
                                    isEditMode = .active
                                }
                            }
                        }
                    }
                }
                .alert("确认删除", isPresented: $showDeleteAlert) {
                    Button("取消", role: .cancel) { }
                    Button("删除", role: .destructive) {
                        if let target = deleteTarget {
                            if target == "all" {
                                messageManager.deleteAllMessages()
                                isEditMode = .inactive
                            } else {
                                messageManager.deleteMessagesBySignature(target)
                            }
                            deleteTarget = nil
                        }
                    }
                } message: {
                    if let target = deleteTarget {
                        if target == "all" {
                            Text("确定要删除所有短信吗？此操作无法撤销。")
                        } else {
                            Text("确定要删除\"\(target)\"签名的所有短信吗？")
                        }
                    }
                }
            }
        }
        .navigationTitle("按签名分类")
    }
}

struct AICategoryView: View {
    @ObservedObject var messageManager: MessageManager
    @State private var selectedMessages: Set<String> = []
    @State private var isEditMode: EditMode = .inactive
    @State private var showDeleteAlert = false
    @State private var deleteTarget: MessageCategory? = nil
    
    var body: some View {
        NavigationView {
            let grouped = messageManager.messagesGroupedByCategory()
            // 确保"其他"分类总是显示，即使没有消息也显示（显示为0条）
            let sortedCategories = MessageCategory.allCases.filter { 
                grouped[$0] != nil || $0 == .other 
            }
            
            if messageManager.isLoading {
                ProgressView("加载中...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if sortedCategories.isEmpty {
                Text("暂无短信")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(selection: $selectedMessages) {
                    ForEach(sortedCategories, id: \.self) { category in
                        Section(header: 
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                                Spacer()
                                if isEditMode == .active {
                                    Button(action: {
                                        deleteTarget = category
                                        showDeleteAlert = true
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                } else {
                                    let count = grouped[category]?.count ?? 0
                                    Text("\(count)条")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        ) {
                            ForEach(grouped[category] ?? []) { message in
                                if isEditMode == .active {
                                    MessageRowView(message: message)
                                        .tag(message.id)
                                } else {
                                    NavigationLink(destination: MessageDetailView(message: message, messageManager: messageManager)) {
                                        MessageRowView(message: message)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .environment(\.editMode, $isEditMode)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            if isEditMode == .active {
                                Button("取消") {
                                    isEditMode = .inactive
                                    selectedMessages.removeAll()
                                }
                                
                                if !selectedMessages.isEmpty {
                                    Button("删除(\(selectedMessages.count))") {
                                        messageManager.deleteMessages(Array(selectedMessages))
                                        selectedMessages.removeAll()
                                        if messageManager.messages.isEmpty {
                                            isEditMode = .inactive
                                        }
                                    }
                                    .foregroundColor(.red)
                                }
                                
                                Button("全选") {
                                    let allIds = grouped.values.flatMap { $0.map { $0.id } }
                                    selectedMessages = Set(allIds)
                                }
                                
                                Button("全部删除") {
                                    showDeleteAlert = true
                                    deleteTarget = nil // nil 表示全部删除
                                }
                                .foregroundColor(.red)
                            } else {
                                Button("编辑") {
                                    isEditMode = .active
                                }
                            }
                        }
                    }
                }
                .alert("确认删除", isPresented: $showDeleteAlert) {
                    Button("取消", role: .cancel) { }
                    Button("删除", role: .destructive) {
                        if let target = deleteTarget {
                            messageManager.deleteMessagesByCategory(target)
                        } else {
                            // 全部删除
                            messageManager.deleteAllMessages()
                            isEditMode = .inactive
                        }
                        deleteTarget = nil
                    }
                } message: {
                    if let target = deleteTarget {
                        Text("确定要删除\"\(target.rawValue)\"分类的所有短信吗？")
                    } else {
                        Text("确定要删除所有短信吗？此操作无法撤销。")
                    }
                }
            }
        }
        .navigationTitle("AI智能分类")
    }
}

// SettingsView 已移至独立的 SettingsView.swift 文件

