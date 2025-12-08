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
    @State private var showManualSheet = false
    @State private var showAdviceAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    summaryCard
                    quickActions
                    latestMeals
                }
                .padding()
            }
            .navigationTitle("今日饮食")
            .toolbar {
                Button {
                    showAdviceAlert = true
                } label: {
                    Image(systemName: "sparkles")
                }
            }
            .alert("这是示意营养建议，未来可接入 AI", isPresented: $showAdviceAlert) {
                Button("好的") {}
            }
            .sheet(isPresented: $showVoiceSheet) {
                SimplePlaceholderView(title: "语音记录", message: "这里展示语音录制和识别界面")
            }
            .sheet(isPresented: $showManualSheet) {
                SimplePlaceholderView(title: "手动添加", message: "这里填写食材、重量和用餐时间")
            }
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日营养概要")
                .font(.title3)
                .bold()
            HStack(alignment: .top, spacing: 12) {
                nutrientBadge(title: "能量", value: "1560 kcal", status: "适中", color: .orange)
                nutrientBadge(title: "蛋白质", value: "82 g", status: "稍低", color: .blue)
                nutrientBadge(title: "蔬果", value: "3/5 份", status: "需补充", color: .green)
            }
            Divider()
            Text("建议：晚餐增加优质蛋白（如鸡胸肉、豆制品），多吃一份深色蔬菜。")
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(16)
    }

    private var quickActions: some View {
        VStack(spacing: 12) {
            HStack {
                Text("快速记录")
                    .font(.headline)
                Spacer()
            }
            HStack(spacing: 12) {
                Button {
                    showVoiceSheet = true
                } label: {
                    actionButtonLabel(title: "语音记录", systemImage: "mic.fill", color: .pink)
                }
                Button {
                    showManualSheet = true
                } label: {
                    actionButtonLabel(title: "手动添加", systemImage: "plus.circle.fill", color: .blue)
                }
            }
        }
    }

    private var latestMeals: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日吃了什么")
                .font(.headline)
            ForEach(sampleMeals) { meal in
                NavigationLink {
                    MealDetailView(meal: meal)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(meal.time)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(meal.scene)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                        Text(meal.title)
                            .font(.body)
                        Text(meal.detail)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.green.opacity(0.08))
                    .cornerRadius(12)
                }
            }
        }
    }

    private func nutrientBadge(title: String, value: String, status: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
            Text(value)
                .font(.headline)
                .bold()
            Text(status)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(color.opacity(0.15))
                .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func actionButtonLabel(title: String, systemImage: String, color: Color) -> some View {
        HStack {
            Image(systemName: systemImage)
            Text(title)
        }
        .font(.headline)
        .padding()
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.15))
        .foregroundColor(color)
        .cornerRadius(12)
    }
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
