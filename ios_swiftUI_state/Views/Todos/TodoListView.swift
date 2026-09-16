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
    
    // SCREEN-LEVEL STATE: Quản lý logic và filtering cho màn hình này
    @StateObject private var viewModel = TodoListViewModel()
    
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
    
    // PERSISTENT STATE: Thứ tự sắp xếp được lưu trữ
    @AppStorage("sortOrder") var sortOrder: SortOrder = .date
    
    // PERSISTENT STATE: Hiển thị tasks đã hoàn thành
    @AppStorage("showCompleted") var showCompleted: Bool = true
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    loadingView
                } else if filteredAndSortedTodos.isEmpty {
                    emptyStateView
                } else {
                    todoListContent
                }
                
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
                                .font(.title2)
                                .fontWeight(.semibold)
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
            .navigationTitle("Công việc")
            .toolbar {
                toolbarContent
            }
            .searchable(text: $searchText, prompt: "Tìm kiếm công việc...")
            .sheet(isPresented: $isAddingNewTodo) {
                AddEditTodoView(mode: .add)
                    .environmentObject(appState)
            }
            .sheet(item: $selectedTodo) { todo in
                TodoDetailView(todo: todo)
                    .environmentObject(appState)
            }
            .alert("Xóa \(selectedTodoIds.count) công việc", isPresented: $showBulkDeleteAlert) {
                Button("Hủy", role: .cancel) {
                    print("Hủy xóa nhiều todos") // In ra hành động hủy
                }
                Button("Xóa", role: .destructive) {
                    bulkDeleteTodos()
                }
            } message: {
                Text("Bạn có chắc muốn xóa \(selectedTodoIds.count) công việc đã chọn?")
            }
            .onAppear {
                // Kết nối ViewModel với AppState khi view xuất hiện
                viewModel.connectToAppState(appState)
                print("TodoListView xuất hiện, kết nối với AppState") // In ra lifecycle event
            }
            .onChange(of: searchText) { oldValue, newValue in
                // Tìm kiếm theo text nhập vào
                print("Text tìm kiếm thay đổi: '\(newValue)'") // In ra text tìm kiếm
            }
            .onChange(of: selectedFilter) { oldValue, newValue in
                // Filter thay đổi
                print("Filter thay đổi: \(newValue.rawValue)") // In ra filter mới
            }
        }
    }
    
    // MARK: - Computed Properties
    
    // Danh sách todos sau khi filter và sort
    private var filteredAndSortedTodos: [TodoItem] {
        var todos = appState.allTodos
        
        // Filter theo trạng thái completed
        if !showCompleted {
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
        switch sortOrder {
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
    
    // View hiển thị khi đang loading
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
            Text("Đang tải...")
                .foregroundColor(.secondary)
                .padding(.top)
        }
    }
    
    // View hiển thị khi không có todo nào
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Chưa có công việc nào")
                .font(.title2)
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
            // Filter buttons
            filterBar
            
            // Statistics card
            statisticsCard
            
            // List todos
            List {
                ForEach(filteredAndSortedTodos) { todo in
                    TodoRowView(
                        todo: todo,
                        isSelected: selectedTodoIds.contains(todo.id),
                        isEditMode: isEditMode,
                        onToggle: { toggleComplete(todo) },
                        onDelete: { deleteTodo(todo) }
                    )
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
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteTodo(todo)
                        } label: {
                            Label("Xóa", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            toggleComplete(todo)
                        } label: {
                            Label(
                                todo.isCompleted ? "Chưa xong" : "Hoàn thành",
                                systemImage: todo.isCompleted ? "arrow.uturn.backward" : "checkmark"
                            )
                        }
                        .tint(todo.isCompleted ? .orange : .green)
                    }
                }
            }
            .listStyle(.plain)
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
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if isEditMode {
                Button("Hủy") {
                    // LOCAL STATE: Thoát edit mode
                    isEditMode = false
                    selectedTodoIds.removeAll()
                    print("Thoát edit mode") // In ra hành động thoát
                }
            } else {
                Button {
                    // LOCAL STATE: Vào edit mode
                    isEditMode = true
                    print("Vào edit mode") // In ra hành động vào edit mode
                } label: {
                    Text("Chọn")
                }
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Picker("Sắp xếp", selection: $sortOrder) {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Label(order.displayName, systemImage: order.icon)
                            .tag(order)
                    }
                }
                .onChange(of: sortOrder) { oldValue, newValue in
                    print("Thay đổi sort order: \(newValue.rawValue)") // In ra sort order mới
                }
                
                Divider()
                
                Toggle("Hiện đã hoàn thành", isOn: $showCompleted)
                    .onChange(of: showCompleted) { oldValue, newValue in
                        print("Toggle hiện completed: \(newValue)") // In ra trạng thái toggle
                    }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
        
        if isEditMode && !selectedTodoIds.isEmpty {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button(role: .destructive) {
                        // LOCAL STATE: Hiển thị alert xóa nhiều
                        showBulkDeleteAlert = true
                        print("Chuẩn bị xóa \(selectedTodoIds.count) todos") // In ra số lượng sẽ xóa
                    } label: {
                        Label("Xóa \(selectedTodoIds.count)", systemImage: "trash")
                    }
                    
                    Spacer()
                    
                    Button {
                        bulkToggleComplete()
                    } label: {
                        Label("Đánh dấu hoàn thành", systemImage: "checkmark.circle")
                    }
                }
            }
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

#Preview {
    TodoListView()
        .environmentObject(AppState())
}
