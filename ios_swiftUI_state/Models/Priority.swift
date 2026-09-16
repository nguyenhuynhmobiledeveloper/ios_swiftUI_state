//
//  Priority.swift
//  ios_swiftUI_state
//
//  Created by MobileDev on 14/9/26.
//

import SwiftUI

// Enum định nghĩa mức độ ưu tiên của task
enum Priority: String, Codable, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var id: String { self.rawValue }
    
    // Màu tương ứng với mỗi mức độ ưu tiên
    var color: Color {
        switch self {
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
    
    // Icon SF Symbol tương ứng
    var icon: String {
        switch self {
        case .low:
            return "arrow.down.circle.fill"
        case .medium:
            return "minus.circle.fill"
        case .high:
            return "arrow.up.circle.fill"
        }
    }
    
    // Giá trị số để sắp xếp
    var sortOrder: Int {
        switch self {
        case .high:
            return 0
        case .medium:
            return 1
        case .low:
            return 2
        }
    }
}
