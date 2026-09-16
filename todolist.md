Dưới đây là một prompt chi tiết để xây dựng ứng dụng To-Do List trong SwiftUI, thể hiện đầy đủ các mức độ quản lý state:

---

## Prompt: Xây dựng ứng dụng To-Do List với SwiftUI - Quản lý State đa cấp

### Mục tiêu

Tạo một ứng dụng To-Do List hoàn chỉnh để minh họa **tất cả các cấp độ quản lý state** trong SwiftUI: Local State, Screen-level State, và Global State.

### Yêu cầu chi tiết

#### 1. **Kiến trúc ứng dụng**

- Sử dụng MVVM pattern
- Tổ chức rõ ràng: Models, ViewModels, Views, Services
- Áp dụng SwiftUI App Lifecycle

#### 2. **Data Models**

**Todo Item:**

- `id`: UUID
- `title`: String
- `description`: String (optional)
- `isCompleted`: Bool
- `priority`: Enum (Low, Medium, High)
- `category`: String
- `dueDate`: Date (optional)
- `createdAt`: Date
- `tags`: [String]

**Category:**

- `id`: UUID
- `name`: String
- `color`: Color
- `icon`: String (SF Symbol)

**User Preferences:**

- `theme`: Enum (Light, Dark, System)
- `sortOrder`: Enum (Date, Priority, Alphabetical)
- `showCompletedTasks`: Bool
- `notificationsEnabled`: Bool

#### 3. **Quản lý State chi tiết**

##### **A. Local State (@State)**

Sử dụng cho:

- Toggle trạng thái UI tạm thời (show/hide)
- Trạng thái TextField đang nhập liệu
- Animation states
- Focus states

**Ví dụ cần implement:**

- `@State private var isAddingNewTodo: Bool` - hiển thị sheet thêm todo
- `@State private var todoTitle: String` - nội dung đang nhập
- `@State private var isEditMode: Bool` - chế độ chỉnh sửa list
- `@State private var showDeleteConfirmation: Bool` - alert xác nhận xóa
- `@State private var selectedPriority: Priority` - priority đang chọn
- `@State private var isExpanded: Bool` - expand/collapse chi tiết task
- `@State private var searchText: String` - text tìm kiếm

##### **B. Screen-level State (@StateObject, @ObservedObject)**

Sử dụng cho:

- ViewModel quản lý logic màn hình
- Dữ liệu có thể thay đổi trong phạm vi màn hình
- Filtering và sorting tạm thời

**ViewModels cần tạo:**

1. **TodoListViewModel** (ObservableObject)
   - `@Published var todos: [TodoItem]`
   - `@Published var filteredTodos: [TodoItem]`
   - `@Published var isLoading: Bool`
   - `@Published var errorMessage: String?`
   - Methods: `addTodo()`, `deleteTodo()`, `toggleComplete()`, `updateTodo()`
   - Filtering logic: `filterByCategory()`, `filterByPriority()`, `searchTodos()`

2. **CategoryViewModel** (ObservableObject)
   - `@Published var categories: [Category]`
   - `@Published var selectedCategory: Category?`
   - Methods: `addCategory()`, `deleteCategory()`

3. **TodoDetailViewModel** (ObservableObject)
   - `@Published var todo: TodoItem`
   - `@Published var isEditing: Bool`
   - Methods: `saveTodo()`, `deleteTodo()`

##### **C. Global State (@EnvironmentObject, @AppStorage)**

**AppState (EnvironmentObject):**
Tạo singleton class `AppState: ObservableObject` để quản lý:

- `@Published var allTodos: [TodoItem]` - toàn bộ todos
- `@Published var categories: [Category]` - danh sách categories
- `@Published var userPreferences: UserPreferences`
- `@Published var statistics: Statistics` (total, completed, pending)

**UserDefaults (@AppStorage):**

- `@AppStorage("theme") var theme: Theme = .system`
- `@AppStorage("sortOrder") var sortOrder: SortOrder = .date`
- `@AppStorage("showCompleted") var showCompleted: Bool = true`

**Environment Values (custom):**
Tạo custom environment keys cho:

- `theme`: Truyền theme xuống toàn bộ hierarchy
- `accentColor`: Màu chủ đạo của app

#### 4. **Cấu trúc Views**

##### **Main Views:**

1. **ContentView**
   - TabView với 3 tabs: Todos, Categories, Settings
   - Inject `@StateObject var appState = AppState()`
   - Pass xuống dưới bằng `.environmentObject(appState)`

2. **TodoListView**
   - `@EnvironmentObject var appState: AppState`
   - `@StateObject var viewModel: TodoListViewModel`
   - SearchBar với `@State var searchText`
   - List với các todo items
   - Floating action button để thêm todo
   - Filter buttons (All, Active, Completed)
   - Sort menu

3. **TodoRowView** (Component)
   - `@State var isExpanded: Bool = false` - local state
   - Checkbox toggle completion
   - Swipe actions: Edit, Delete
   - Priority indicator
   - Category badge
   - Tap để expand/collapse details

4. **AddEditTodoView**
   - `@Environment(\.dismiss) var dismiss`
   - `@EnvironmentObject var appState: AppState`
   - Form với các local states:
     - `@State var title: String`
     - `@State var description: String`
     - `@State var selectedCategory: Category?`
     - `@State var selectedPriority: Priority`
     - `@State var dueDate: Date`
     - `@State var showDatePicker: Bool`
   - DatePicker, Picker cho category/priority
   - Save button call `appState.addTodo()`

5. **TodoDetailView**
   - `@EnvironmentObject var appState: AppState`
   - `@StateObject var viewModel: TodoDetailViewModel`
   - `@State var isEditing: Bool = false`
   - Hiển thị đầy đủ thông tin
   - Edit mode toggle

6. **CategoriesView**
   - `@EnvironmentObject var appState: AppState`
   - `@State var showAddCategory: Bool`
   - Grid layout các categories
   - Tap category để filter todos

7. **SettingsView**
   - `@AppStorage` bindings cho preferences
   - Toggle notifications
   - Theme picker
   - Sort order picker
   - Statistics summary từ `appState`

##### **Reusable Components:**

- **PriorityBadge**: `let priority: Priority` (không cần state)
- **CategoryBadge**: `let category: Category`
- **StatCard**: Hiển thị thống kê với animation
- **CustomButton**: Reusable button styles

#### 5. **Data Persistence**

Implement `DataManager` class:

- Save/load từ UserDefaults hoặc FileManager
- Encode/Decode Codable models
- Khởi tạo sample data nếu first launch

```swift
class DataManager {
    static let shared = DataManager()

    func saveTodos(_ todos: [TodoItem])
    func loadTodos() -> [TodoItem]
    func saveCategories(_ categories: [Category])
    func loadCategories() -> [Category]
}
```

#### 6. **Features nâng cao thể hiện State Management**

1. **Search & Filter**
   - `@State var searchText` ở TodoListView
   - Computed property `var filteredTodos` trong ViewModel
   - Kết hợp với `@Published` trong AppState

2. **Multi-select Mode**
   - `@State var selectedTodos: Set<UUID>`
   - Bulk delete/complete actions
   - Edit mode toggle

3. **Undo/Redo**
   - Dùng `@Published var history: [AppState]` trong AppState
   - Implement command pattern

4. **Real-time Statistics**
   - Computed từ `appState.allTodos`
   - Update tự động khi todos thay đổi
   - Hiển thị: Total, Completed %, Today's tasks

5. **Animations**
   - `@State var isAnimating: Bool`
   - withAnimation khi add/delete
   - Transition effects

#### 7. **Minh họa State Flow**

**Ví dụ: Thêm một Todo mới**

```
User tap Add Button
→ @State isAddingNewTodo = true (Local)
→ Sheet appears with AddEditTodoView
→ User nhập title: @State var title (Local)
→ User chọn category: from @EnvironmentObject appState (Global)
→ User tap Save
→ Call appState.addTodo() (Global state updated)
→ @Published allTodos triggers update
→ TodoListView auto refresh via @EnvironmentObject
→ ViewModel's @Published filteredTodos recalculates
→ UI updates automatically
```

**Ví dụ: Toggle Complete**

```
User tap checkbox in TodoRowView
→ Local animation @State
→ Call viewModel.toggleComplete(id)
→ ViewModel updates @Published todos
→ ViewModel notifies appState (Global)
→ appState.statistics recalculates
→ SettingsView's StatCard updates automatically
```

#### 8. **Code Structure**

```
TodoApp/
├── TodoApp.swift (@main)
├── Models/
│   ├── TodoItem.swift
│   ├── Category.swift
│   ├── UserPreferences.swift
│   └── Priority.swift
├── ViewModels/
│   ├── AppState.swift (Global State)
│   ├── TodoListViewModel.swift
│   ├── TodoDetailViewModel.swift
│   └── CategoryViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── Todos/
│   │   ├── TodoListView.swift
│   │   ├── TodoRowView.swift
│   │   ├── TodoDetailView.swift
│   │   └── AddEditTodoView.swift
│   ├── Categories/
│   │   ├── CategoriesView.swift
│   │   └── CategoryCard.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Components/
│       ├── PriorityBadge.swift
│       ├── CategoryBadge.swift
│       ├── StatCard.swift
│       └── SearchBar.swift
├── Services/
│   └── DataManager.swift
└── Utilities/
    ├── Extensions.swift
    └── Constants.swift
```

#### 9. **Yêu cầu kỹ thuật**

- iOS 17.0+
- SwiftUI
- Combine framework cho reactive updates
- Không dùng thư viện bên ngoài
- Code comments giải thích từng loại state
- Unit tests cho ViewModels

#### 10. **Comments & Documentation**

Mỗi property state cần comment:

```swift
// LOCAL STATE: Controls the visibility of add todo sheet
@State private var isAddingNewTodo: Bool = false

// SCREEN-LEVEL STATE: Manages todos for this screen with filtering
@StateObject private var viewModel = TodoListViewModel()

// GLOBAL STATE: Access to app-wide todo data and user preferences
@EnvironmentObject var appState: AppState

// PERSISTENT STATE: User's preferred theme, saved across launches
@AppStorage("theme") var theme: Theme = .system
```

#### 11. **Testing Scenarios**

- Add todo → verify nó xuất hiện ở TodoListView và statistics update
- Complete todo → verify checkmark, statistics, và filter "Active" hoạt động
- Delete todo → verify xóa khỏi list và global state
- Change theme ở Settings → verify toàn bộ app update ngay lập tức
- Search → verify filtering works với local state
- Rotate device → verify state persistence

---

### Deliverables

1. Hoàn chỉnh source code với structure trên
2. README.md giải thích chi tiết từng loại state được dùng ở đâu
3. Diagram minh họa data flow giữa các components
4. Demo video showing state changes propagating through app

QUY TẮC CODE VÀ COMMENT BẮT BUỘC

1. Đặt tên biến và hàm:

- Phải rõ nghĩa, mô tả đầy đủ mục đích
- KHÔNG dùng tên viết tắt như arr1, arr2, str, val, tmp
- Dùng camelCase theo chuẩn Swift
- Ví dụ tốt: studentNames, calculateTotalPrice, userProfileData
- Ví dụ xấu: arr, calc, data

2. Comment:

- Mỗi comment phải viết HOA chữ cái đầu tiên
- Comment giải thích "tại sao" không chỉ "cái gì"
- Ví dụ: // Tính tổng điểm của học sinh để xếp hạng

3. Print/Log:

- Mỗi dòng print phải rõ nghĩa về giá trị đang in
- Format: print("Mô tả rõ ràng: \(giaTri)") // Mô tả ngắn gọn giá trị
- Ví dụ: print("Tổng điểm của học sinh: \(totalScore)") // In ra tổng điểm đã tính 
