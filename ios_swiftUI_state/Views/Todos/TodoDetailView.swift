//
//  TodoDetailView.swift
//  ios_swiftUI_state
//
//  Created by MobileDev on 14/9/26.
//

import SwiftUI

// VIEW: Màn hình hiển thị chi tiết một todo
struct TodoDetailView: View {
    // ENVIRONMENT: Truy cập dismiss để đóng view
    @Environment(\.dismiss) var dismiss
    
    // GLOBAL STATE: Truy cập AppState để update và delete todo
    @EnvironmentObject var appState: AppState
    
    // SCREEN-LEVEL STATE: ViewModel quản lý logic cho màn hình này
    @StateObject private var viewModel: TodoDetailViewModel
    
    // LOCAL STATE: Quản lý hiển thị các sheets và alerts
    @State private var showEditSheet: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    
    init(todo: TodoItem) {
        _viewModel = StateObject(wrappedValue: TodoDetailViewModel(todo: todo))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header section
                VStack(alignment: .leading, spacing: 12) {
                    // Title
                    Text(viewModel.todo.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .strikethrough(viewModel.todo.isCompleted)
                    
                    // Completion status
                    Button(action: {
                        withAnimation {
                            viewModel.toggleCompletion()
                        }
                    }) {
                        HStack {
                            Image(systemName: viewModel.todo.isCompleted ? "checkmark.circle.fill" : "circle")
                            Text(viewModel.todo.isCompleted ? "Completed" : "Mark as Complete")
                        }
                        .font(.headline)
                        .foregroundColor(viewModel.todo.isCompleted ? .green : .blue)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                // Description section
                if !viewModel.todo.description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Description", systemImage: "text.alignleft")
                            .font(.headline)
                        
                        Text(viewModel.todo.description)
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
                    Label("Details", systemImage: "info.circle")
                        .font(.headline)
                    
                    // Priority
                    HStack {
                        Text("Priority:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        PriorityBadge(priority: viewModel.todo.priority)
                    }
                    
                    Divider()
                    
                    // Category
                    HStack {
                        Text("Category:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        if let categoryId = viewModel.todo.categoryId,
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
                        if let dueDate = viewModel.todo.dueDate {
                            VStack(alignment: .trailing) {
                                Text(dueDate, style: .date)
                                Text(dueDate, style: .time)
                            }
                            .font(.subheadline)
                            .foregroundColor(viewModel.todo.isOverdue ? .red : .primary)
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
                        Text(viewModel.todo.createdAt, style: .date)
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                // Tags section
                if !viewModel.todo.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Tags", systemImage: "tag")
                            .font(.headline)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(viewModel.todo.tags, id: \.self) { tag in
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
                        print("Mở sheet chỉnh sửa todo: \(viewModel.todo.title)") // Log edit
                    }) {
                        Label("Edit Todo", systemImage: "pencil")
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
                        Label("Delete Todo", systemImage: "trash")
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
        .navigationTitle("Todo Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditSheet) {
            AddEditTodoView(existingTodo: viewModel.todo)
        }
        .alert("Delete Todo", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteTodo()
                dismiss()
                print("Đã xóa todo và đóng detail view") // Log delete
            }
        } message: {
            Text("Are you sure you want to delete this todo? This action cannot be undone.")
        }
        .onAppear {
            viewModel.setup(appState: appState)
        }
    }
}

// MARK: - Flow Layout Helper

// Custom layout để hiển thị tags theo dạng flow
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize
        var positions: [CGPoint]
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var positions: [CGPoint] = []
            var size: CGSize = .zero
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let subviewSize = subview.sizeThatFits(.unspecified)
                
                if currentX + subviewSize.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, subviewSize.height)
                currentX += subviewSize.width + spacing
                size.width = max(size.width, currentX - spacing)
            }
            
            size.height = currentY + lineHeight
            self.size = size
            self.positions = positions
        }
    }
}

#Preview {
    NavigationView {
        TodoDetailView(todo: TodoItem.sampleTodos[0])
            .environmentObject(AppState())
    }
}
