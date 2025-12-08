import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var dataStore: AppDataStore

    var body: some View {
        Form {
            Section(header: Text("地区设置")) {
                TextField("例如：华南-深圳", text: $dataStore.settings.region)
                    .textInputAutocapitalization(.never)
                Text("地区会影响后续推荐的食材和家常菜")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section(header: Text("身体/饮食场景")) {
                ForEach(UserScene.allCases) { scene in
                    Toggle(scene.rawValue, isOn: Binding(
                        get: { dataStore.settings.scenes.contains(scene) },
                        set: { isOn in
                            update(scene: scene, enabled: isOn)
                        }
                    ))
                }
            }

            Section(header: Text("语言设置")) {
                Picker("语言", selection: $dataStore.settings.language) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.rawValue).tag(lang)
                    }
                }
                .pickerStyle(.segmented)
                Text("当前仅切换枚举值，后续可接入 Localizable.strings 完成本地化。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section(header: Text("关于")) {
                Text("NutriLife 是“营养记账 & 买菜助手”，后续将基于《中国食物成分表》和中国膳食营养建议提供更智能的提示。")
                    .font(.body)
            }
        }
        .navigationTitle("我的")
    }

    private func update(scene: UserScene, enabled: Bool) {
        var scenes = dataStore.settings.scenes
        if enabled {
            if !scenes.contains(scene) { scenes.append(scene) }
        } else {
            scenes.removeAll { $0 == scene }
            if scenes.isEmpty { scenes = [.normal] }
        }
        dataStore.settings.scenes = scenes
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AppDataStore())
    }
}
