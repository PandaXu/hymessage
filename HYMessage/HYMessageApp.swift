//
//  HYMessageApp.swift
//  HYMessage
//
//  Created on 2024
//

import SwiftUI

@main
struct HYMessageApp: App {
    @StateObject private var messageManager = MessageManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(messageManager)
                .onAppear {
                    print("[HYMessageApp] 📱 App 启动")
                    // App 启动时自动同步 Extension 数据并重新分类
                    messageManager.syncAndReclassify()
                }
        }
    }
}

