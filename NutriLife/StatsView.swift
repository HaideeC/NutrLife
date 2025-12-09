import SwiftUI
import Charts

struct StatsView: View {
    private let spendings: [DailySpending] = DailySpending.sample
    private let nutrientTrends: [NutrientTrend] = NutrientTrend.sample

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                spendingSection
                trendSection
            }
            .padding()
        }
        .navigationTitle("统计")
    }

    private var spendingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("近 7 天支出示意")
                .font(.headline)
            Chart(spendings) { item in
                BarMark(
                    x: .value("日期", item.date, unit: .day),
                    y: .value("支出", item.amount)
                )
                .foregroundStyle(.green.gradient)
            }
            .frame(height: 220)
            Text("当前展示为示意数据，未来将使用真实买菜记录生成。")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)).shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4))
    }

    private var trendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("营养趋势占位")
                .font(.headline)
            ForEach(nutrientTrends) { trend in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(trend.title)
                            .font(.subheadline)
                        Text(trend.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("\(trend.reachDays)/7 天")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                Divider()
            }
            Text("当前为示意数据，未来会结合真实记录进行达标天数统计与趋势提示。")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)).shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4))
    }
}

struct DailySpending: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double

    static var sample: [DailySpending] {
        let calendar = Calendar.current
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
            return DailySpending(date: date, amount: Double.random(in: 20...80))
        }.sorted { $0.date < $1.date }
    }
}

struct NutrientTrend: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let reachDays: Int

    static var sample: [NutrientTrend] {
        [
            NutrientTrend(title: "蛋白质接近推荐量", description: "本周已有多天接近推荐摄入。", reachDays: 4),
            NutrientTrend(title: "蔬菜水果充足", description: "蔬果摄入接近 5 份/天。", reachDays: 3),
            NutrientTrend(title: "膳食纤维有待提升", description: "可尝试多吃全谷物与豆类。", reachDays: 2)
        ]
    }
}

#Preview {
    NavigationStack {
        StatsView()
    }
}
