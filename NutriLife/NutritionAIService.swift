import Foundation

/// AI 提供方（占位）
enum AIProvider {
    case deepseek
    case openai
}

/// 营养分析服务占位，当前返回假数据
final class NutritionAIService {
    private let baseURL: URL
    private let apiKey: String
    private let modelName: String
    private let provider: AIProvider

    init(baseURL: URL, apiKey: String, modelName: String, provider: AIProvider) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.modelName = modelName
        self.provider = provider
    }

    /// 分析每日饮食（占位实现）
    func analyzeDailyMeal(_ input: DailyMealInput) async throws -> NutritionAnalysisResult {
        // TODO: 未来接入 DeepSeek / OpenAI GPT-5.1 的 chat/completions 接口
        // 占位返回假数据，避免真实网络请求
        return NutritionAnalysisResult(
            macros: .init(energyKcal: 1850, proteinGram: 95, fatGram: 60, carbGram: 210, fiberGram: 22),
            micros: .init(vitaminA: 800, vitaminC: 95, calcium: 650, iron: 14, potassium: 2400),
            status: .init(energy: .normal, protein: .normal, fat: .normal, carb: .normal, fiber: .low),
            recommendedIngredients: ["菠菜", "西兰花", "豆腐"],
            recommendedRecipes: ["清炒菠菜", "西兰花炒牛肉", "豆腐番茄汤"]
        )
    }
}
