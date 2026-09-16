//
//  CategoryViewModel.swift
//  ios_swiftUI_state
//
//  Created by MobileDev on 14/9/26.
//

import Foundation
import Combine

// SCREEN-LEVEL STATE: ViewModel quản lý logic cho màn hình categories
class CategoryViewModel: ObservableObject {
    // PUBLISHED PROPERTIES: State có thể quan sát được từ View
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category?
    @Published var isLoading: Bool = false
    
    // Reference đến global state
    private var appState: AppState?
    private var cancellables = Set<AnyCancellable>()
    
    // Setup với AppState
    func setup(appState: AppState) {
        self.appState = appState
        
        // Lắng nghe thay đổi từ appState.categories
        appState.$categories
            .sink { [weak self] categories in
                self?.categories = categories
            }
            .store(in: &cancellables)
        
        // Load categories ban đầu
        self.categories = appState.categories
        
        print("CategoryViewModel đã setup và lắng nghe AppState") // Log setup
    }
    
    // MARK: - Category Operations
    
    // Thêm category mới
    func addCategory(name: String, color: String, icon: String) {
        guard let appState = appState else { return }
        
        let newCategory = Category(name: name, color: color, icon: icon)
        appState.addCategory(newCategory)
        print("Đã thêm category: \(name)") // Log add category
    }
    
    // Xóa category
    func deleteCategory(id: UUID) {
        appState?.deleteCategory(id: id)
    }
    
    // Chọn category
    func selectCategory(_ category: Category?) {
        selectedCategory = category
        if let category = category {
            print("Đã chọn category: \(category.name)") // Log selection
        } else {
            print("Đã bỏ chọn category") // Log deselection
        }
    }
    
    // Lấy số lượng todos cho mỗi category
    func getTodoCount(for categoryId: UUID) -> Int {
        guard let appState = appState else { return 0 }
        return appState.allTodos.filter { $0.categoryId == categoryId }.count
    }
    
    // Lấy số lượng todos active cho category
    func getActiveTodoCount(for categoryId: UUID) -> Int {
        guard let appState = appState else { return 0 }
        return appState.allTodos.filter { $0.categoryId == categoryId && !$0.isCompleted }.count
    }
}
