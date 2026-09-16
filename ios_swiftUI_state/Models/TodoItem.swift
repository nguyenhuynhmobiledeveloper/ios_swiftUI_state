//
//  TodoItem.swift
//  ios_swiftUI_state
//
//  Created by MobileDev on 14/9/26.
//

import Foundation

// Model chính định nghĩa một công việc trong danh sách To-Do
struct TodoItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
    var priority: Priority
    var categoryId: UUID? // Reference đến Category
    var dueDate: Date?
    var createdAt: Date
    var tags: [String]
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        isCompleted: Bool = false,
        priority: Priority = .medium,
        categoryId: UUID? = nil,
        dueDate: Date? = nil,
        createdAt: Date = Date(),
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.priority = priority
        self.categoryId = categoryId
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.tags = tags
    }
    
    // Kiểm tra task có quá hạn không
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return !isCompleted && dueDate < Date()
    }
    
    // Kiểm tra task có deadline hôm nay không
    var isDueToday: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }
    
    // Sample data cho preview và testing
    static let sampleTodos: [TodoItem] = [
        TodoItem(
            title: "Complete SwiftUI Tutorial",
            description: "Finish the advanced state management chapter",
            priority: .high,
            dueDate: Date().addingTimeInterval(86400),
            tags: ["coding", "learning"]
        ),
        TodoItem(
            title: "Buy groceries",
            description: "Milk, eggs, bread, vegetables",
            isCompleted: false,
            priority: .medium,
            dueDate: Date().addingTimeInterval(3600),
            tags: ["shopping", "urgent"]
        ),
        TodoItem(
            title: "Morning workout",
            description: "30 minutes cardio and stretching",
            isCompleted: true,
            priority: .low,
            tags: ["health", "routine"]
        ),
        TodoItem(
            title: "Team meeting preparation",
            description: "Prepare slides and agenda for tomorrow's meeting",
            priority: .high,
            dueDate: Date().addingTimeInterval(43200),
            tags: ["work", "presentation"]
        )
    ]
}
