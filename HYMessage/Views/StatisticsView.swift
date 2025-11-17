//
//  StatisticsView.swift
//  HYMessage
//
//  Created on 2024
//

import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct StatisticsView: View {
    @ObservedObject var messageManager: MessageManager
    @StateObject private var filterManager = FilterRulesManager.shared
    @State private var selectedTimeRange: TimeRange = .all
    
    enum TimeRange: String, CaseIterable {
        case all = "全部"
        case last7Days = "最近7天"
        case last30Days = "最近30天"
        case last90Days = "最近90天"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 时间范围选择
                    Picker("时间范围", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    // 总体统计
                    overallStatisticsSection
                    
                    // 分类统计
                    categoryStatisticsSection
                    
                    // 签名统计
                    signatureStatisticsSection
                    
                    // 过滤规则统计
                    filterRulesStatisticsSection
                    
                    // 时间分布
                    timeDistributionSection
                }
                .padding()
            }
            .navigationTitle("数据统计")
            .refreshable {
                // 刷新统计数据（Extension 数据会自动从 App Group 读取）
                print("[StatisticsView] 🔄 刷新统计数据")
            }
        }
    }
    
    // MARK: - 数据来源说明
    private var dataSourceInfoSection: some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.blue)
            Text("统计数据来自 SMSFilterExtension 处理的短信分类历史")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    // MARK: - 总体统计
    private var overallStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("总体统计")
                .font(.headline)
                .padding(.bottom, 4)
            
            let stats = messageManager.getStatistics(timeRange: selectedTimeRange)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    title: "总短信数",
                    value: "\(stats.totalMessages)",
                    icon: "message.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "已分类",
                    value: "\(stats.classifiedMessages)",
                    icon: "tag.fill",
                    color: .green
                )
                
                StatCard(
                    title: "签名数",
                    value: "\(stats.signatureCount)",
                    icon: "signature",
                    color: .orange
                )
                
                StatCard(
                    title: "过滤规则",
                    value: "\(stats.filterRulesCount)",
                    icon: "shield.checkered",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - 分类统计
    private var categoryStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("分类统计")
                .font(.headline)
                .padding(.bottom, 4)
            
            let categoryStats = messageManager.getCategoryStatistics(timeRange: selectedTimeRange)
            let total = categoryStats.values.reduce(0, +)
            
            ForEach(MessageCategory.allCases, id: \.self) { category in
                let count = categoryStats[category] ?? 0
                let percentage = total > 0 ? Double(count) / Double(total) * 100 : 0
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label(category.rawValue, systemImage: category.icon)
                            .foregroundColor(category.color)
                            .font(.body)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(count)条")
                                .font(.headline)
                            Text(String(format: "%.1f%%", percentage))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // 进度条
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .frame(height: 6)
                                .cornerRadius(3)
                            
                            Rectangle()
                                .fill(category.color)
                                .frame(width: geometry.size.width * CGFloat(percentage / 100), height: 6)
                                .cornerRadius(3)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - 签名统计
    private var signatureStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("签名统计（Top 10）")
                .font(.headline)
                .padding(.bottom, 4)
            
            let signatureStats = messageManager.getSignatureStatistics(timeRange: selectedTimeRange)
            let topSignatures = Array(signatureStats.sorted { $0.value > $1.value }.prefix(10))
            
            if topSignatures.isEmpty {
                Text("暂无签名数据")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(Array(topSignatures.enumerated()), id: \.element.key) { index, item in
                    HStack {
                        Text("\(index + 1)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 24)
                        
                        Text(item.key)
                            .font(.body)
                        
                        Spacer()
                        
                        Text("\(item.value)条")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - 过滤规则统计
    private var filterRulesStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("过滤规则统计")
                .font(.headline)
                .padding(.bottom, 4)
            
            let rulesStats = filterManager.getRulesStatistics()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("签名规则")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(rulesStats.signatureCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("分类规则")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(rulesStats.categoryCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("已启用")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(rulesStats.enabledCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            
            Divider()
            
            // 过滤效果统计
            let filterStats = messageManager.getFilterStatistics()
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("预计过滤")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(filterStats.estimatedFiltered)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("允许通过")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(filterStats.estimatedAllowed)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - 时间分布
    private var timeDistributionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("时间分布")
                .font(.headline)
                .padding(.bottom, 4)
            
            let timeStats = messageManager.getTimeDistribution(timeRange: selectedTimeRange)
            
            #if canImport(Charts)
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(Array(timeStats.enumerated()), id: \.offset) { index, count in
                        BarMark(
                            x: .value("日期", index),
                            y: .value("数量", count)
                        )
                        .foregroundStyle(.blue)
                    }
                }
                .frame(height: 200)
            } else {
                simpleTimeDistributionView(timeStats: timeStats)
            }
            #else
            simpleTimeDistributionView(timeStats: timeStats)
            #endif
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - 简单时间分布视图（兼容 iOS 16 以下）
    @ViewBuilder
    private func simpleTimeDistributionView(timeStats: [Int]) -> some View {
        VStack(spacing: 8) {
            ForEach(Array(timeStats.enumerated()), id: \.offset) { index, count in
                HStack {
                    Text(getTimeLabel(for: index))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    
                    // 简单的进度条
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            let maxCount = timeStats.max() ?? 1
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: geometry.size.width * CGFloat(Double(count) / Double(maxCount)), height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                    .frame(width: 100)
                    
                    Text("\(count)条")
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(width: 50, alignment: .trailing)
                }
            }
        }
    }
    
    private func getTimeLabel(for index: Int) -> String {
        switch selectedTimeRange {
        case .all:
            return "第\(index + 1)周"
        case .last7Days:
            return "\(index + 1)天前"
        case .last30Days:
            return "\(index + 1)天前"
        case .last90Days:
            return "第\(index + 1)周"
        }
    }
}

// MARK: - 统计卡片
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}

#Preview {
    StatisticsView(messageManager: MessageManager())
}

