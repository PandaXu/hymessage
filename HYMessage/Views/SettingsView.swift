//
//  SettingsView.swift
//  HYMessage
//
//  Created on 2024
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var messageManager: MessageManager
    @StateObject private var filterManager = FilterRulesManager.shared
    @State private var showFilterSettings = false
    @State private var showExtensionSettings = false
    
    var body: some View {
        NavigationView {
            Form {
                // SMS Filter Extension 设置
                Section(header: Text("短信过滤扩展")) {
                    Button(action: {
                        showExtensionSettings = true
                    }) {
                        HStack {
                            Image(systemName: "shield.checkered")
                            Text("管理短信过滤")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                    
                    Text("SMS Filter Extension 可以在系统级别对短信进行分类和过滤")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 过滤规则设置
                Section(header: Text("过滤规则"), footer: Text("过滤规则会自动应用到 iMessage，系统会根据规则自动过滤新收到的短信")) {
                    NavigationLink(destination: FilterRulesView(filterManager: filterManager)) {
                        HStack {
                            Image(systemName: "list.bullet.rectangle")
                            Text("管理过滤规则")
                            Spacer()
                            let stats = filterManager.getRulesStatistics()
                            if stats.enabledCount > 0 {
                                Text("\(stats.enabledCount) 条启用")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Toggle("自动过滤营销短信", isOn: $filterManager.autoFilterPromotion)
                        .onChange(of: filterManager.autoFilterPromotion) { newValue in
                            filterManager.saveRules()
                            print("[SettingsView] ✅ 自动过滤营销短信: \(newValue)")
                        }
                    
                    Button(action: {
                        // 从现有消息中提取签名并创建规则
                        filterManager.createRulesFromMessages(messageManager.messages)
                        filterManager.saveRules()
                    }) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                            Text("从短信中提取签名规则")
                        }
                    }
                    
                    Button(action: {
                        // 验证规则是否已保存
                        if filterManager.verifyRulesSaved() {
                            // 可以显示成功提示
                        }
                    }) {
                        HStack {
                            Image(systemName: "checkmark.shield")
                            Text("验证规则已保存")
                        }
                    }
                }
                
                // 数据管理
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
                            Text("重新加载短信")
                        }
                    }
                    
                    Button(action: {
                        messageManager.syncFromExtension()
                    }) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("同步 Extension 数据")
                        }
                    }
                    
                    Button(action: {
                        messageManager.reclassifyAllMessages()
                    }) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                            Text("重新分类所有短信")
                        }
                    }
                    
                    Button(action: {
                        messageManager.syncAndReclassify()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle.fill")
                            Text("同步并重新分类")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        // 清空分类
                        for index in messageManager.messages.indices {
                            messageManager.messages[index].category = nil
                        }
                    }) {
                        HStack {
                            Image(systemName: "tag.slash")
                            Text("清空分类")
                        }
                        .foregroundColor(.orange)
                    }
                    
                    Button(role: .destructive, action: {
                        messageManager.clearStoredMessages()
                        messageManager.messages = []
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("清空所有数据")
                        }
                    }
                }
                
                // 统计信息
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
                        Text("\(messageManager.messages.filter { $0.category != nil || $0.aiSuggestedCategory != nil }.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("签名数")
                        Spacer()
                        Text("\(Set(messageManager.messages.compactMap { $0.signature }).count)")
                            .foregroundColor(.secondary)
                    }
                }
                
                // 关于
                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://github.com/PandaXu/hymessage")!) {
                        HStack {
                            Image(systemName: "link")
                            Text("GitHub 仓库")
                        }
                    }
                }
            }
            .navigationTitle("设置")
            .sheet(isPresented: $showExtensionSettings) {
                ExtensionSettingsView()
            }
        }
    }
}

// MARK: - Extension Settings View

struct ExtensionSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var extensionStatus: ExtensionStatus = .unknown
    
    enum ExtensionStatus {
        case enabled
        case disabled
        case unknown
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Extension 状态")) {
                    HStack {
                        Text("状态")
                        Spacer()
                        statusBadge
                    }
                    
                    if extensionStatus == .enabled {
                        Text("短信过滤扩展已启用，系统会自动对短信进行分类和过滤")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else if extensionStatus == .disabled {
                        Text("短信过滤扩展未启用，请在系统设置中启用")
                            .font(.caption)
                            .foregroundColor(.orange)
                    } else {
                        Text("无法确定 Extension 状态")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("如何启用")) {
                    VStack(alignment: .leading, spacing: 12) {
                        instructionStep(number: 1, text: "打开「设置」应用")
                        instructionStep(number: 2, text: "进入「信息」")
                        instructionStep(number: 3, text: "选择「未知与过滤信息」")
                        instructionStep(number: 4, text: "选择「短信过滤」")
                        instructionStep(number: 5, text: "启用「短信智能管理」")
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    Button(action: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "gear")
                            Text("打开系统设置")
                        }
                    }
                }
            }
            .navigationTitle("Extension 设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                checkExtensionStatus()
            }
        }
    }
    
    private var statusBadge: some View {
        Group {
            switch extensionStatus {
            case .enabled:
                Label("已启用", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            case .disabled:
                Label("未启用", systemImage: "xmark.circle.fill")
                    .foregroundColor(.orange)
            case .unknown:
                Label("请检查系统设置", systemImage: "questionmark.circle.fill")
                    .foregroundColor(.gray)
            @unknown default:
                Label("请检查系统设置", systemImage: "questionmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func instructionStep(number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
        }
    }
    
    private func checkExtensionStatus() {
        // 注意：ILMessageFilterExtensionState 需要 iOS 12.0+
        // 这里使用简化的检查方式
        // 实际实现中，可以通过检查 Extension 是否在系统中注册来判断
        // 由于无法直接检查，默认显示为 unknown，用户需要在系统设置中查看
        extensionStatus = .unknown
    }
}

// MARK: - Filter Rules View

struct FilterRulesView: View {
    @ObservedObject var filterManager: FilterRulesManager
    @State private var showAddSignatureAlert = false
    @State private var newSignature = ""
    
    var body: some View {
        Form {
            // 规则说明
            Section(footer: Text("这些规则会自动应用到 iMessage。当收到新短信时，系统会根据这些规则自动过滤。")) {
                let stats = filterManager.getRulesStatistics()
                HStack {
                    Text("规则统计")
                    Spacer()
                    Text("签名: \(stats.signatureCount) | 分类: \(stats.categoryCount) | 启用: \(stats.enabledCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 按签名过滤
            Section(header: Text("按签名过滤"), footer: Text("匹配指定签名的短信将被过滤")) {
                ForEach(Array(filterManager.rules.signatureRules.keys.sorted()), id: \.self) { signature in
                    if let rule = filterManager.rules.signatureRules[signature] {
                        HStack {
                            Text(signature)
                                .font(.body)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { rule.enabled && rule.action == .filter },
                                set: { enabled in
                                    print("[FilterRulesView] 更新签名规则: \(signature) -> \(enabled ? "filter" : "allow")")
                                    filterManager.updateSignatureRule(signature: signature, action: enabled ? .filter : .allow)
                                }
                            ))
                        }
                    }
                }
                
                if filterManager.rules.signatureRules.isEmpty {
                    Text("暂无签名规则")
                        .foregroundColor(.secondary)
                }
                
                Button(action: {
                    showAddSignatureAlert = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("添加签名规则")
                    }
                    .foregroundColor(.blue)
                }
            }
            
            // 按分类过滤
            Section(header: Text("按分类过滤"), footer: Text("匹配指定分类的短信将被过滤")) {
                ForEach(MessageCategory.allCases, id: \.self) { category in
                    HStack {
                        Label(category.rawValue, systemImage: category.icon)
                            .foregroundColor(category.color)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { 
                                filterManager.rules.categoryRules[category]?.enabled == true &&
                                filterManager.rules.categoryRules[category]?.action == .filter
                            },
                            set: { enabled in
                                print("[FilterRulesView] 更新分类规则: \(category.rawValue) -> \(enabled ? "filter" : "allow")")
                                filterManager.updateCategoryRule(category: category, action: enabled ? .filter : .allow)
                            }
                        ))
                    }
                }
            }
            
            // 规则操作
            Section(header: Text("规则操作")) {
                Button(action: {
                    // 验证规则
                    if filterManager.verifyRulesSaved() {
                        print("[FilterRulesView] ✅ 规则验证成功")
                    }
                }) {
                    HStack {
                        Image(systemName: "checkmark.shield")
                        Text("验证规则")
                    }
                }
                
                Button(role: .destructive, action: {
                    // 清空所有规则
                    filterManager.rules = FilterRules()
                    filterManager.saveRules()
                    print("[FilterRulesView] 🗑️ 已清空所有规则")
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("清空所有规则")
                    }
                }
            }
        }
        .navigationTitle("过滤规则")
        .navigationBarTitleDisplayMode(.inline)
        .alert("添加签名规则", isPresented: $showAddSignatureAlert) {
            TextField("输入签名", text: $newSignature)
            Button("取消", role: .cancel) {
                newSignature = ""
            }
            Button("添加") {
                if !newSignature.isEmpty {
                    let signatureToAdd = newSignature
                    filterManager.updateSignatureRule(signature: signatureToAdd, action: .filter)
                    newSignature = ""
                    print("[FilterRulesView] ✅ 添加签名规则: \(signatureToAdd)")
                }
            }
        } message: {
            Text("输入要过滤的短信签名（例如：中国移动、京东等）")
        }
    }
}

