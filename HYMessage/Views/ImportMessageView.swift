//
//  ImportMessageView.swift
//  HYMessage
//
//  Created on 2024
//

import SwiftUI
import UniformTypeIdentifiers

struct ImportMessageView: View {
    @ObservedObject var messageManager: MessageManager
    @Environment(\.dismiss) var dismiss
    @State private var showDocumentPicker = false
    @State private var showFileImporter = false
    @State private var importFormat: MessageManager.ImportFormat = .csv
    @State private var showTemplate = false
    @State private var templateContent = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("导入方式")) {
                    Text("由于 iOS 系统限制，无法直接读取短信数据库。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("请使用以下方式导入短信：")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("从文件导入")) {
                    Picker("文件格式", selection: $importFormat) {
                        Text("CSV").tag(MessageManager.ImportFormat.csv)
                        Text("JSON").tag(MessageManager.ImportFormat.json)
                    }
                    
                    Button(action: {
                        showFileImporter = true
                    }) {
                        HStack {
                            Image(systemName: "doc.badge.plus")
                            Text("选择文件导入")
                        }
                    }
                }
                
                Section(header: Text("文件格式说明")) {
                    Button(action: {
                        showTemplate = true
                        templateContent = importFormat == .csv 
                            ? MessageImporter.generateCSVTemplate()
                            : MessageImporter.generateJSONTemplate()
                    }) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("查看格式模板")
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        if importFormat == .csv {
                            Text("CSV 格式：")
                                .font(.headline)
                            Text("sender,content,timestamp")
                                .font(.system(.body, design: .monospaced))
                            Text("10086,【中国移动】验证码123456,2024-01-01 12:00:00")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.secondary)
                        } else {
                            Text("JSON 格式：")
                                .font(.headline)
                            Text("{\n  \"messages\": [\n    {\n      \"sender\": \"10086\",\n      \"content\": \"...\",\n      \"timestamp\": \"2024-01-01T12:00:00Z\"\n    }\n  ]\n}")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("如何获取短信数据")) {
                    VStack(alignment: .leading, spacing: 12) {
                        // Shortcuts 自动化
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "app.badge")
                                    .foregroundColor(.blue)
                                Text("Shortcuts 自动化（推荐）")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            Text("使用 Shortcuts App 可以简化导出流程")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                if let url = URL(string: "shortcuts://") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.right.circle")
                                    Text("打开 Shortcuts App")
                                }
                                .font(.caption)
                            }
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 4)
                        
                        Divider()
                        
                        // 第三方工具
                        VStack(alignment: .leading, spacing: 4) {
                            Text("使用第三方工具导出短信")
                                .font(.subheadline)
                            Text("   • iMazing（推荐）")
                            Text("   • iExplorer")
                            Text("   • 3uTools")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        
                        // iCloud 备份
                        VStack(alignment: .leading, spacing: 4) {
                            Text("从 iCloud 备份导出")
                                .font(.subheadline)
                            Text("需要解析备份文件，操作较复杂")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        
                        // 手动创建
                        VStack(alignment: .leading, spacing: 4) {
                            Text("手动创建 CSV/JSON 文件")
                                .font(.subheadline)
                            Text("适合少量短信数据")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .padding(.vertical, 4)
                }
                
                Section {
                    Button(action: {
                        messageManager.loadMessages()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("重新加载")
                        }
                    }
                }
            }
            .navigationTitle("导入短信")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: importFormat == .csv 
                    ? [UTType.commaSeparatedText, UTType.plainText]
                    : [UTType.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        importFile(from: url)
                    }
                case .failure(let error):
                    messageManager.errorMessage = "文件选择失败: \(error.localizedDescription)"
                }
            }
            .sheet(isPresented: $showTemplate) {
                TemplateView(content: templateContent, format: importFormat)
            }
        }
    }
    
    private func importFile(from url: URL) {
        // 获取文件访问权限
        guard url.startAccessingSecurityScopedResource() else {
            messageManager.errorMessage = "无法访问文件"
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let data = try Data(contentsOf: url)
            messageManager.importMessages(from: data, format: importFormat)
        } catch {
            messageManager.errorMessage = "读取文件失败: \(error.localizedDescription)"
        }
    }
}

struct TemplateView: View {
    let content: String
    let format: MessageManager.ImportFormat
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(content)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("格式模板")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        UIPasteboard.general.string = content
                    }) {
                        Image(systemName: "doc.on.doc")
                    }
                }
            }
        }
    }
}

