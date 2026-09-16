import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    @AppStorage("theme") private var theme: Theme = .system
    @AppStorage("sortOrder") private var sortOrder: SortOrder = .date
    @AppStorage("showCompleted") private var showCompleted = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Thống kê") {
                    LabeledContent("Tổng công việc", value: "\(appState.statistics.total)")
                    LabeledContent("Đã hoàn thành", value: "\(appState.statistics.completed)")
                    LabeledContent("Chưa hoàn thành", value: "\(appState.statistics.pending)")
                }

                Section("Hiển thị") {
                    Picker("Giao diện", selection: $theme) {
                        ForEach(Theme.allCases) { item in
                            Text(themeName(item)).tag(item)
                        }
                    }

                    Picker("Sắp xếp mặc định", selection: $sortOrder) {
                        ForEach(SortOrder.allCases) { order in
                            Label(order.displayName, systemImage: order.icon).tag(order)
                        }
                    }

                    Toggle("Hiện công việc đã hoàn thành", isOn: $showCompleted)
                }

                Section("Thông báo") {
                    Toggle("Bật thông báo", isOn: $notificationsEnabled)
                }
            }
            .navigationTitle("Cài đặt")
        }
    }

    private func themeName(_ theme: Theme) -> String {
        switch theme {
        case .light: return "Sáng"
        case .dark: return "Tối"
        case .system: return "Theo hệ thống"
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
