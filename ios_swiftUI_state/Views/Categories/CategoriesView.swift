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
                    GeometryReader { geometry in
                        ScrollView {
                            categoryGrid(width: geometry.size.width)
                                .padding()
                        }
                    }
                }
            }
            .navigationBarTitle("Danh mục")
            .navigationBarItems(
                trailing: Button(action: {
                    showAddCategory = true
                    print("Mở sheet thêm category mới")
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                }
            )
            .sheet(isPresented: $showAddCategory) {
                addCategorySheet
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Xóa danh mục"),
                    message: categoryToDelete.map { Text("Bạn có chắc muốn xóa danh mục '\($0.name)'?") },
                    primaryButton: .cancel(Text("Hủy")) {
                        print("Hủy xóa category")
                    },
                    secondaryButton: .destructive(Text("Xóa")) {
                        if let category = categoryToDelete {
                            appState.deleteCategory(id: category.id)
                            print("Đã xóa category: \(category.name)")
                        }
                    }
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func categoryGrid(width: CGFloat) -> some View {
        let columnCount = max(1, Int((width - 32 + 16) / 166))
        let rowCount = (appState.categories.count + columnCount - 1) / columnCount
        return VStack(spacing: 16) {
            ForEach(0..<rowCount, id: \.self) { row in
                HStack(spacing: 16) {
                    ForEach(0..<columnCount, id: \.self) { column in
                        self.categoryCell(at: row * columnCount + column)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func categoryCell(at index: Int) -> some View {
        if index < appState.categories.count {
            let category = appState.categories[index]
            CategoryCard(
                category: category,
                todoCount: appState.todosByCategory(categoryId: category.id).count,
                isSelected: false
            )
            .contextMenu {
                Button(action: {
                    categoryToDelete = category
                    showDeleteAlert = true
                }) {
                    HStack { Image(systemName: "trash"); Text("Xóa") }
                }
            }
        } else {
            Color.clear
        }
    }

    // View hiển thị khi chưa có category nào
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Chưa có danh mục nào")
                .font(.system(size: 22))
                .fontWeight(.semibold)
            
            Text("Nhấn nút + để tạo danh mục đầu tiên")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button {
                showAddCategory = true
                print("Mở sheet từ empty state") // In ra nguồn mở sheet
            } label: {
                HStack { Image(systemName: "plus.circle.fill"); Text("Thêm danh mục") }
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
                Section(header: Text("Thông tin danh mục")) {
                    TextField("Tên danh mục", text: $newCategoryName)
                        .autocapitalization(.words)
                }
                
                Section(header: Text("Chọn biểu tượng")) {
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
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text("Chọn màu sắc")) {
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
                
                Section(header: Text("Xem trước")) {
                    // Preview category mới
                    HStack {
                        Image(systemName: selectedIcon)
                            .font(.system(size: 22))
                            .foregroundColor(selectedColor)
                            .frame(width: 40, height: 40)
                            .background(selectedColor.opacity(0.2))
                            .cornerRadius(8)
                        
                        Text(newCategoryName.isEmpty ? "Xem trước" : newCategoryName)
                            .font(.headline)
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationBarTitle("Thêm danh mục", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Hủy") {
                    showAddCategory = false
                    resetForm()
                    print("Hủy thêm category và reset form")
                },
                trailing: Button("Lưu") {
                    let newCategory = Category(
                        name: newCategoryName,
                        color: selectedColorName,
                        icon: selectedIcon
                    )
                    appState.addCategory(newCategory)
                    print("Đã tạo category mới: \(newCategory.name) với icon \(newCategory.icon)")
                    
                    showAddCategory = false
                    resetForm()
                }
                .disabled(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
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

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
            .environmentObject(AppState())
    }
}
