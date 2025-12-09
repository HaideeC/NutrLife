import Foundation
import Combine
import SwiftUI

/// 轻量本地数据存储，使用 Codable + JSON 文件
@MainActor
final class AppDataStore: ObservableObject {
    @Published private(set) var meals: [MealEntry] = []
    @Published private(set) var purchases: [PurchaseRecord] = []
    @Published var settings: UserSettings = .default {
        didSet { save(settings, to: settingsURL) }
    }

    private let mealsURL: URL
    private let purchasesURL: URL
    private let settingsURL: URL
    private let queue = DispatchQueue(label: "com.nutrilife.datastore")

    init(fileManager: FileManager = .default) {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: "/")
        mealsURL = documents.appendingPathComponent("meal_records.json")
        purchasesURL = documents.appendingPathComponent("purchase_records.json")
        settingsURL = documents.appendingPathComponent("user_settings.json")
        loadAll()
    }

    /// 添加一条饮食记录
    func addMeal(_ entry: MealEntry) {
        meals.append(entry)
        save(meals, to: mealsURL)
    }

    /// 添加一条买菜记录
    func addPurchase(_ record: PurchaseRecord) {
        purchases.append(record)
        save(purchases, to: purchasesURL)
    }

    /// 今日的饮食记录
    func meals(for date: Date, calendar: Calendar = .current) -> [MealEntry] {
        meals.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    /// 载入本地数据
    private func loadAll() {
        meals = load(from: mealsURL) ?? sampleMeals()
        purchases = load(from: purchasesURL) ?? samplePurchases()
        settings = load(from: settingsURL) ?? .default
    }

    /// 通用保存
    private func save<T: Encodable>(_ value: T, to url: URL) {
        queue.async {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            do {
                let data = try encoder.encode(value)
                try data.write(to: url, options: .atomic)
            } catch {
                print("保存失败: \(error)")
            }
        }
    }

    /// 通用加载
    private func load<T: Decodable>(from url: URL) -> T? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            print("读取失败: \(error)")
            return nil
        }
    }

    /// 假数据：饮食
    private func sampleMeals() -> [MealEntry] {
        [
            MealEntry(name: "鸡胸肉", weightGram: 180, price: 12.5, mealTime: .lunch, date: Date()),
            MealEntry(name: "西兰花", weightGram: 150, price: 5.2, mealTime: .lunch, date: Date()),
            MealEntry(name: "燕麦牛奶", weightGram: 250, price: 6.0, mealTime: .breakfast, date: Date())
        ]
    }

    /// 假数据：买菜记录
    private func samplePurchases() -> [PurchaseRecord] {
        [
            PurchaseRecord(ingredientName: "菜心", unitPrice: 6.5, unit: .jin, totalPrice: 9.0, date: Date().addingTimeInterval(-86400)),
            PurchaseRecord(ingredientName: "鸡胸肉", unitPrice: 18.0, unit: .kilogram, totalPrice: 36.0, date: Date().addingTimeInterval(-2 * 86400))
        ]
    }
}
