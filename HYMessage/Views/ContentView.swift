//
//  ContentView.swift
//  HYMessage
//
//  Created on 2024
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var messageManager: MessageManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 全部短信
            MessageListView(messageManager: messageManager)
                .tabItem {
                    Label("全部", systemImage: "message.fill")
                }
                .tag(0)
            
            // 按签名分类
            SignatureCategoryView(messageManager: messageManager)
                .tabItem {
                    Label("签名", systemImage: "signature")
                }
                .tag(1)
            
            // 按AI分类
            AICategoryView(messageManager: messageManager)
                .tabItem {
                    Label("AI分类", systemImage: "brain.head.profile")
                }
                .tag(2)
            
            // 数据统计
            StatisticsView(messageManager: messageManager)
                .tabItem {
                    Label("统计", systemImage: "chart.bar.fill")
                }
                .tag(3)
            
            // 设置
            SettingsView(messageManager: messageManager)
                .tabItem {
                    Label("设置", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .onAppear {
            // 如果消息列表为空，则加载消息
            // 否则 App 启动时已经通过 syncAndReclassify 处理了
            if messageManager.messages.isEmpty {
                messageManager.loadMessages()
            }
        }
    }
}

struct MessageListView: View {
    @ObservedObject var messageManager: MessageManager
    @State private var searchText = ""
    @State private var selectedCategory: MessageCategory?
    
    var filteredMessages: [Message] {
        var messages = messageManager.messages
        
        if !searchText.isEmpty {
            messages = messages.filter { message in
                message.content.localizedCaseInsensitiveContains(searchText) ||
                message.sender.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let category = selectedCategory {
            messages = messages.filter { message in
                let messageCategory = message.category ?? message.aiSuggestedCategory ?? .other
                return messageCategory == category
            }
        }
        
        return messages
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if messageManager.isLoading {
                    ProgressView("加载中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredMessages) { message in
                        NavigationLink(destination: MessageDetailView(message: message, messageManager: messageManager)) {
                            MessageRowView(message: message)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .searchable(text: $searchText, prompt: "搜索短信")
                }
            }
            .navigationTitle("全部短信")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("全部") {
                            selectedCategory = nil
                        }
                        ForEach(MessageCategory.allCases, id: \.self) { category in
                            Button(category.rawValue) {
                                selectedCategory = category
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        messageManager.loadMessages()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

struct MessageRowView: View {
    let message: Message
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(message.sender)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let signature = message.signature {
                    Text(signature)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            Text(message.content)
                .font(.body)
                .lineLimit(2)
                .foregroundColor(.secondary)
            
            HStack {
                Text(message.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // 确保所有消息都显示分类，无法分类的显示"其他"
                let category = message.category ?? message.aiSuggestedCategory ?? .other
                Label(category.rawValue, systemImage: category.icon)
                    .font(.caption)
                    .foregroundColor(category.color)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
        .environmentObject(MessageManager())
}

