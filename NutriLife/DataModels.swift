import Foundation

/// 餐次类型，便于在 UI 中选择
enum MealTime: String, Codable, CaseIterable, Identifiable {
    case breakfast = "早餐"
    case lunch = "午餐"
    case dinner = "晚餐"
    case snack = "加餐"

    var id: String { rawValue }
}

/// 单个食物记录，用于本地饮食记录
struct MealEntry: Identifiable, Codable {
    let id: UUID
    var name: String
    var weightGram: Double
    var price: Double?
    var mealTime: MealTime
    var date: Date

    init(id: UUID = UUID(), name: String, weightGram: Double, price: Double?, mealTime: MealTime, date: Date = Date()) {
        self.id = id
        self.name = name
        self.weightGram = weightGram
        self.price = price
        self.mealTime = mealTime
        self.date = date
    }
}

/// 买菜记录，可供后续统计使用
struct PurchaseRecord: Identifiable, Codable {
    let id: UUID
    var ingredientName: String
    var unitPrice: Double
    var unit: PriceUnit
    var totalPrice: Double
    var date: Date

    init(id: UUID = UUID(), ingredientName: String, unitPrice: Double, unit: PriceUnit, totalPrice: Double, date: Date = Date()) {
        self.id = id
        self.ingredientName = ingredientName
        self.unitPrice = unitPrice
        self.unit = unit
        self.totalPrice = totalPrice
        self.date = date
    }
}

/// 买菜价格单位
enum PriceUnit: String, Codable, CaseIterable, Identifiable {
    case jin = "斤"
    case kilogram = "千克"

    var id: String { rawValue }

    /// 将当前单位的单价转换为每斤价格
    func pricePerJin(from unitPrice: Double) -> Double {
        switch self {
        case .jin:
            return unitPrice
        case .kilogram:
            return unitPrice / 2.0
        }
    }

    /// 根据单位计算重量文案
    func formattedWeight(amount: Double) -> String {
        switch self {
        case .jin:
            return String(format: "%.2f 斤", amount)
        case .kilogram:
            return String(format: "%.2f 千克", amount)
        }
    }
}

/// 大模型输入的食物记录
struct FoodRecord: Codable {
    let id: String       // 对应食物成分表编码
    let name: String     // 食物名称
    let amountGram: Double
    let price: Double?
}

/// 大模型分析输入
struct DailyMealInput: Codable {
    let date: Date
    let region: String
    let scenes: [String]
    let foodRecords: [FoodRecord]
}

/// 指标水平标签
enum NutrientLevel: String, Codable {
    case low = "偏低"
    case normal = "正常"
    case high = "偏高"
}

/// 营养汇总结果
struct NutritionAnalysisResult: Codable {
    struct MacroSummary: Codable {
        var energyKcal: Double
        var proteinGram: Double
        var fatGram: Double
        var carbGram: Double
        var fiberGram: Double
    }

    struct MicroSummary: Codable {
        var vitaminA: Double
        var vitaminC: Double
        var calcium: Double
        var iron: Double
        var potassium: Double
    }

    struct MetricStatus: Codable {
        var energy: NutrientLevel
        var protein: NutrientLevel
        var fat: NutrientLevel
        var carb: NutrientLevel
        var fiber: NutrientLevel
    }

    var macros: MacroSummary
    var micros: MicroSummary
    var status: MetricStatus
    var recommendedIngredients: [String]
    var recommendedRecipes: [String]
}

/// 用户设置
struct UserSettings: Codable {
    var region: String
    var scenes: [UserScene]
    var language: AppLanguage

    static var `default`: UserSettings {
        UserSettings(region: "华南-深圳", scenes: [.normal], language: .chinese)
    }
}

/// 场景类型
enum UserScene: String, Codable, CaseIterable, Identifiable {
    case normal = "普通成年人"
    case weightLoss = "减脂"
    case fitness = "健身"
    case period = "经期"
    case energyBoost = "补气血"

    var id: String { rawValue }
}

/// 语言设置（预留多语言）
enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case chinese = "中文"
    case english = "English"

    var id: String { rawValue }
}
