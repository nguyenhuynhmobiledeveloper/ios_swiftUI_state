//
//  TodoDetailView.swift
//  ios_swiftUI_state
//
//  Created by MobileDev on 14/9/26.
//

import SwiftUI

// VIEW: Màn hình hiển thị chi tiết một todo
struct TodoDetailView: View {
    // ENVIRONMENT: Truy cập presentationMode để đóng view (iOS 13 compatible)
    @Environment(\.presentationMode) var presentationMode
    
    // GLOBAL STATE: Truy cập AppState để update và delete todo
    @EnvironmentObject var appState: AppState
    
    // Đọc dữ liệu mới nhất từ AppState để chi tiết cập nhật sau khi chỉnh sửa.
    private let initialTodo: TodoItem

    private var todo: TodoItem {
        appState.allTodos.first(where: { $0.id == initialTodo.id }) ?? initialTodo
    }
    
    // LOCAL STATE: Quản lý hiển thị các sheets và alerts
    @State private var showEditSheet: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    
    init(todo: TodoItem) {
        self.initialTodo = todo
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header section
                VStack(alignment: .leading, spacing: 12) {
                    // Title
                    Text(todo.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .strikethrough(todo.isCompleted)
                    
                    // Completion status
                    Button(action: {
                        withAnimation {
                            appState.toggleTodoCompletion(id: todo.id)
                        }
                    }) {
                        HStack {
                            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                            Text(todo.isCompleted ? "Completed" : "Mark as Complete")
                        }
                        .font(.headline)
                        .foregroundColor(todo.isCompleted ? .green : .blue)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                // Description section
                if !todo.description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack { Image(systemName: "text.alignleft"); Text("Description") }
                            .font(.headline)
                        
                        Text(todo.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                
                // Details section
                VStack(alignment: .leading, spacing: 16) {
                    HStack { Image(systemName: "info.circle"); Text("Details") }
                        .font(.headline)
                    
                    // Priority
                    HStack {
                        Text("Priority:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        PriorityBadge(priority: todo.priority)
                    }
                    
                    Divider()
                    
                    // Category
                    HStack {
                        Text("Category:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        if let categoryId = todo.categoryId,
                           let category = appState.getCategory(id: categoryId) {
                            CategoryBadge(category: category)
                        } else {
                            Text("None")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // Due date
                    HStack {
                        Text("Due Date:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        if let dueDate = todo.dueDate {
                            VStack(alignment: .trailing) {
                                Text(Self.dateFormatter.string(from: dueDate))
                                Text(Self.timeFormatter.string(from: dueDate))
                            }
                            .font(.subheadline)
                            .foregroundColor(todo.isOverdue ? .red : .primary)
                        } else {
                            Text("Not set")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // Created date
                    HStack {
                        Text("Created:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(Self.dateFormatter.string(from: todo.createdAt))
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                // Tags section
                if !todo.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack { Image(systemName: "tag"); Text("Tags") }
                            .font(.headline)
                        
                        // Simple wrapping layout for iOS 13
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(todo.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.15))
                                    .foregroundColor(.blue)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: {
                        showEditSheet = true
                        print("Mở sheet chỉnh sửa todo: \(todo.title)") // Log edit
                    }) {
                        HStack { Image(systemName: "pencil"); Text("Edit Todo") }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        showDeleteConfirmation = true
                        print("Hiển thị xác nhận xóa todo") // Log delete confirmation
                    }) {
                        HStack { Image(systemName: "trash"); Text("Delete Todo") }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle("Todo Details", displayMode: .inline)
        .sheet(isPresented: $showEditSheet) {
            AddEditTodoView(existingTodo: todo)
                .environmentObject(appState)
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Todo"),
                message: Text("Are you sure you want to delete this todo? This action cannot be undone."),
                primaryButton: .cancel(),
                secondaryButton: .destructive(Text("Delete")) {
                    appState.deleteTodo(id: todo.id)
                    presentationMode.wrappedValue.dismiss()
                    print("Đã xóa todo và đóng detail view")
                }
            )
        }
    }
}

struct TodoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TodoDetailView(todo: TodoItem.sampleTodos[0])
                .environmentObject(AppState())
        }
    }
}
