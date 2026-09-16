//
//  UserPreferences.swift
//  ios_swiftUI_state
//
//  Created by MobileDev on 14/9/26.
//

import Foundation

// Enum định nghĩa theme của ứng dụng
enum Theme: String, Codable, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
    
    var id: String { self.rawValue }
}

// Enum định nghĩa cách sắp xếp danh sách todo
enum SortOrder: String, Codable, CaseIterable, Identifiable {
    case date = "Date"
    case priority = "Priority"
    case alphabetical = "Alphabetical"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .date:
            return "calendar"
        case .priority:
            return "exclamationmark.triangle"
        case .alphabetical:
            return "textformat.abc"
        }
    }

    var displayName: String {
        switch self {
        case .date:
            return "Ngày tạo"
        case .priority:
            return "Độ ưu tiên"
        case .alphabetical:
            return "Tên A-Z"
        }
    }
}

// Model lưu trữ các thiết lập của người dùng
struct UserPreferences: Codable {
    var theme: Theme
    var sortOrder: SortOrder
    var showCompletedTasks: Bool
    var notificationsEnabled: Bool
    
    init(
        theme: Theme = .system,
        sortOrder: SortOrder = .date,
        showCompletedTasks: Bool = true,
        notificationsEnabled: Bool = false
    ) {
        self.theme = theme
        self.sortOrder = sortOrder
        self.showCompletedTasks = showCompletedTasks
        self.notificationsEnabled = notificationsEnabled
    }
}
