//
//  DataManager.swift
//  ios_swiftUI_state
//
//  Created by MobileDev on 14/9/26.
//

import Foundation

// Service quản lý việc lưu trữ và tải dữ liệu từ UserDefaults
class DataManager {
    static let shared = DataManager()
    
    private let todosKey = "savedTodos"
    private let categoriesKey = "savedCategories"
    private let preferencesKey = "userPreferences"
    
    private init() {}
    
    // Lưu danh sách todos vào UserDefaults
    func saveTodos(_ todos: [TodoItem]) {
        if let encoded = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encoded, forKey: todosKey)
            print("Đã lưu \(todos.count) todos vào UserDefaults") // Log số lượng todos đã lưu
        }
    }
    
    // Tải danh sách todos từ UserDefaults
    func loadTodos() -> [TodoItem] {
        guard let data = UserDefaults.standard.data(forKey: todosKey),
              let todos = try? JSONDecoder().decode([TodoItem].self, from: data) else {
            print("Không tìm thấy todos đã lưu, trả về mảng rỗng") // Log khi không có data
            return []
        }
        print("Đã tải \(todos.count) todos từ UserDefaults") // Log số lượng todos đã tải
        return todos
    }
    
    // Lưu danh sách categories vào UserDefaults
    func saveCategories(_ categories: [Category]) {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: categoriesKey)
            print("Đã lưu \(categories.count) categories vào UserDefaults") // Log số lượng categories đã lưu
        }
    }
    
    // Tải danh sách categories từ UserDefaults
    func loadCategories() -> [Category] {
        guard let data = UserDefaults.standard.data(forKey: categoriesKey),
              let categories = try? JSONDecoder().decode([Category].self, from: data) else {
            print("Không tìm thấy categories đã lưu, trả về categories mẫu") // Log khi không có data
            return Category.sampleCategories
        }
        print("Đã tải \(categories.count) categories từ UserDefaults") // Log số lượng categories đã tải
        return categories
    }
    
    // Lưu user preferences vào UserDefaults
    func savePreferences(_ preferences: UserPreferences) {
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: preferencesKey)
            print("Đã lưu user preferences vào UserDefaults") // Log khi lưu preferences
        }
    }
    
    // Tải user preferences từ UserDefaults
    func loadPreferences() -> UserPreferences {
        guard let data = UserDefaults.standard.data(forKey: preferencesKey),
              let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) else {
            print("Không tìm thấy preferences đã lưu, trả về preferences mặc định") // Log khi không có data
            return UserPreferences()
        }
        print("Đã tải user preferences từ UserDefaults") // Log khi tải preferences
        return preferences
    }
    
    // Kiểm tra xem có phải lần đầu khởi chạy app không
    func isFirstLaunch() -> Bool {
        let hasLaunchedKey = "hasLaunchedBefore"
        let hasLaunched = UserDefaults.standard.bool(forKey: hasLaunchedKey)
        
        if !hasLaunched {
            UserDefaults.standard.set(true, forKey: hasLaunchedKey)
            print("Lần đầu khởi chạy app") // Log lần đầu khởi chạy
            return true
        }
        return false
    }
    
    // Xóa tất cả dữ liệu đã lưu
    func clearAllData() {
        UserDefaults.standard.removeObject(forKey: todosKey)
        UserDefaults.standard.removeObject(forKey: categoriesKey)
        UserDefaults.standard.removeObject(forKey: preferencesKey)
        print("Đã xóa toàn bộ dữ liệu khỏi UserDefaults") // Log khi xóa data
    }
}
