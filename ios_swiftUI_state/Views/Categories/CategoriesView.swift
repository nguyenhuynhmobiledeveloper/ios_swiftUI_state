//
//  CategoriesView.swift
//  ios_swiftUI_state
//
//  Màn hình quản lý danh mục - minh họa Global State và Local State
//

import SwiftUI

struct CategoriesView: View {
    // GLOBAL STATE: Truy cập dữ liệu categories toàn app
    @EnvironmentObject var appState: AppState
    
    // LOCAL STATE: Điều khiển hiển thị sheet thêm category
    @State private var showAddCategory: Bool = false
    
    // LOCAL STATE: Text đang nhập khi tạo category mới
    @State private var newCategoryName: String = ""
    
    // LOCAL STATE: Màu đã chọn cho category mới
    @State private var selectedColorName: String = "blue"
    
    // LOCAL STATE: Icon đã chọn cho category mới
    @State private var selectedIcon: String = "folder"
    
    // LOCAL STATE: Category đang được chỉnh sửa
    @State private var editingCategory: Category?
    
    // LOCAL STATE: Hiển thị alert xác nhận xóa
    @State private var showDeleteAlert: Bool = false
    
    // LOCAL STATE: Category chuẩn bị xóa
    @State private var categoryToDelete: Category?
    
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    let availableIcons = ["folder", "star", "heart", "bookmark", "flag", "house", "cart", "bag", "tag", "paperplane"]
    let availableColorNames = ["blue", "green", "red", "orange", "purple", "pink", "yellow", "indigo"]

    private var selectedColor: Color {
        Category(name: "", color: selectedColorName, icon: "folder").displayColor
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if appState.categories.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(appState.categories) { category in
                                Button {
                                    print("Đã chọn category: \(category.name)")
                                } label: {
                                    CategoryCard(
                                        category: category,
                                        todoCount: appState.todosByCategory(categoryId: category.id).count,
                                        isSelected: false
                                    )
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button("Xóa", systemImage: "trash", role: .destructive) {
                                        // Chuẩn bị xóa category
                                        categoryToDelete = category
                                        showDeleteAlert = true
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Danh mục")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // LOCAL STATE: Hiển thị sheet thêm category
                        showAddCategory = true
                        print("Mở sheet thêm category mới") // In ra trạng thái mở sheet
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAddCategory) {
                addCategorySheet
            }
            .alert("Xóa danh mục", isPresented: $showDeleteAlert) {
                Button("Hủy", role: .cancel) {
                    print("Hủy xóa category") // In ra hành động hủy
                }
                Button("Xóa", role: .destructive) {
                    if let category = categoryToDelete {
                        // GLOBAL STATE: Xóa category khỏi app state
                        appState.deleteCategory(id: category.id)
                        print("Đã xóa category: \(category.name)") // In ra category đã xóa
                    }
                }
            } message: {
                if let category = categoryToDelete {
                    Text("Bạn có chắc muốn xóa danh mục '\(category.name)'?")
                }
            }
        }
    }
    
    // View hiển thị khi chưa có category nào
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Chưa có danh mục nào")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Nhấn nút + để tạo danh mục đầu tiên")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button {
                showAddCategory = true
                print("Mở sheet từ empty state") // In ra nguồn mở sheet
            } label: {
                Label("Thêm danh mục", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
    
    // Sheet để thêm category mới
    private var addCategorySheet: some View {
        NavigationView {
            Form {
                Section("Thông tin danh mục") {
                    TextField("Tên danh mục", text: $newCategoryName)
                        .textInputAutocapitalization(.words)
                }
                
                Section("Chọn biểu tượng") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Button {
                                    // LOCAL STATE: Cập nhật icon được chọn
                                    selectedIcon = icon
                                    print("Đã chọn icon: \(icon)") // In ra icon được chọn
                                } label: {
                                    Image(systemName: icon)
                                        .font(.title)
                                        .frame(width: 60, height: 60)
                                        .background(selectedIcon == icon ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(selectedIcon == icon ? Color.accentColor : Color.clear, lineWidth: 2)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section("Chọn màu sắc") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(availableColorNames, id: \.self) { colorName in
                                let color = Category(name: "", color: colorName, icon: "folder").displayColor
                                Button {
                                    // LOCAL STATE: Cập nhật màu được chọn
                                    selectedColorName = colorName
                                    print("Đã chọn màu: \(colorName)") // In ra màu được chọn
                                } label: {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedColorName == colorName ? Color.primary : Color.clear, lineWidth: 3)
                                        )
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section {
                    // Preview category mới
                    HStack {
                        Image(systemName: selectedIcon)
                            .font(.title2)
                            .foregroundColor(selectedColor)
                            .frame(width: 40, height: 40)
                            .background(selectedColor.opacity(0.2))
                            .cornerRadius(8)
                        
                        Text(newCategoryName.isEmpty ? "Xem trước" : newCategoryName)
                            .font(.headline)
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Xem trước")
                }
            }
            .navigationTitle("Thêm danh mục")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        // LOCAL STATE: Đóng sheet và reset
                        showAddCategory = false
                        resetForm()
                        print("Hủy thêm category và reset form") // In ra hành động hủy
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        // GLOBAL STATE: Thêm category mới vào app state
                        let newCategory = Category(
                            name: newCategoryName,
                            color: selectedColorName,
                            icon: selectedIcon
                        )
                        appState.addCategory(newCategory)
                        print("Đã tạo category mới: \(newCategory.name) với icon \(newCategory.icon)") // In ra category đã tạo
                        
                        // LOCAL STATE: Đóng sheet và reset
                        showAddCategory = false
                        resetForm()
                    }
                    .disabled(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    // Hàm reset form về trạng thái ban đầu
    private func resetForm() {
        // Reset các LOCAL STATE về giá trị mặc định
        newCategoryName = ""
        selectedColorName = "blue"
        selectedIcon = "folder"
        print("Đã reset form thêm category") // In ra trạng thái reset
    }
}

#Preview {
    CategoriesView()
        .environmentObject(AppState())
}
