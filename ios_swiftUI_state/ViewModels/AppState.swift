//
//  AppState.swift
//  ios_swiftUI_state
//
//  Created by MobileDev on 14/9/26.
//

import Foundation
import Combine

// GLOBAL STATE: Quản lý state toàn cục của ứng dụng
// Được inject vào root view và có thể truy cập từ bất kỳ view nào qua @EnvironmentObject
class AppState: ObservableObject {
    // PUBLISHED PROPERTIES: Tự động trigger UI update khi thay đổi
    @Published var allTodos: [TodoItem] = [] {
        didSet {
            // Tự động lưu khi todos thay đổi
            DataManager.shared.saveTodos(allTodos)
            // Cập nhật statistics khi todos thay đổi
            updateStatistics()
        }
    }
    
    @Published var categories: [Category] = [] {
        didSet {
            // Tự động lưu khi categories thay đổi
            DataManager.shared.saveCategories(categories)
        }
    }
    
    @Published var userPreferences: UserPreferences = UserPreferences() {
        didSet {
            // Tự động lưu khi preferences thay đổi
            DataManager.shared.savePreferences(userPreferences)
        }
    }
    
    @Published var statistics: Statistics = Statistics()
    
    init() {
        loadData()
    }
    
    // MARK: - Data Loading
    
    // Tải toàn bộ dữ liệu khi khởi động app
    private func loadData() {
        print("Bắt đầu tải dữ liệu từ DataManager") // Log quá trình tải
        
        // Tải categories trước
        self.categories = DataManager.shared.loadCategories()
        
        // Kiểm tra nếu lần đầu khởi chạy thì tạo sample data
        if DataManager.shared.isFirstLaunch() {
            self.allTodos = TodoItem.sampleTodos
            print("Đã tạo sample todos cho lần đầu khởi chạy") // Log tạo sample data
        } else {
            self.allTodos = DataManager.shared.loadTodos()
        }
        
        // Tải preferences
        self.userPreferences = DataManager.shared.loadPreferences()
        
        // Cập nhật statistics
        updateStatistics()
        
        print("Hoàn thành tải dữ liệu: \(allTodos.count) todos, \(categories.count) categories") // Log kết quả
    }
    
    // MARK: - Todo Operations
    
    // Thêm todo mới
    func addTodo(_ todo: TodoItem) {
        allTodos.append(todo)
        print("Đã thêm todo: \(todo.title)") // Log thêm todo
    }
    
    // Xóa todo theo ID
    func deleteTodo(id: UUID) {
        if let index = allTodos.firstIndex(where: { $0.id == id }) {
            let title = allTodos[index].title
            allTodos.remove(at: index)
            print("Đã xóa todo: \(title)") // Log xóa todo
        }
    }
    
    // Xóa todo theo object
    func deleteTodo(_ todo: TodoItem) {
        deleteTodo(id: todo.id)
    }
    
    // Xóa nhiều todos
    func deleteTodos(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            allTodos.remove(at: index)
        }
        print("Đã xóa \(offsets.count) todos") // Log xóa nhiều todos
    }
    
    // Cập nhật todo
    func updateTodo(_ todo: TodoItem) {
        if let index = allTodos.firstIndex(where: { $0.id == todo.id }) {
            allTodos[index] = todo
            print("Đã cập nhật todo: \(todo.title)") // Log cập nhật todo
        }
    }
    
    // Toggle trạng thái hoàn thành
    func toggleTodoCompletion(id: UUID) {
        if let index = allTodos.firstIndex(where: { $0.id == id }) {
            allTodos[index].isCompleted.toggle()
            let status = allTodos[index].isCompleted ? "hoàn thành" : "chưa hoàn thành"
            print("Đã đổi trạng thái todo '\(allTodos[index].title)' thành: \(status)") // Log toggle
        }
    }
    
    // MARK: - Category Operations
    
    // Thêm category mới
    func addCategory(_ category: Category) {
        categories.append(category)
        print("Đã thêm category: \(category.name)") // Log thêm category
    }
    
    // Xóa category
    func deleteCategory(id: UUID) {
        if let index = categories.firstIndex(where: { $0.id == id }) {
            let name = categories[index].name
            categories.remove(at: index)
            print("Đã xóa category: \(name)") // Log xóa category
            
            // Xóa categoryId khỏi các todos có category này
            for i in 0..<allTodos.count {
                if allTodos[i].categoryId == id {
                    allTodos[i].categoryId = nil
                }
            }
        }
    }
    
    // Lấy category theo ID
    func getCategory(id: UUID?) -> Category? {
        guard let id = id else { return nil }
        return categories.first(where: { $0.id == id })
    }
    
    // MARK: - Statistics
    
    // Cập nhật thống kê từ danh sách todos
    private func updateStatistics() {
        statistics = Statistics(from: allTodos)
        print("Cập nhật statistics - Total: \(statistics.totalTasks), Completed: \(statistics.completedTasks), Pending: \(statistics.pendingTasks)") // Log statistics
    }
    
    // MARK: - Filtering & Sorting
    
    // Lọc todos theo category
    func todosByCategory(categoryId: UUID?) -> [TodoItem] {
        guard let categoryId = categoryId else { return allTodos }
        return allTodos.filter { $0.categoryId == categoryId }
    }
    
    // Lọc todos theo priority
    func todosByPriority(_ priority: Priority) -> [TodoItem] {
        return allTodos.filter { $0.priority == priority }
    }
    
    // Lấy todos chưa hoàn thành
    func activeTodos() -> [TodoItem] {
        return allTodos.filter { !$0.isCompleted }
    }
    
    // Lấy todos đã hoàn thành
    func completedTodos() -> [TodoItem] {
        return allTodos.filter { $0.isCompleted }
    }
    
    // Sắp xếp todos theo sort order
    func sortedTodos(_ todos: [TodoItem]) -> [TodoItem] {
        switch userPreferences.sortOrder {
        case .date:
            return todos.sorted { $0.createdAt > $1.createdAt }
        case .priority:
            return todos.sorted { $0.priority.sortOrder < $1.priority.sortOrder }
        case .alphabetical:
            return todos.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }
    }
}
