import SwiftUI

struct PriceView: View {
    @State private var itemA = PriceItem(name: "菜心", unitPrice: 6.5, unit: .jin, totalPrice: 9.0)
    @State private var itemB = PriceItem(name: "鸡胸肉", unitPrice: 18.0, unit: .kilogram, totalPrice: 36.0)

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PriceCard(title: "商品 A", item: $itemA, accent: .green)
                PriceCard(title: "商品 B", item: $itemB, accent: .blue)
                comparisonSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("买菜")
    }

    private var comparisonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("对比结果")
                .font(.headline)
            Text(comparisonText())
                .font(.body)
                .foregroundColor(.primary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)).shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3))
        }
    }

    private func comparisonText() -> String {
        let priceA = itemA.pricePerJin
        let priceB = itemB.pricePerJin
        let diff = abs(priceA - priceB)
        if diff < 0.3 {
            return "差不多，可以看新鲜度和口感选择"
        } else if priceA < priceB {
            return String(format: "A 更便宜，每斤便宜 %.2f 元", priceB - priceA)
        } else {
            return String(format: "B 更便宜，每斤便宜 %.2f 元", priceA - priceB)
        }
    }
}

struct PriceItem {
    var name: String
    var unitPrice: Double
    var unit: PriceUnit
    var totalPrice: Double

    var weight: Double {
        guard unitPrice > 0 else { return 0 }
        return totalPrice / unitPrice
    }

    var pricePerJin: Double {
        unit.pricePerJin(from: unitPrice)
    }
}

struct PriceCard: View {
    let title: String
    @Binding var item: PriceItem
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            TextField("食材名称", text: $item.name)
                .textFieldStyle(.roundedBorder)
            HStack {
                TextField("单价（元）", value: $item.unitPrice, formatter: numberFormatter)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                Picker("单位", selection: $item.unit) {
                    ForEach(PriceUnit.allCases) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
            }
            TextField("本次总价（元）", value: $item.totalPrice, formatter: numberFormatter)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)

            VStack(alignment: .leading, spacing: 8) {
                Text("重量估算：" + item.unit.formattedWeight(amount: item.weight))
                Text(String(format: "折算每斤价格：￥%.2f", item.pricePerJin))
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)).shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4))
    }

    private var numberFormatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 2
        nf.minimumFractionDigits = 0
        return nf
    }
}

#Preview {
    NavigationStack {
        PriceView()
    }
}
