# NutrLife iOS App 技术方案

## 1. 模块划分
- **Pricing (买菜价格记录)**：录入单价/总价推算重量，商品对比，支出统计与趋势图，数据持久化与同步。
- **Intake (饮食/购菜记录)**：文本/语音录入今日吃了什么或买了什么；规则解析重量、食材；与买菜记录关联。
- **Nutrition (营养计算)**：基于权威营养成分表，按食物重量计算能量、三大营养素、关键维生素/矿物质；支持场景化目标（普通/减脂/健身/经期/补气血等）。
- **Analytics (统计 & 红绿灯)**：日/周/月支出与营养趋势、红绿灯提示、建议生成（文案可由 LLM 产出）。
- **User (账号与订阅)**：Apple 登录/手机号登录，用户档案，订阅权益（LLM 调用额度），云端同步策略。
- **Settings (配置)**：偏好设置、数据导入导出、隐私与权限管理。
- **AIIntegration (NutritionAIService)**：统一的大模型抽象，路由 DeepSeek / OpenAI GPT-5.1 等，实现 LLM 兜底解析与文案生成。
- **Data (Repository 层)**：Core Data/SQLite 封装，CSV 导入食物成分表，统一 CRUD、同步钩子。

## 2. 数据模型（Swift Struct / Core Data 实体）
> 采用 Core Data 实体，配合 Repository 提供 Swift struct 映射。

- **User**
  - id: UUID
  - appleID / phoneNumber: String?
  - nickname: String?
  - subscriptionTier: Enum { free, premium }
  - dailyLLMLimit: Int (free 用户配额)
  - createdAt, updatedAt: Date

- **Food** (来自《中国食物成分表》的标准化食材)
  - id: UUID
  - name: String (中文名)
  - category: String (蔬菜/肉类等)
  - sourceRef: String (数据源版本)

- **FoodNutrient**
  - id: UUID
  - foodID (relation to Food)
  - nutrientCode: String (如 ENERGY_KCAL, PROTEIN_G, VIT_C_MG)
  - amountPer100g: Double
  - unit: String

- **PurchaseRecord**（买菜记录）
  - id: UUID
  - userID: UUID
  - foodID: UUID? (匹配到标准食材；未匹配可存文本字段 `foodNameRaw`)
  - unitPrice: Double (元/斤)
  - totalAmount: Double (元)
  - weightKg: Double (自动推算，斤换算 0.5kg)
  - store: String?
  - purchasedAt: Date
  - note: String?

- **IntakeRecord**（吃的/购入记录，吃的优先用于营养计算）
  - id: UUID
  - userID: UUID
  - foodID: UUID?
  - foodNameRaw: String
  - sourceType: Enum { purchase, meal, voice }
  - quantity: Double (重量 kg)
  - price: Double? (从购菜记录带入可选)
  - mealType: Enum { breakfast, lunch, dinner, snack }
  - recordedAt: Date
  - parsedMethod: Enum { rule, llm }
  - note: String?

- **NutritionTarget**（按场景的目标摄入）
  - id: UUID
  - scenario: Enum { normal, fatLoss, fitness, menstruation, qiBlood }
  - energyKcal, proteinG, fatG, carbG: Double
  - micronutrients: [String: Double]

- **NutritionSummary**（日/周计算结果缓存）
  - id: UUID
  - userID: UUID
  - period: Enum { day, week }
  - startDate: Date
  - endDate: Date
  - totalEnergyKcal, proteinG, fatG, carbG: Double
  - micronutrients: [String: Double]
  - greenLight: [String] (充足项)
  - redLight: [String] (缺口项)
  - suggestions: [String] (可由 LLM 生成)
  - generatedAt: Date

## 3. 规则解析 vs LLM 解析
- **规则优先覆盖**：
  - 固定句式：“X 元一斤，买了 Y 元”→ weight = Y / X (斤)；单位换算斤→kg。
  - “买了 N 斤/公斤/克的某食材”→ 解析重量，建立 PurchaseRecord & IntakeRecord。
  - “今天吃了/做了 某菜，用了 M 克某食材”→ 直接解析重量。
  - 对比功能：两条价格记录直接算单价、给出便宜提示。
  - 简单日期识别：“今天/昨天/周一”等映射日期。
- **LLM 兜底触发**：
  - 无法匹配规则或含多种食材且缺少重量的长文本/口语。
  - 需生成个性化文案建议、红绿灯解释。
  - 语音转文本后的自由描述（先尝试规则，失败再调 LLM）。
  - 模糊食材命名需要归一化到 Food（规则词表失败后）。

## 4. NutritionAIService 抽象接口
```swift
protocol NutritionAIService {
    /// 解析复杂饮食/购菜文本，返回结构化 IntakeRecord 候选
    func parseIntake(userId: UUID, text: String, contextDate: Date) async throws -> [ParsedIntake]

    /// 日/周营养分析（含红绿灯与建议文案）
    func analyzeNutrition(userId: UUID, period: AnalysisPeriod, records: [IntakeRecord], target: NutritionTarget) async throws -> NutritionAIResult
}

enum AnalysisPeriod: String, Codable { case day, week }

struct ParsedIntake: Codable {
    let foodName: String
    let weightKg: Double?
    let mealType: String?
    let price: Double?
    let note: String?
}

struct NutritionAIResult: Codable {
    let redLight: [String]
    let greenLight: [String]
    let suggestions: [String] // 简短可读提示
    let nutrients: [String: Double] // key: nutrientCode, value: total amount
}
```

### 输入输出 JSON 约定
- **parseIntake** 输入：`{ "userId": "uuid", "text": "...", "contextDate": "ISO8601" }`
  - 输出：`[{ "foodName": "鸡胸肉", "weightKg": 0.3, "mealType": "dinner", "price": 15.2, "note": "" }]`
- **analyzeNutrition** 输入：
```json
{
  "userId": "uuid",
  "period": "day",
  "target": {"scenario": "fitness", "energyKcal": 2400, "proteinG": 140, "fatG": 70, "carbG": 260},
  "records": [
    {"foodNameRaw": "鸡胸肉", "weightKg": 0.2, "mealType": "lunch"},
    {"foodNameRaw": "西兰花", "weightKg": 0.15, "mealType": "lunch"}
  ]
}
```
  - 输出：
```json
{
  "redLight": ["维生素C偏低"],
  "greenLight": ["蛋白质充足"],
  "suggestions": ["晚餐增加一份深色蔬菜，补维生素C"],
  "nutrients": {"ENERGY_KCAL": 1850, "PROTEIN_G": 120, "FAT_G": 60, "CARB_G": 180}
}
```
