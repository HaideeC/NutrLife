import SwiftUI

// MARK: - 主入口
@main
struct NutrLifePrototypeApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

// MARK: - Tab 容器
struct MainTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("今日", systemImage: "sun.max.fill")
                }

            MarketView()
                .tabItem {
                    Label("买菜", systemImage: "cart.fill")
                }

            StatsView()
                .tabItem {
                    Label("统计", systemImage: "chart.bar.fill")
                }

            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
        }
        .tint(.green)
    }
}

// MARK: - 今日 Tab
struct TodayView: View {
    @State private var showVoiceSheet = false
    @State private var showAddMeal = false
    @State private var foodRecords: [TodayFoodRecord] = TodayFoodRecord.sample

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    summaryCard
                    recordActions
                    recordList
                }
                .padding()
            }
            .navigationTitle("今日")
            .sheet(isPresented: $showVoiceSheet) {
                VoicePlaceholderView()
            }
            .navigationDestination(isPresented: $showAddMeal) {
                AddFoodRecordView { newRecord in
                    foodRecords.append(newRecord)
                    showAddMeal = false
                }
            }
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("今日概览")
                .font(.title3.bold())
            VStack(spacing: 12) {
                progressRow(title: "能量", subtitle: "已达推荐量的 70%", value: 0.7, tint: .orange)
                progressRow(title: "蛋白质", subtitle: "82 g / 110 g", value: 0.74, tint: .blue)
                progressRow(title: "蔬菜水果", subtitle: "3 / 5 份", value: 0.6, tint: .green)
            }
            Divider()
            HStack(spacing: 10) {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.green)
                Text("今晚多加一份深色叶菜，顺便补点优质蛋白。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThickMaterial)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private var recordActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("记录入口")
                .font(.headline)
            VStack(spacing: 12) {
                Button {
                    showVoiceSheet = true
                } label: {
                    actionButton(title: "语音记录今天吃了什么", icon: "waveform.circle.fill", gradient: Gradient(colors: [.pink.opacity(0.85), .orange.opacity(0.8)]))
                }
                NavigationLink(isActive: $showAddMeal) {
                    EmptyView()
                } label: {
                    actionButton(title: "手动添加饮食记录", icon: "plus.circle.fill", gradient: Gradient(colors: [.blue.opacity(0.85), .teal.opacity(0.8)]))
                }
            }
        }
    }

    private var recordList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日已记录的食物")
                .font(.headline)
            if foodRecords.isEmpty {
                Text("还没有记录，试试上面的按钮吧。")
                    .foregroundColor(.secondary)
            } else {
                ForEach(foodRecords) { record in
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(record.name)
                                .font(.body.bold())
                            Text("重量：\(Int(record.grams)) 克")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            if let price = record.price {
                                Text(String(format: "价格：¥%.2f", price))
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                        Spacer()
                        Text(record.timeLabel)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.15))
                            .cornerRadius(10)
                    }
                    .padding()
                    .background(Color.white.opacity(0.85))
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                }
            }
        }
    }

    private func progressRow(title: String, subtitle: String, value: Double, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.subheadline.bold())
                Spacer()
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            ProgressView(value: value)
                .tint(tint)
                .accentColor(tint)
                .shadow(color: tint.opacity(0.25), radius: 4, x: 0, y: 2)
        }
    }

    private func actionButton(title: String, icon: String, gradient: Gradient) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text("语音记录 / 手动输入，快速补充今日饮食")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .foregroundColor(.white)
        .background(
            LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 4)
    }
}

// MARK: - 语音占位
struct VoicePlaceholderView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "waveform")
                    .font(.system(size: 60))
                    .foregroundColor(.pink)
                Text("语音记录占位")
                    .font(.title2.bold())
                Text("未来将在这里接入 iOS 语音识别与 AI 解析，自动识别你说的食物和重量。")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("语音记录")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }
}

// MARK: - 手动添加视图
struct AddFoodRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var grams: String = ""
    @State private var price: String = ""
    let onSave: (TodayFoodRecord) -> Void

    var body: some View {
        Form {
            Section(header: Text("食物信息")) {
                TextField("食物名称", text: $name)
                TextField("重量（克）", text: $grams)
                    .keyboardType(.numberPad)
                TextField("价格（可选，元）", text: $price)
                    .keyboardType(.decimalPad)
            }

            Section {
                Button {
                    guard let gramValue = Double(grams) else { return }
                    let priceValue = Double(price)
                    let record = TodayFoodRecord(name: name.isEmpty ? "未命名食物" : name, grams: gramValue, price: priceValue, timeLabel: "新增")
                    onSave(record)
                    dismiss()
                } label: {
                    Text("保存并添加到列表")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(grams.isEmpty)
            }
        }
        .navigationTitle("添加饮食记录")
    }
}

struct TodayFoodRecord: Identifiable {
    let id = UUID()
    let name: String
    let grams: Double
    let price: Double?
    let timeLabel: String

    static let sample: [TodayFoodRecord] = [
        TodayFoodRecord(name: "燕麦牛奶", grams: 320, price: 6.5, timeLabel: "早餐"),
        TodayFoodRecord(name: "鸡胸肉沙拉", grams: 350, price: 18.0, timeLabel: "午餐"),
        TodayFoodRecord(name: "虾仁西兰花", grams: 420, price: 22.0, timeLabel: "晚餐")
    ]
}

struct MealDetailView: View {
    let meal: Meal

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(meal.title)
                .font(.title3)
                .bold()
            Text(meal.detail)
                .font(.body)
            HStack {
                Label("时间: \(meal.time)", systemImage: "clock")
                Spacer()
                Label("场景: \(meal.scene)", systemImage: "leaf")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
        .navigationTitle(meal.time)
    }
}

// MARK: - 买菜 Tab
struct MarketView: View {
    @State private var itemAUnit: String = ""
    @State private var itemATotal: String = ""
    @State private var itemBUnit: String = ""
    @State private var itemBTotal: String = ""
    @State private var showCompareAlert = false

    private var itemAWeight: Double {
        guard let unit = Double(itemAUnit), let total = Double(itemATotal), unit > 0 else { return 0 }
        return total / unit * 500 // 元/斤 -> 克（1 斤 = 500g）
    }

    private var itemBWeight: Double {
        guard let unit = Double(itemBUnit), let total = Double(itemBTotal), unit > 0 else { return 0 }
        return total / unit * 500
    }

    private var cheaperTip: String {
        guard let unitA = Double(itemAUnit), let unitB = Double(itemBUnit), unitA > 0, unitB > 0 else { return "" }
        if unitA == unitB { return "两者价格相同" }
        return unitA < unitB ? "商品 A 更便宜" : "商品 B 更便宜"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("商品 A")) {
                    TextField("单价（元/斤）", text: $itemAUnit)
                        .keyboardType(.decimalPad)
                    TextField("总价（元）", text: $itemATotal)
                        .keyboardType(.decimalPad)
                    HStack {
                        Text("推算重量")
                        Spacer()
                        Text(String(format: "%.0f 克", itemAWeight))
                            .foregroundColor(.secondary)
                    }
                }
                Section(header: Text("商品 B")) {
                    TextField("单价（元/斤）", text: $itemBUnit)
                        .keyboardType(.decimalPad)
                    TextField("总价（元）", text: $itemBTotal)
                        .keyboardType(.decimalPad)
                    HStack {
                        Text("推算重量")
                        Spacer()
                        Text(String(format: "%.0f 克", itemBWeight))
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("每斤价格对比")) {
                    HStack {
                        Text("商品 A")
                        Spacer()
                        Text(itemAUnit.isEmpty ? "-" : "\(itemAUnit) 元/斤")
                    }
                    HStack {
                        Text("商品 B")
                        Spacer()
                        Text(itemBUnit.isEmpty ? "-" : "\(itemBUnit) 元/斤")
                    }
                    Button("给出提示") {
                        showCompareAlert = true
                    }
                }
            }
            .navigationTitle("买菜记录")
            .alert("对比结果", isPresented: $showCompareAlert) {
                Button("知道了") {}
            } message: {
                Text(cheaperTip.isEmpty ? "请输入两件商品的单价" : cheaperTip)
            }
        }
    }
}

// MARK: - 统计 Tab
struct StatsView: View {
    private let sampleSpend: [Double] = [52, 38, 64, 48, 59, 70, 45]
    private let sampleEnergy: [Double] = [1400, 1600, 1800, 1500, 1700, 1650, 1750]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("饮食支出趋势（元）")
                        .font(.headline)
                    barChart(values: sampleSpend, tint: .orange)
                        .frame(height: 160)

                    Text("能量摄入趋势（kcal）")
                        .font(.headline)
                    lineChart(values: sampleEnergy, tint: .blue)
                        .frame(height: 200)

                    summaryList
                }
                .padding()
            }
            .navigationTitle("统计")
        }
    }

    private var summaryList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("周摘要")
                .font(.headline)
            ForEach(0..<sampleSpend.count, id: \.self) { index in
                HStack {
                    Text("周 \(index + 1)")
                    Spacer()
                    Text("支出: \(Int(sampleSpend[index])) 元")
                        .foregroundColor(.secondary)
                }
                Divider()
            }
        }
    }

    private func barChart(values: [Double], tint: Color) -> some View {
        GeometryReader { geo in
            let maxValue = (values.max() ?? 1)
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(values.indices, id: \.self) { idx in
                    let heightRatio = maxValue == 0 ? 0 : values[idx] / maxValue
                    RoundedRectangle(cornerRadius: 8)
                        .fill(tint.opacity(0.8))
                        .frame(width: (geo.size.width - CGFloat(values.count - 1) * 12) / CGFloat(values.count), height: geo.size.height * heightRatio)
                        .overlay(alignment: .top) {
                            Text("\(Int(values[idx]))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                }
            }
        }
    }

    private func lineChart(values: [Double], tint: Color) -> some View {
        GeometryReader { geo in
            let maxValue = (values.max() ?? 1)
            let minValue = (values.min() ?? 0)
            let points: [CGPoint] = values.enumerated().map { idx, value in
                let x = geo.size.width / CGFloat(values.count - 1) * CGFloat(idx)
                let yRange = max(maxValue - minValue, 1)
                let y = geo.size.height * (1 - CGFloat((value - minValue) / yRange))
                return CGPoint(x: x, y: y)
            }

            Path { path in
                guard let first = points.first else { return }
                path.move(to: first)
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            .stroke(tint, lineWidth: 3)

            ForEach(points.indices, id: \.self) { idx in
                Circle()
                    .fill(tint)
                    .frame(width: 8, height: 8)
                    .position(points[idx])
            }
        }
    }
}

// MARK: - 我的 Tab
struct ProfileView: View {
    @State private var selectedRegion = "CN-Guangdong-Shenzhen"
    @State private var selectedScene = "normal"
    @State private var isEnglish = false
    @State private var showSubscribeSheet = false

    private let regions = ["CN-Guangdong-Shenzhen", "CN-Beijing", "CN-Shanghai"]
    private let scenes = ["normal", "weight_loss", "fitness", "period", "blood_qi"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("地区设置")) {
                    Picker("地区", selection: $selectedRegion) {
                        ForEach(regions, id: \.self) { region in
                            Text(region)
                        }
                    }
                }

                Section(header: Text("场景偏好")) {
                    Picker("饮食场景", selection: $selectedScene) {
                        ForEach(scenes, id: \.self) { scene in
                            Text(scene)
                        }
                    }
                }

                Section(header: Text("语言")) {
                    Toggle("英文界面（English UI）", isOn: $isEnglish)
                }

                Section(header: Text("订阅")) {
                    Button("了解高级订阅权益") {
                        showSubscribeSheet = true
                    }
                }
            }
            .navigationTitle("我的")
            .sheet(isPresented: $showSubscribeSheet) {
                SimplePlaceholderView(title: "订阅权益", message: "展示会员无限次分析、更多图表、家庭账号等描述")
            }
        }
    }
}

// MARK: - 公用视图
struct SimplePlaceholderView: View {
    let title: String
    let message: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text(title)
                    .font(.title2)
                    .bold()
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding()
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
}

// MARK: - 示例数据
struct Meal: Identifiable {
    let id = UUID()
    let time: String
    let title: String
    let detail: String
    let scene: String
}

let sampleMeals: [Meal] = [
    Meal(time: "早餐", title: "燕麦牛奶 + 香蕉", detail: "燕麦 40g，牛奶 200ml，香蕉 1 根", scene: "普通"),
    Meal(time: "午餐", title: "鸡胸肉沙拉", detail: "鸡胸肉 120g，生菜番茄，橄榄油少许", scene: "减脂"),
    Meal(time: "晚餐", title: "虾仁西兰花", detail: "虾仁 100g，西兰花 150g，糙米饭 80g", scene: "健身")
]

// MARK: - 预览
struct NutrLifePrototypeApp_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
