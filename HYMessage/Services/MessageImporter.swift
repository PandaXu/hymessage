//
//  MessageImporter.swift
//  HYMessage
//
//  Created on 2024
//

import Foundation
import UniformTypeIdentifiers

class MessageImporter {
    
    // 从 CSV 文件导入短信
    static func importFromCSV(_ csvString: String) -> [Message] {
        var messages: [Message] = []
        let lines = csvString.components(separatedBy: .newlines)
        
        // 跳过标题行（如果有）
        let startIndex = lines.first?.contains("sender") == true ? 1 : 0
        
        for line in lines[startIndex...] where !line.isEmpty {
            let components = parseCSVLine(line)
            if components.count >= 3 {
                let sender = components[0].trimmingCharacters(in: .whitespaces)
                let content = components[1].trimmingCharacters(in: .whitespaces)
                let dateString = components[2].trimmingCharacters(in: .whitespaces)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let timestamp = dateFormatter.date(from: dateString) ?? Date()
                
                let message = Message(
                    sender: sender,
                    content: content,
                    timestamp: timestamp
                )
                messages.append(message)
            }
        }
        
        return messages
    }
    
    // 从 JSON 文件导入短信
    static func importFromJSON(_ jsonData: Data) -> [Message]? {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            // 尝试解析为数组
            if let messages = try? decoder.decode([Message].self, from: jsonData) {
                return messages
            }
            
            // 尝试解析为字典格式
            if let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
               let messagesArray = dict["messages"] as? [[String: Any]] {
                var messages: [Message] = []
                for msgDict in messagesArray {
                    if let sender = msgDict["sender"] as? String,
                       let content = msgDict["content"] as? String {
                        let timestamp: Date
                        if let dateString = msgDict["timestamp"] as? String {
                            let formatter = ISO8601DateFormatter()
                            timestamp = formatter.date(from: dateString) ?? Date()
                        } else {
                            timestamp = Date()
                        }
                        
                        let message = Message(
                            sender: sender,
                            content: content,
                            timestamp: timestamp
                        )
                        messages.append(message)
                    }
                }
                return messages
            }
        } catch {
            print("JSON 解析错误: \(error)")
        }
        
        return nil
    }
    
    // 从系统短信数据库尝试读取（需要越狱或特殊权限，通常不可用）
    static func importFromSystem() -> [Message]? {
        // iOS 系统限制：无法直接访问短信数据库
        // 此方法仅作为占位符，实际无法使用
        return nil
    }
    
    // 解析 CSV 行（处理引号和逗号）
    private static func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuotes = false
        
        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                result.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        result.append(current)
        
        return result
    }
    
    // 生成 CSV 模板
    static func generateCSVTemplate() -> String {
        return """
        sender,content,timestamp
        10086,【中国移动】您的验证码是123456，5分钟内有效，请勿泄露。,2024-01-01 12:00:00
        95588,【工商银行】您尾号1234的银行卡于12:30消费100.00元，余额5000.00元。,2024-01-01 13:30:00
        """
    }
    
    // 生成 JSON 模板
    static func generateJSONTemplate() -> String {
        return """
        {
          "messages": [
            {
              "sender": "10086",
              "content": "【中国移动】您的验证码是123456，5分钟内有效，请勿泄露。",
              "timestamp": "2024-01-01T12:00:00Z"
            },
            {
              "sender": "95588",
              "content": "【工商银行】您尾号1234的银行卡于12:30消费100.00元，余额5000.00元。",
              "timestamp": "2024-01-01T13:30:00Z"
            }
          ]
        }
        """
    }
}

