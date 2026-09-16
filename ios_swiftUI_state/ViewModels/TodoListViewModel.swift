//
//  TodoListViewModel.swift
//  ios_swiftUI_state
//
//  Created by MobileDev on 14/9/26.
//

import Foundation
import Combine

// SCREEN-LEVEL STATE: ViewModel quản lý logic và state cho TodoListView
class TodoListViewModel: ObservableObject {
    // PUBLISHED PROPERTIES: State có thể quan sát được từ View
    @Published var filteredTodos: [TodoItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedFilter: FilterType = .all
    @Published var searchText: String = "" {
        didSet {
            // Tự động filter khi search text thay đổi
            applyFilters()
        }
    }
    
    // Reference đến global state
    private var appState: AppState?
    private var cancellables = Set<AnyCancellable>()
    
    // Enum định nghĩa các loại filter
    enum FilterType: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case completed = "Completed"
        
        var icon: String {
            switch self {
            case .all:
                return "list.bullet"
            case .active:
                return "circle"
            case .completed:
                return "checkmark.circle.fill"
            }
        }
    }
    
    // Setup ViewModel với AppState
    func setup(appState: AppState) {
        self.appState = appState
        
        // Lắng nghe thay đổi từ appState.allTodos
        appState.$allTodos
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
        
        // Lắng nghe thay đổi sort order từ preferences
        appState.$userPreferences
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
        
        // Apply filters lần đầu
        applyFilters()
        
        print("TodoListViewModel đã setup và lắng nghe AppState") // Log setup
    }
    
    // Alias cho setup - dùng trong TodoListView
    func connectToAppState(_ appState: AppState) {
        setup(appState: appState)
    }
    
    // MARK: - Filtering Logic
    
    // Áp dụng các filter và sort
    func applyFilters() {
        guard let appState = appState else { return }
        
        var todos = appState.allTodos
        
        // Filter theo completion status
        switch selectedFilter {
        case .all:
            if !appState.userPreferences.showCompletedTasks {
                todos = todos.filter { !$0.isCompleted }
            }
        case .active:
            todos = todos.filter { !$0.isCompleted }
        case .completed:
            todos = todos.filter { $0.isCompleted }
        }
        
        // Filter theo search text
        if !searchText.isEmpty {
            todos = todos.filter { todo in
                todo.title.localizedCaseInsensitiveContains(searchText) ||
                todo.description.localizedCaseInsensitiveContains(searchText) ||
                todo.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
        
        // Sort theo user preferences
        filteredTodos = appState.sortedTodos(todos)
        
        print("Đã áp dụng filters - Hiển thị \(filteredTodos.count) todos") // Log filtering
    }
    
    // Filter theo category
    func filterByCategory(_ categoryId: UUID?) {
        guard let appState = appState else { return }
        
        if let categoryId = categoryId {
            filteredTodos = appState.todosByCategory(categoryId: categoryId)
            print("Đã lọc theo category ID: \(categoryId)") // Log category filter
        } else {
            applyFilters()
        }
    }
    
    // Filter theo priority
    func filterByPriority(_ priority: Priority) {
        guard let appState = appState else { return }
        filteredTodos = appState.todosByPriority(priority)
        print("Đã lọc theo priority: \(priority.rawValue)") // Log priority filter
    }
    
    // MARK: - Todo Operations
    
    // Thêm todo mới
    func addTodo(title: String, description: String, priority: Priority, categoryId: UUID?, dueDate: Date?, tags: [String]) {
        guard let appState = appState else { return }
        
        let newTodo = TodoItem(
            title: title,
            description: description,
            priority: priority,
            categoryId: categoryId,
            dueDate: dueDate,
            tags: tags
        )
        
        appState.addTodo(newTodo)
    }
    
    // Toggle completion status
    func toggleComplete(id: UUID) {
        appState?.toggleTodoCompletion(id: id)
    }
    
    // Xóa todo
    func deleteTodo(id: UUID) {
        appState?.deleteTodo(id: id)
    }
    
    // Xóa todos tại offsets
    func deleteTodos(at offsets: IndexSet) {
        for index in offsets {
            let todo = filteredTodos[index]
            appState?.deleteTodo(id: todo.id)
        }
    }
    
    // Cập nhật filter type
    func setFilter(_ filter: FilterType) {
        selectedFilter = filter
        applyFilters()
        print("Đã thay đổi filter sang: \(filter.rawValue)") // Log filter change
    }
    
    // Clear search
    func clearSearch() {
        searchText = ""
    }
}
