import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @ObservedObject private var preferences = UserPreferencesManager.shared

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Thống kê")) {
                    HStack {
                        Text("Tổng công việc")
                        Spacer()
                        Text("\(appState.statistics.total)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Đã hoàn thành")
                        Spacer()
                        Text("\(appState.statistics.completed)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Chưa hoàn thành")
                        Spacer()
                        Text("\(appState.statistics.pending)")
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("Hiển thị")) {
                    Picker("Giao diện", selection: $preferences.theme) {
                        ForEach(Theme.allCases) { item in
                            Text(themeName(item)).tag(item)
                        }
                    }

                    Picker("Sắp xếp mặc định", selection: $preferences.sortOrder) {
                        ForEach(SortOrder.allCases) { order in
                            HStack {
                                Image(systemName: order.icon)
                                Text(order.displayName)
                            }
                            .tag(order)
                        }
                    }

                    Toggle("Hiện công việc đã hoàn thành", isOn: $preferences.showCompleted)
                }

                Section(header: Text("Thông báo")) {
                    Toggle("Bật thông báo", isOn: $preferences.notificationsEnabled)
                }
            }
            .navigationBarTitle("Cài đặt")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func themeName(_ theme: Theme) -> String {
        switch theme {
        case .light: return "Sáng"
        case .dark: return "Tối"
        case .system: return "Theo hệ thống"
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppState())
    }
}
