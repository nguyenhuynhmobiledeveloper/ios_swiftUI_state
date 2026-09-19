//
//  Category.swift
//  ios_swiftUI_state
//
//  Created by MobileDev on 14/9/26.
//

import SwiftUI

// Model định nghĩa danh mục/phân loại công việc
struct Category: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var color: String // Lưu tên màu dạng String để Codable
    var icon: String // SF Symbol name
    
    init(id: UUID = UUID(), name: String, color: String, icon: String) {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
    }
    
    // Chuyển đổi String color sang Color object
    var displayColor: Color {
        switch color {
        case "blue":
            return .blue
        case "red":
            return .red
        case "green":
            return .green
        case "orange":
            return .orange
        case "purple":
            return .purple
        case "pink":
            return .pink
        case "yellow":
            return .yellow
        case "teal":
            return Color(UIColor.systemTeal)
        case "indigo":
            return Color(UIColor.systemIndigo)
        case "cyan":
            return Color(red: 0.2, green: 0.68, blue: 0.9)
        default:
            return .gray
        }
    }
    
    // Danh sách category mẫu
    static let sampleCategories: [Category] = [
        Category(name: "Work", color: "blue", icon: "briefcase.fill"),
        Category(name: "Personal", color: "green", icon: "person.fill"),
        Category(name: "Shopping", color: "orange", icon: "cart.fill"),
        Category(name: "Health", color: "red", icon: "heart.fill"),
        Category(name: "Study", color: "purple", icon: "book.fill"),
        Category(name: "Home", color: "pink", icon: "house.fill")
    ]
}
