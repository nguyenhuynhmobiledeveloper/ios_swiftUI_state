//
//  AddEditTodoView.swift
//  ios_swiftUI_state
//
//  Created by MobileDev on 14/9/26.
//

import SwiftUI

// VIEW: Màn hình thêm hoặc chỉnh sửa todo
struct AddEditTodoView: View {
    // Mode định nghĩa màn hình đang ở chế độ thêm hay sửa
    enum Mode {
        case add
        case edit(TodoItem)
    }
    
    // ENVIRONMENT: Truy cập dismiss để đóng sheet
    @Environment(\.dismiss) var dismiss
    
    // GLOBAL STATE: Truy cập AppState để thêm/cập nhật todo
    @EnvironmentObject var appState: AppState
    
    // LOCAL STATE: Các trường input form được quản lý bởi @State
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedPriority: Priority = .medium
    @State private var selectedCategory: Category?
    @State private var dueDate: Date = Date().addingTimeInterval(3600)
    @State private var hasDueDate: Bool = false
    @State private var showDatePicker: Bool = false
    @State private var tagInput: String = ""
    @State private var tags: [String] = []
    @State private var showValidationError: Bool = false
    
    let mode: Mode
    
    private var existingTodo: TodoItem? {
        if case .edit(let todo) = mode {
            return todo
        }
        return nil
    }
    
    private var isEditing: Bool {
        if case .edit = mode {
            return true
        }
        return false
    }
    
    init(mode: Mode = .add) {
        self.mode = mode
    }
    
    // Khởi tạo với todo cũ (backward compatibility)
    init(existingTodo: TodoItem) {
        self.mode = .edit(existingTodo)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Title section
                Section("Title") {
                    TextField("Enter todo title", text: $title)
                        .textInputAutocapitalization(.sentences)
                }
                
                // Description section
                Section("Description") {
                    TextEditor(text: $description)
                        .frame(minHeight: 80)
                }
                
                // Priority section
                Section("Priority") {
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(Priority.allCases) { priority in
                            HStack {
                                Image(systemName: priority.icon)
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Category section
                Section("Category") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(appState.categories) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: selectedCategory?.id == category.id,
                                    action: {
                                        selectCategory(category)
                                    }
                                )
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // Due date section
                Section("Due Date") {
                    Toggle("Set due date", isOn: $hasDueDate.animation())
                    
                    if hasDueDate {
                        DatePicker(
                            "Date & Time",
                            selection: $dueDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                
                // Tags section
                Section("Tags") {
                    HStack {
                        TextField("Add tag", text: $tagInput)
                            .textInputAutocapitalization(.never)
                            .onSubmit {
                                addTag()
                            }
                        
                        Button(action: addTag) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .disabled(tagInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    
                    if !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    TagChip(tag: tag) {
                                        removeTag(tag)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Todo" : "New Todo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                        print("Đã hủy \(isEditing ? "chỉnh sửa" : "thêm") todo") // Log cancel
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTodo()
                    }
                    .disabled(!isValidInput)
                }
            }
            .alert("Title Required", isPresented: $showValidationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter a title for the todo")
            }
            .onAppear {
                loadExistingTodo()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isValidInput: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - Methods
    
    private func loadExistingTodo() {
        guard let todo = existingTodo else { return }
        
        title = todo.title
        description = todo.description
        selectedPriority = todo.priority
        selectedCategory = appState.getCategory(id: todo.categoryId)
        tags = todo.tags
        
        if let dueDate = todo.dueDate {
            self.dueDate = dueDate
            self.hasDueDate = true
        }
        
        print("Đã load todo để chỉnh sửa: \(todo.title)") // Log load
    }
    
    private func selectCategory(_ category: Category) {
        if selectedCategory?.id == category.id {
            selectedCategory = nil
            print("Đã bỏ chọn category") // Log deselect
        } else {
            selectedCategory = category
            print("Đã chọn category: \(category.name)") // Log select
        }
    }
    
    private func addTag() {
        let trimmedTag = tagInput.trimmingCharacters(in: .whitespaces).lowercased()
        guard !trimmedTag.isEmpty, !tags.contains(trimmedTag) else { return }
        
        tags.append(trimmedTag)
        tagInput = ""
        print("Đã thêm tag: \(trimmedTag)") // Log add tag
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
        print("Đã xóa tag: \(tag)") // Log remove tag
    }
    
    private func saveTodo() {
        guard isValidInput else {
            showValidationError = true
            return
        }
        
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let trimmedDescription = description.trimmingCharacters(in: .whitespaces)
        
        if let existingTodo = existingTodo {
            // Update existing todo
            var updatedTodo = existingTodo
            updatedTodo.title = trimmedTitle
            updatedTodo.description = trimmedDescription
            updatedTodo.priority = selectedPriority
            updatedTodo.categoryId = selectedCategory?.id
            updatedTodo.dueDate = hasDueDate ? dueDate : nil
            updatedTodo.tags = tags
            
            appState.updateTodo(updatedTodo)
            print("Đã cập nhật todo: \(trimmedTitle)") // Log update
        } else {
            // Create new todo
            let newTodo = TodoItem(
                title: trimmedTitle,
                description: trimmedDescription,
                priority: selectedPriority,
                categoryId: selectedCategory?.id,
                dueDate: hasDueDate ? dueDate : nil,
                tags: tags
            )
            
            appState.addTodo(newTodo)
            print("Đã thêm todo mới: \(trimmedTitle)") // Log add
        }
        
        dismiss()
    }
}

// MARK: - Helper Components

// Button để chọn category
struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.title2)
                Text(category.name)
                    .font(.caption)
            }
            .frame(width: 80, height: 80)
            .foregroundColor(isSelected ? .white : category.displayColor)
            .background(isSelected ? category.displayColor : category.displayColor.opacity(0.15))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(category.displayColor, lineWidth: isSelected ? 2 : 0)
            )
        }
        .buttonStyle(.plain)
    }
}

// Chip hiển thị tag với nút xóa
struct TagChip: View {
    let tag: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text("#\(tag)")
                .font(.caption)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.15))
        .foregroundColor(.blue)
        .cornerRadius(12)
    }
}

#Preview {
    AddEditTodoView(mode: .add)
        .environmentObject(AppState())
}
