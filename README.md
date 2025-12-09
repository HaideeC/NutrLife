# NutriLife iOS (SwiftUI)

NutriLife 是一款面向中国独居年轻人和小家庭的「营养记账 + 买菜省钱 + 低门槛营养指南」原型 App。当前版本使用 SwiftUI 搭建，可在 Xcode 直接运行预览，支持本地轻量持久化和可扩展的大模型接口占位。

## 功能概览（MVP）
- **今日**：展示假数据的能量/蛋白质/蔬果进度，提供语音占位入口与手动添加饮食记录，记录支持本地保存并按日展示。
- **买菜**：两种商品价格对比小工具，支持斤/千克换算、重量与每斤单价计算，以及差价文案提示；预留本地买菜记录数据结构。
- **统计**：展示近 7 天支出示意柱状图与营养趋势占位说明（假数据）。
- **我的**：地区设置、场景多选（减脂/健身/经期/补气血等）、语言偏好开关与关于说明，设置会本地持久化。
- **AI 预留**：定义了膳食输入与营养分析结果的数据结构，以及可切换 DeepSeek/OpenAI 的 NutritionAIService 占位实现（当前返回假数据，不调用网络）。

## 运行环境
- Xcode 15+（推荐）
- iOS 17 及以上模拟器或真机
- Swift 5.9+

## 如何运行
1. 克隆仓库：
   ```bash
   git clone <repo-url>
   cd NutrLife
   ```
2. 用 Xcode 打开本目录（如果已有模板工程，请删除默认生成的同名 App 入口/ContentView 以避免重复定义）。
3. 选择 iOS 17+ 模拟器，直接运行或使用 Canvas 预览各 SwiftUI 视图。

## 代码结构
- `NutriLifeApp.swift`：App 入口，注入数据存储。
- `RootTabView.swift`：TabView + NavigationStack 框架。
- `TodayView.swift`：今日概览、录入入口、记录列表与手动添加子页。
- `PriceView.swift`：买菜价格对比卡片与提示。
- `StatsView.swift`：示意支出柱状图与营养趋势占位。
- `ProfileView.swift`：地区/场景/语言设置与关于说明。
- `DataModels.swift`：核心数据结构与枚举（餐次、记录、AI 输入输出等）。
- `DataStore.swift`：基于 Codable + JSON 文件的轻量持久化实现。
- `NutritionAIService.swift`：大模型分析占位实现，未来可接入 DeepSeek / GPT-5.1。

## 后续扩展建议
- 接入《中国食物成分表》CSV，计算真实营养摄入。
- 将买菜记录与饮食记录关联，支撑真实统计和趋势分析。
- 使用 Localizable.strings 实现中英双语切换。
- 替换 NutritionAIService 内的假数据为真实 API 请求，并增加错误处理和速率控制。

## 许可
当前项目仅用于演示与原型验证，后续可根据商业化需求确定最终许可协议。
