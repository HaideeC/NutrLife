import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var dataStore: AppDataStore
    @State private var showVoiceSheet = false
    @State private var showAddSheet = false

    private let energyProgress: Double = 0.72
    private let proteinProgress: Double = 0.65
    private let veggieProgress: Double = 0.58

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                overviewCard
                recordActions
                todayList
            }
            .padding()
        }
        .navigationTitle("今日")
        .sheet(isPresented: $showVoiceSheet) {
            VoicePlaceholderView()
        }
        .sheet(isPresented: $showAddSheet) {
            NavigationStack {
                AddMealView()
            }
            .presentationDetents([.medium, .large])
        }
    }

    private var overviewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日营养概要")
                .font(.title2)
                .bold()
            ProgressRow(title: "总能量", progress: energyProgress, description: "约 70% 推荐量")
            ProgressRow(title: "蛋白质", progress: proteinProgress, description: "距离目标还差一点")
            ProgressRow(title: "蔬菜水果", progress: veggieProgress, description: "今晚可以加一份深色绿叶菜")
            Divider()
            Text("建议：今晚可以加一份深色叶菜，增加膳食纤维和钾摄入。")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)).shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4))
    }

    private var recordActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("记录入口")
                .font(.headline)
            Button(action: { showVoiceSheet = true }) {
                HStack {
                    Image(systemName: "mic.fill")
                    VStack(alignment: .leading) {
                        Text("语音记录今天吃了什么")
                            .font(.body)
                        Text("未来将接入 iOS 语音识别 + AI 解析")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.green.opacity(0.12)))
            }

            Button(action: { showAddSheet = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("手动添加饮食")
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.blue.opacity(0.1)))
            }
        }
    }

    private var todayList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("今日记录")
                .font(.headline)
            if dataStore.meals(for: Date()).isEmpty {
                Text("今日还没有记录，试试语音或手动添加吧")
                    .foregroundColor(.secondary)
            } else {
                ForEach(dataStore.meals(for: Date())) { meal in
                    MealRow(meal: meal)
                }
            }
        }
    }
}

struct ProgressRow: View {
    let title: String
    let progress: Double
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                Spacer()
                Text(String(format: "%.0f%%", progress * 100))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            ProgressView(value: progress)
                .tint(.green)
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct MealRow: View {
    let meal: MealEntry
    private let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name)
                    .font(.headline)
                Text("约 \(Int(meal.weightGram)) 克 · \(meal.mealTime.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let price = meal.price {
                    Text(String(format: "花费：￥%.2f", price))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Text(formatter.string(from: meal.date))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))
    }
}

struct VoicePlaceholderView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("语音记录占位")
                .font(.title2)
                .bold()
            Text("未来将在此接入 iOS 语音识别，结合 AI 解析饮食内容。")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Spacer()
            Button("关闭") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct AddMealView: View {
    @EnvironmentObject private var dataStore: AppDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var weightGram: String = ""
    @State private var price: String = ""
    @State private var mealTime: MealTime = .breakfast

    var body: some View {
        Form {
            Section(header: Text("食物信息")) {
                TextField("食物名称", text: $name)
                TextField("重量（克）", text: $weightGram)
                    .keyboardType(.decimalPad)
                TextField("价格（可选）", text: $price)
                    .keyboardType(.decimalPad)
                Picker("餐次", selection: $mealTime) {
                    ForEach(MealTime.allCases) { time in
                        Text(time.rawValue).tag(time)
                    }
                }
            }

            Section {
                Button("保存到今日") {
                    saveMeal()
                }
                .disabled(!canSave)
            }
        }
        .navigationTitle("添加饮食记录")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("关闭") { dismiss() }
            }
        }
    }

    private var canSave: Bool {
        guard !name.isEmpty, let weight = Double(weightGram), weight > 0 else { return false }
        return true
    }

    private func saveMeal() {
        let weight = Double(weightGram) ?? 0
        let priceValue = Double(price)
        let entry = MealEntry(name: name, weightGram: weight, price: priceValue, mealTime: mealTime, date: Date())
        dataStore.addMeal(entry)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        TodayView()
            .environmentObject(AppDataStore())
    }
}
