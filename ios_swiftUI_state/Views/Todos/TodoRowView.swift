//
//  TodoRowView.swift
//  ios_swiftUI_state
//
//  Created by MobileDev on 14/9/26.
//

import SwiftUI

// COMPONENT: Row hiển thị một todo item trong list
struct TodoRowView: View {
    // GLOBAL STATE: Truy cập AppState để lấy category info và toggle completion
    @EnvironmentObject var appState: AppState
    
    // LOCAL STATE: Quản lý trạng thái expand/collapse của row
    @State private var isExpanded: Bool = false
    
    let todo: TodoItem
    var isSelected: Bool = false
    var isEditMode: Bool = false
    var onToggle: (() -> Void)?
    var onDelete: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main content
            HStack(alignment: .top, spacing: 12) {
                // Selection indicator in edit mode
                if isEditMode {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .blue : .gray)
                } else {
                    // Checkbox
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            onToggle?()
                            print("Toggle completion cho todo: \(todo.title)") // Log toggle
                        }
                    }) {
                        Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 20))
                            .foregroundColor(todo.isCompleted ? .green : .gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    // Title
                    Text(todo.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .strikethrough(todo.isCompleted)
                        .foregroundColor(todo.isCompleted ? .secondary : .primary)
                    
                    // Badges row
                    HStack(spacing: 8) {
                        PriorityBadge(priority: todo.priority, showIcon: false)
                        
                        if let categoryId = todo.categoryId,
                           let category = appState.getCategory(id: categoryId) {
                            CategoryBadge(category: category, showIcon: false)
                        }
                        
                        if let dueDate = todo.dueDate {
                            DueDateBadge(date: dueDate, isCompleted: todo.isCompleted)
                        }
                    }
                    
                    // Expanded details
                    if isExpanded && !todo.description.isEmpty {
                        Text(todo.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    // Tags
                    if isExpanded && !todo.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(todo.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.system(size: 11))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(6)
                                }
                            }
                        }
                        .padding(.top, 4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                
                Spacer()
                
                // Expand/collapse button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                        print("Toggle expand cho todo: \(todo.title) - isExpanded: \(isExpanded)") // Log expand
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(.systemBackground))
            .contentShape(Rectangle())
        }
    }
}

// Helper component for due date badge
struct DueDateBadge: View {
    let date: Date
    let isCompleted: Bool
    
    private var isOverdue: Bool {
        !isCompleted && date < Date()
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private var dateText: String {
        let formatter = DateFormatter()
        if isToday {
            formatter.timeStyle = .short
            return "Today \(formatter.string(from: date))"
        } else {
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "calendar")
                .font(.system(size: 11))
            Text(dateText)
                .font(.caption)
        }
        .foregroundColor(isOverdue ? .red : (isToday ? .orange : .blue))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background((isOverdue ? Color.red : (isToday ? Color.orange : Color.blue)).opacity(0.15))
        .cornerRadius(8)
    }
}

struct TodoRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ForEach(TodoItem.sampleTodos) { todo in
                TodoRowView(
                    todo: todo,
                    onToggle: { print("Toggle \(todo.title)") },
                    onDelete: { print("Delete \(todo.title)") }
                )
            }
        }
        .listStyle(PlainListStyle())
        .environmentObject(AppState())
    }
}
