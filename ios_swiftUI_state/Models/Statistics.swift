//
//  Statistics.swift
//  ios_swiftUI_state
//
//  Created by MobileDev on 14/9/26.
//

import Foundation

// Model lưu trữ các thống kê về todo
struct Statistics {
    var totalTasks: Int
    var completedTasks: Int
    var pendingTasks: Int
    var todayTasks: Int
    var overdueTasks: Int
    var highPriorityTasks: Int
    
    // Aliases để dùng trong TodoListView
    var total: Int { totalTasks }
    var completed: Int { completedTasks }
    var pending: Int { pendingTasks }
    
    // Tính phần trăm hoàn thành
    var completionPercentage: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks) * 100
    }
    
    // Khởi tạo statistics từ danh sách todos
    init(from todos: [TodoItem]) {
        self.totalTasks = todos.count
        self.completedTasks = todos.filter { $0.isCompleted }.count
        self.pendingTasks = todos.filter { !$0.isCompleted }.count
        self.todayTasks = todos.filter { $0.isDueToday }.count
        self.overdueTasks = todos.filter { $0.isOverdue }.count
        self.highPriorityTasks = todos.filter { $0.priority == .high && !$0.isCompleted }.count
    }
    
    // Khởi tạo rỗng
    init() {
        self.totalTasks = 0
        self.completedTasks = 0
        self.pendingTasks = 0
        self.todayTasks = 0
        self.overdueTasks = 0
        self.highPriorityTasks = 0
    }
}
