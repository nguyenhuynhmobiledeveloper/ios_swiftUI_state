//
//  TodoDetailViewModel.swift
//  ios_swiftUI_state
//
//  Created by MobileDev on 14/9/26.
//

import Foundation
import Combine

// SCREEN-LEVEL STATE: ViewModel quản lý logic cho màn hình chi tiết todo
class TodoDetailViewModel: ObservableObject {
    // PUBLISHED PROPERTIES: State có thể quan sát được từ View
    @Published var todo: TodoItem
    @Published var isEditing: Bool = false
    @Published var hasChanges: Bool = false
    
    // Reference đến global state
    private var appState: AppState?
    private let originalTodo: TodoItem
    
    init(todo: TodoItem) {
        self.todo = todo
        self.originalTodo = todo
    }
    
    // Setup với AppState
    func setup(appState: AppState) {
        self.appState = appState
        print("TodoDetailViewModel đã setup cho todo: \(todo.title)") // Log setup
    }
    
    // MARK: - Edit Operations
    
    // Bật chế độ chỉnh sửa
    func startEditing() {
        isEditing = true
        print("Bắt đầu chỉnh sửa todo: \(todo.title)") // Log start editing
    }
    
    // Hủy chỉnh sửa và khôi phục về trạng thái ban đầu
    func cancelEditing() {
        todo = originalTodo
        isEditing = false
        hasChanges = false
        print("Đã hủy chỉnh sửa và khôi phục todo") // Log cancel editing
    }
    
    // Lưu các thay đổi
    func saveTodo() {
        guard let appState = appState else { return }
        
        appState.updateTodo(todo)
        isEditing = false
        hasChanges = false
        print("Đã lưu thay đổi cho todo: \(todo.title)") // Log save
    }
    
    // Xóa todo
    func deleteTodo() {
        guard let appState = appState else { return }
        appState.deleteTodo(id: todo.id)
        print("Đã xóa todo: \(todo.title)") // Log delete
    }
    
    // Toggle completion status
    func toggleCompletion() {
        todo.isCompleted.toggle()
        hasChanges = true
        
        // Cập nhật ngay vào AppState
        appState?.toggleTodoCompletion(id: todo.id)
        
        let status = todo.isCompleted ? "hoàn thành" : "chưa hoàn thành"
        print("Đã đổi trạng thái todo thành: \(status)") // Log toggle
    }
    
    // MARK: - Field Updates
    
    // Cập nhật title
    func updateTitle(_ newTitle: String) {
        todo.title = newTitle
        hasChanges = true
    }
    
    // Cập nhật description
    func updateDescription(_ newDescription: String) {
        todo.description = newDescription
        hasChanges = true
    }
    
    // Cập nhật priority
    func updatePriority(_ newPriority: Priority) {
        todo.priority = newPriority
        hasChanges = true
        print("Đã thay đổi priority thành: \(newPriority.rawValue)") // Log priority change
    }
    
    // Cập nhật category
    func updateCategory(_ categoryId: UUID?) {
        todo.categoryId = categoryId
        hasChanges = true
        print("Đã thay đổi category") // Log category change
    }
    
    // Cập nhật due date
    func updateDueDate(_ newDate: Date?) {
        todo.dueDate = newDate
        hasChanges = true
        print("Đã thay đổi due date") // Log due date change
    }
    
    // Thêm tag
    func addTag(_ tag: String) {
        guard !tag.isEmpty, !todo.tags.contains(tag) else { return }
        todo.tags.append(tag)
        hasChanges = true
        print("Đã thêm tag: \(tag)") // Log add tag
    }
    
    // Xóa tag
    func removeTag(_ tag: String) {
        todo.tags.removeAll { $0 == tag }
        hasChanges = true
        print("Đã xóa tag: \(tag)") // Log remove tag
    }
}
