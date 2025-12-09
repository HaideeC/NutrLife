import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                TodayView()
            }
            .tabItem {
                Label("今日", systemImage: "sun.max.fill")
            }

            NavigationStack {
                PriceView()
            }
            .tabItem {
                Label("买菜", systemImage: "cart.fill")
            }

            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label("统计", systemImage: "chart.bar.fill")
            }

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("我的", systemImage: "person.crop.circle")
            }
        }
        .tint(.green)
    }
}

#Preview {
    RootTabView()
        .environmentObject(AppDataStore())
}
