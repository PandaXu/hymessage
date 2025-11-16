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
            let sortedCategories = MessageCategory.allCases.filter { grouped[$0] != nil }
            
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
                                    Text("\(grouped[category]?.count ?? 0)")
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

struct SettingsView: View {
    @ObservedObject var messageManager: MessageManager
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("数据管理")) {
                    NavigationLink(destination: ImportMessageView(messageManager: messageManager)) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("导入短信")
                        }
                    }
                    
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

