import SwiftUI

@main
struct NutriLifeApp: App {
    @StateObject private var dataStore = AppDataStore()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(dataStore)
        }
    }
}
