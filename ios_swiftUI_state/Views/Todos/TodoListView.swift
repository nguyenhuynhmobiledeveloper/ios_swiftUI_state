//
//  TodoListView.swift
//  ios_swiftUI_state
//
//  Màn hình chính hiển thị danh sách todos - minh họa đầy đủ các cấp độ state
//

import SwiftUI

struct TodoListView: View {
    // GLOBAL STATE: Truy cập dữ liệu todos và categories toàn app
    @EnvironmentObject var appState: AppState
    
    // Preferences được giữ bởi singleton; dữ liệu todos lấy trực tiếp từ AppState.
    @ObservedObject private var preferences = UserPreferencesManager.shared
    
    // LOCAL STATE: Điều khiển hiển thị sheet thêm todo
    @State private var isAddingNewTodo: Bool = false
    
    // LOCAL STATE: Text đang nhập trong search bar
    @State private var searchText: String = ""
    
    // LOCAL STATE: Chế độ chỉnh sửa list (multi-select)
    @State private var isEditMode: Bool = false
    
    // LOCAL STATE: Filter hiện tại (All/Active/Completed)
    @State private var selectedFilter: TodoFilter = .all
    
    // LOCAL STATE: Hiển thị menu sort
    @State private var showSortMenu: Bool = false
    
    // LOCAL STATE: Todo đang được chọn để xem chi tiết
    @State private var selectedTodo: TodoItem?
    
    // LOCAL STATE: Các todos được chọn trong edit mode
    @State private var selectedTodoIds: Set<UUID> = []
    
    // LOCAL STATE: Hiển thị alert xác nhận xóa nhiều
    @State private var showBulkDeleteAlert: Bool = false
    @State private var showActionSheet: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                todoListContent
                
                // Floating action button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            // LOCAL STATE: Mở sheet thêm todo mới
                            isAddingNewTodo = true
                            print("Mở sheet thêm todo mới") // In ra hành động mở sheet
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitle("Công việc", displayMode: .large)
            .navigationBarItems(
                leading: editModeButton,
                trailing: settingsButton
            )
            .sheet(isPresented: $isAddingNewTodo) {
                AddEditTodoView(mode: .add)
                    .environmentObject(appState)
            }
            .alert(isPresented: $showBulkDeleteAlert) {
                Alert(
                    title: Text("Xóa \(selectedTodoIds.count) công việc"),
                    message: Text("Bạn có chắc muốn xóa \(selectedTodoIds.count) công việc đã chọn?"),
                    primaryButton: .cancel(Text("Hủy")) {
                        print("Hủy xóa nhiều todos")
                    },
                    secondaryButton: .destructive(Text("Xóa")) {
                        bulkDeleteTodos()
                    }
                )
            }
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(
                    title: Text("Tùy chọn"),
                    buttons: [
                        .default(Text("Sắp xếp theo ngày")) {
                            preferences.sortOrder = .date
                        },
                        .default(Text("Sắp xếp theo ưu tiên")) {
                            preferences.sortOrder = .priority
                        },
                        .default(Text("Sắp xếp theo tên A-Z")) {
                            preferences.sortOrder = .alphabetical
                        },
                        .default(Text(preferences.showCompleted ? "Ẩn đã hoàn thành" : "Hiện đã hoàn thành")) {
                            preferences.showCompleted.toggle()
                        },
                        .cancel(Text("Hủy"))
                    ]
                )
            }

        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $selectedTodo) { todo in
            NavigationView {
                TodoDetailView(todo: todo)
                    .environmentObject(appState)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    // MARK: - Computed Properties
    
    // Danh sách todos sau khi filter và sort
    private var filteredAndSortedTodos: [TodoItem] {
        var todos = appState.allTodos
        
        // Filter theo trạng thái completed
        if !preferences.showCompleted {
            todos = todos.filter { !$0.isCompleted }
            print("Đã lọc bỏ todos đã hoàn thành: \(todos.count) todos còn lại") // In ra kết quả filter
        }
        
        // Filter theo All/Active/Completed
        switch selectedFilter {
        case .all:
            break
        case .active:
            todos = todos.filter { !$0.isCompleted }
        case .completed:
            todos = todos.filter { $0.isCompleted }
        }
        
        // Search filter
        if !searchText.isEmpty {
            todos = todos.filter { todo in
                todo.title.localizedCaseInsensitiveContains(searchText) ||
                todo.description.localizedCaseInsensitiveContains(searchText) ||
                todo.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
            print("Tìm kiếm '\(searchText)': tìm thấy \(todos.count) kết quả") // In ra kết quả search
        }
        
        // Sort theo thứ tự đã chọn
        switch preferences.sortOrder {
        case .date:
            todos.sort { $0.createdAt > $1.createdAt }
        case .priority:
            todos.sort { $0.priority.rawValue > $1.priority.rawValue }
        case .alphabetical:
            todos.sort { $0.title < $1.title }
        }
        
        return todos
    }
    
    // MARK: - Subviews
    
    // View hiển thị khi không có todo nào
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Chưa có công việc nào")
                .font(.system(size: 22))
                .fontWeight(.semibold)
            
            if !searchText.isEmpty {
                Text("Không tìm thấy kết quả cho '\(searchText)'")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("Nhấn nút + để thêm công việc mới")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // Nội dung chính - danh sách todos
    private var todoListContent: some View {
        VStack(spacing: 0) {
            // Search bar
            SearchBar(text: $searchText, placeholder: "Tìm kiếm công việc...")
            
            // Filter buttons
            filterBar
            
            // Statistics card
            statisticsCard
            
            // List todos
            if filteredAndSortedTodos.isEmpty {
                emptyStateView
                Spacer()
            }
            List {
                ForEach(filteredAndSortedTodos) { todo in
                    TodoRowView(
                        todo: todo,
                        isSelected: selectedTodoIds.contains(todo.id),
                        isEditMode: isEditMode,
                        onToggle: { toggleComplete(todo) },
                        onDelete: { deleteTodo(todo) }
                    )
                    .contextMenu {
                        Button(action: { toggleComplete(todo) }) {
                            HStack {
                                Image(systemName: todo.isCompleted ? "arrow.uturn.backward" : "checkmark")
                                Text(todo.isCompleted ? "Đánh dấu chưa xong" : "Đánh dấu hoàn thành")
                            }
                        }
                        Button(action: { deleteTodo(todo) }) {
                            HStack { Image(systemName: "trash"); Text("Xóa") }
                        }
                    }
                    .onTapGesture {
                        if isEditMode {
                            // LOCAL STATE: Toggle selection trong edit mode
                            toggleSelection(for: todo.id)
                            print("Toggle chọn todo: \(todo.title)") // In ra todo được toggle
                        } else {
                            // LOCAL STATE: Mở detail view
                            selectedTodo = todo
                            print("Mở chi tiết todo: \(todo.title)") // In ra todo được xem
                        }
                    }
                }
                .onDelete { indexSet in
                    let todosToDelete = indexSet.map { filteredAndSortedTodos[$0] }
                    todosToDelete.forEach(deleteTodo)
                }
            }
            .listStyle(PlainListStyle())
        }
    }
    
    // Filter bar
    private var filterBar: some View {
        HStack(spacing: 12) {
            ForEach(TodoFilter.allCases, id: \.self) { filter in
                Button {
                    // LOCAL STATE: Thay đổi filter
                    withAnimation {
                        selectedFilter = filter
                    }
                    print("Chọn filter: \(filter.rawValue)") // In ra filter được chọn
                } label: {
                    Text(filter.displayName)
                        .font(.subheadline)
                        .fontWeight(selectedFilter == filter ? .semibold : .regular)
                        .foregroundColor(selectedFilter == filter ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            selectedFilter == filter ? Color.accentColor : Color.gray.opacity(0.2)
                        )
                        .cornerRadius(20)
                }
            }
            Spacer()
        }
        .padding()
    }
    
    // Statistics card
    private var statisticsCard: some View {
        HStack(spacing: 20) {
            StatCard(
                title: "Tổng",
                value: "\(appState.statistics.total)",
                icon: "list.bullet",
                color: .blue
            )
            
            StatCard(
                title: "Hoàn thành",
                value: "\(appState.statistics.completed)",
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            StatCard(
                title: "Chưa xong",
                value: "\(appState.statistics.pending)",
                icon: "clock.fill",
                color: .orange
            )
        }
        .padding()
    }
    
    // Toolbar content
    private var editModeButton: some View {
        Group {
            if isEditMode {
                Button("Hủy") {
                    isEditMode = false
                    selectedTodoIds.removeAll()
                    print("Thoát edit mode")
                }
            } else {
                Button("Chọn") {
                    isEditMode = true
                    print("Vào edit mode")
                }
            }
        }
    }
    
    private var settingsButton: some View {
        Button(action: {
            showActionSheet = true
        }) {
            Image(systemName: "ellipsis.circle")
        }
    }
    
    // MARK: - Actions
    
    // Toggle selection của todo trong edit mode
    private func toggleSelection(for id: UUID) {
        if selectedTodoIds.contains(id) {
            selectedTodoIds.remove(id)
            print("Bỏ chọn todo id: \(id)") // In ra id bỏ chọn
        } else {
            selectedTodoIds.insert(id)
            print("Chọn todo id: \(id)") // In ra id được chọn
        }
    }
    
    // Xóa một todo
    private func deleteTodo(_ todo: TodoItem) {
        withAnimation {
            // GLOBAL STATE: Xóa todo khỏi app state
            appState.deleteTodo(todo)
            print("Đã xóa todo: \(todo.title)") // In ra todo đã xóa
        }
    }
    
    // Toggle trạng thái hoàn thành của todo
    private func toggleComplete(_ todo: TodoItem) {
        withAnimation {
            // GLOBAL STATE: Cập nhật trạng thái trong app state
            var updatedTodo = todo
            updatedTodo.isCompleted.toggle()
            appState.updateTodo(updatedTodo)
            print("Toggle hoàn thành todo: \(todo.title), mới: \(updatedTodo.isCompleted)") // In ra trạng thái mới
        }
    }
    
    // Xóa nhiều todos đã chọn
    private func bulkDeleteTodos() {
        withAnimation {
            let todosToDelete = appState.allTodos.filter { selectedTodoIds.contains($0.id) }
            for todo in todosToDelete {
                appState.deleteTodo(todo)
            }
            print("Đã xóa \(todosToDelete.count) todos") // In ra số lượng đã xóa
            selectedTodoIds.removeAll()
            isEditMode = false
        }
    }
    
    // Đánh dấu hoàn thành nhiều todos
    private func bulkToggleComplete() {
        withAnimation {
            let todosToUpdate = appState.allTodos.filter { selectedTodoIds.contains($0.id) }
            for todo in todosToUpdate {
                var updatedTodo = todo
                updatedTodo.isCompleted = true
                appState.updateTodo(updatedTodo)
            }
            print("Đã đánh dấu hoàn thành \(todosToUpdate.count) todos") // In ra số lượng đã update
            selectedTodoIds.removeAll()
            isEditMode = false
        }
    }
}

// MARK: - Supporting Types

// Enum cho filter options
enum TodoFilter: String, CaseIterable {
    case all = "all"
    case active = "active"
    case completed = "completed"
    
    var displayName: String {
        switch self {
        case .all: return "Tất cả"
        case .active: return "Chưa xong"
        case .completed: return "Hoàn thành"
        }
    }
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
            .environmentObject(AppState())
    }
}
