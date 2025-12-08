import Foundation

/// 营养评估的单项水平标签
public enum NutrientLevel: String, Codable {
    case low = "偏低"
    case normal = "正常"
    case high = "偏高"
}

/// 常量营养素汇总
public struct MacronutrientSummary: Codable {
    public let energyKcal: Double
    public let proteinGram: Double
    public let fatGram: Double
    public let carbohydrateGram: Double
    public let fiberGram: Double
    public let energyLevel: NutrientLevel
    public let proteinLevel: NutrientLevel
    public let fatLevel: NutrientLevel
    public let carbohydrateLevel: NutrientLevel
    public let fiberLevel: NutrientLevel
}

/// 关键微量营养素摘要
public struct MicronutrientItem: Codable {
    public let name: String
    public let amount: Double
    public let unit: String
    public let level: NutrientLevel
}

/// 营养缺口推荐食材
public struct NutrientRecommendation: Codable {
    public let nutrient: String
    public let suggestedFoods: [String]
}

/// 模型输出的营养分析结果
public struct NutritionAnalysisResult: Codable {
    public let macronutrients: MacronutrientSummary
    public let micronutrients: [MicronutrientItem]
    public let dishSuggestions: [String]
    public let deficiencyRecommendations: [NutrientRecommendation]
}

/// AI 服务提供方
public enum AIProvider {
    case deepseek
    case openai
}

/// 统一的营养 AI 封装
public final class NutritionAIService {
    private let baseURL: URL
    private let apiKey: String
    private let modelName: String
    private let provider: AIProvider
    private let urlSession: URLSession

    public init(baseURL: URL, apiKey: String, modelName: String, provider: AIProvider, urlSession: URLSession = .shared) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.modelName = modelName
        self.provider = provider
        self.urlSession = urlSession
    }

    /// 调用大模型分析每日饮食
    public func analyzeDailyMeal(_ input: DailyMealInput) async throws -> NutritionAnalysisResult {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let inputData = try encoder.encode(input)
        guard let inputJSONString = String(data: inputData, encoding: .utf8) else {
            throw NSError(domain: "NutritionAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "输入编码失败"])
        }

        let systemPrompt = "你是一名中国注册营养师，请严格依据中国食物成分表和健康饮食指南，用中文输出结构化 JSON 结果。确保定量数据以克或千卡为单位，标签只用“偏低/正常/偏高”。"
        let userPrompt = "请根据以下用户每日饮食 JSON，生成 NutritionAnalysisResult JSON，不要输出多余说明。输入：\n\(inputJSONString)\n输出字段要求：\n1）macronutrients：包含能量千卡、蛋白质克、脂肪克、碳水化合物克、膳食纤维克以及对应的水平标签；\n2）micronutrients：列出关键维生素和矿物质（例如维生素A、维生素C、钙、铁、锌、镁、钾等），每项包含名称、摄入量、单位、水平标签；\n3）deficiencyRecommendations：当某营养素偏低时，给出中国常见食材名称数组；\n4）dishSuggestions：给出几道符合场景的家常菜菜名；\n5）仅返回 JSON，符合 Codable 结构。"

        let messages = [
            ChatMessage(role: "system", content: systemPrompt),
            ChatMessage(role: "user", content: userPrompt)
        ]

        let bodyData = try buildRequestBody(messages: messages)
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization") // TODO: 替换为真实的 API Key
        request.httpBody = bodyData

        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw NSError(domain: "NutritionAIService", code: -2, userInfo: [NSLocalizedDescriptionKey: "网络请求失败"])
        }

        let content = try extractContent(from: data)
        guard let contentData = content.data(using: .utf8) else {
            throw NSError(domain: "NutritionAIService", code: -3, userInfo: [NSLocalizedDescriptionKey: "模型输出编码失败"])
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(NutritionAnalysisResult.self, from: contentData)
    }

    /// 构造不同提供方的请求体
    private func buildRequestBody(messages: [ChatMessage]) throws -> Data {
        let encoder = JSONEncoder()
        switch provider {
        case .deepseek:
            let payload = ChatCompletionsRequest(model: modelName, messages: messages, temperature: 0.2)
            return try encoder.encode(payload)
        case .openai:
            let payload = ChatCompletionsRequest(model: modelName, messages: messages, temperature: 0.2)
            return try encoder.encode(payload)
        }
    }

    /// 从模型响应中提取文本内容
    private func extractContent(from data: Data) throws -> String {
        let decoder = JSONDecoder()
        let response = try decoder.decode(ChatCompletionsResponse.self, from: data)
        guard let content = response.choices.first?.message.content else {
            throw NSError(domain: "NutritionAIService", code: -4, userInfo: [NSLocalizedDescriptionKey: "响应内容为空"])
        }
        return content
    }
}

/// 通用聊天消息
private struct ChatMessage: Codable {
    let role: String
    let content: String
}

/// chat/completions 请求体
private struct ChatCompletionsRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let temperature: Double
}

/// chat/completions 响应体
private struct ChatCompletionsResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let role: String
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

// MARK: - 调用示例

func exampleCall() {
    let foodRecords = [
        FoodRecord(id: "F123", name: "鸡胸肉", amountGram: 200, price: 12.5),
        FoodRecord(id: "V456", name: "西兰花", amountGram: 150, price: 4.2),
        FoodRecord(id: "C789", name: "燕麦片", amountGram: 60, price: nil)
    ]

    let input = DailyMealInput(
        date: Date(),
        region: "CN-Guangdong-Shenzhen",
        scenes: ["weight_loss"],
        foodRecords: foodRecords
    )

    let service = NutritionAIService(
        baseURL: URL(string: "https://api.deepseek.com/v1/chat/completions")!,
        apiKey: "YOUR_API_KEY", // TODO: 替换为真实的 API Key
        modelName: "deepseek-chat",
        provider: .deepseek
    )

    Task {
        do {
            let result = try await service.analyzeDailyMeal(input)
            print("营养分析结果：\(result)")
        } catch {
            print("调用失败：\(error)")
        }
    }
}
