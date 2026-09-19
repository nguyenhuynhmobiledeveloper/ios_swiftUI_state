# Hướng Dẫn Hỗ Trợ iOS 13 Cho Ứng Dụng Todo List

## Tổng Quan

> Checklist cuối tài liệu phản ánh trạng thái triển khai đã kiểm chứng. Các ví dụ bên dưới là hướng dẫn ban đầu; khi khác biệt, xem mã nguồn hiện tại và checklist.

Ứng dụng Todo List hiện tại sử dụng nhiều tính năng SwiftUI hiện đại (iOS 14-17+). Để hỗ trợ iOS 13, cần thực hiện nhiều thay đổi quan trọng về cấu trúc và API.

## ⚠️ Cảnh Báo Quan Trọng

**SwiftUI trên iOS 13 có nhiều hạn chế:**
- Thiếu nhiều API tiện lợi
- Hiệu năng kém hơn
- Nhiều bugs chưa được sửa
- Apple đã ngừng hỗ trợ iOS 13 (EOL)

**Khuyến nghị:** Nên giữ minimum deployment target ở **iOS 14** trở lên để có trải nghiệm tốt nhất.

---

## Bước 1: Thay Đổi Deployment Target

### 1.1. Trong Xcode

1. Mở file `ios_swiftUI_state.xcodeproj` trong Xcode
2. Chọn project trong Project Navigator
3. Chọn target `ios_swiftUI_state`
4. Trong tab **General**, tìm **Minimum Deployments**
5. Thay đổi **iOS** từ `26.5` → `13.0`

### 1.2. Hoặc Chỉnh Sửa Trực Tiếp project.pbxproj

Mở file `ios_swiftUI_state.xcodeproj/project.pbxproj`, tìm và thay thế:

```diff
- IPHONEOS_DEPLOYMENT_TARGET = 26.5;
+ IPHONEOS_DEPLOYMENT_TARGET = 13.0;
```

**Vị trí cần thay:** Có 2 chỗ (Debug và Release configuration)

---

## Bước 2: Thay Đổi App Entry Point (Critical)

### Vấn Đề

File `ios_swiftUI_stateApp.swift` sử dụng:
- `@main` attribute (iOS 14+)
- `App` protocol (iOS 14+)

### Giải Pháp

Thay thế bằng `UIApplicationDelegate` và `SceneDelegate`.

### 2.1. Xóa File Cũ

```bash
# Backup trước khi xóa
cp ios_swiftUI_state/ios_swiftUI_stateApp.swift ios_swiftUI_state/ios_swiftUI_stateApp.swift.backup
```

### 2.2. Tạo AppDelegate.swift

```swift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
}
```

### 2.3. Tạo SceneDelegate.swift

```swift
import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appState = AppState()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        let contentView = ContentView()
            .environmentObject(appState)

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
```

### 2.4. Tạo Info.plist Entries

Thêm vào `Info.plist`:

```xml
<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <false/>
    <key>UISceneConfigurations</key>
    <dict>
        <key>UIWindowSceneSessionRoleApplication</key>
        <array>
            <dict>
                <key>UISceneConfigurationName</key>
                <string>Default Configuration</string>
                <key>UISceneDelegateClassName</key>
                <string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
            </dict>
        </array>
    </dict>
</dict>
```

---

## Bước 3: Thay Thế @StateObject

### Vấn Đề

`@StateObject` chỉ có từ iOS 14+.

### Giải Pháp

#### 3.1. Trong TodoListView.swift

```diff
- @StateObject private var viewModel = TodoListViewModel()
+ @ObservedObject private var viewModel: TodoListViewModel
+ 
+ init() {
+     self.viewModel = TodoListViewModel()
+ }
```

#### 3.2. Trong Các View Khác

Tìm tất cả `@StateObject` và thay bằng `@ObservedObject` với init tương tự.

**Lưu ý:** iOS 13 không tự động quản lý lifecycle, có thể gặp issue với memory.

---

## Bước 4: Thay Thế NavigationStack

### Vấn Đề

`NavigationStack` là iOS 16+.

### Giải Pháp

#### Trong SettingsView.swift:

```diff
- NavigationStack {
+ NavigationView {
      Form {
          // ... content
      }
      .navigationTitle("Cài đặt")
+ }
+ .navigationViewStyle(StackNavigationViewStyle()) // Quan trọng cho iPad
```

---

## Bước 5: Thay Thế @AppStorage

### Vấn Đề

`@AppStorage` là iOS 14+.

### Giải Pháp: Tạo Property Wrapper Tùy Chỉnh

#### 5.1. Tạo File UserDefaultsWrapper.swift

```swift
import Foundation
import Combine

@propertyWrapper
struct UserDefault<T: Codable> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.data(forKey: key) else {
                return defaultValue
            }
            let value = try? JSONDecoder().decode(T.self, from: data)
            return value ?? defaultValue
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

// Cho các kiểu đơn giản (String, Int, Bool, etc.)
@propertyWrapper
struct UserDefaultSimple<T> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
```

#### 5.2. Thay Thế Trong ContentView.swift

```diff
- @AppStorage("theme") private var theme: Theme = .system
+ @State private var theme: Theme = UserDefaults.standard.string(forKey: "theme")
+     .flatMap { Theme(rawValue: $0) } ?? .system
```

#### 5.3. Hoặc Sử Dụng ObservableObject

Tạo `UserPreferencesManager.swift`:

```swift
import Foundation
import Combine

class UserPreferencesManager: ObservableObject {
    static let shared = UserPreferencesManager()
    
    @Published var theme: Theme {
        didSet {
            UserDefaults.standard.set(theme.rawValue, forKey: "theme")
        }
    }
    
    @Published var sortOrder: SortOrder {
        didSet {
            let data = try? JSONEncoder().encode(sortOrder)
            UserDefaults.standard.set(data, forKey: "sortOrder")
        }
    }
    
    @Published var showCompleted: Bool {
        didSet {
            UserDefaults.standard.set(showCompleted, forKey: "showCompleted")
        }
    }
    
    private init() {
        // Load from UserDefaults
        if let themeRaw = UserDefaults.standard.string(forKey: "theme"),
           let theme = Theme(rawValue: themeRaw) {
            self.theme = theme
        } else {
            self.theme = .system
        }
        
        self.showCompleted = UserDefaults.standard.bool(forKey: "showCompleted")
        
        if let data = UserDefaults.standard.data(forKey: "sortOrder"),
           let sortOrder = try? JSONDecoder().decode(SortOrder.self, from: data) {
            self.sortOrder = sortOrder
        } else {
            self.sortOrder = .date
        }
    }
}
```

Sau đó inject vào EnvironmentObject.

---

## Bước 6: Thay Thế .searchable()

### Vấn Đề

`.searchable()` modifier là iOS 15+.

### Giải Pháp: Sử Dụng UISearchBar Wrapper

#### 6.1. Tạo SearchBar.swift (Đã Có)

File này đã tồn tại, cần verify nó hoạt động với iOS 13:

```swift
// ios_swiftUI_state/Views/Components/SearchBar.swift
import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Tìm kiếm..."
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
    }
}
```

#### 6.2. Thay Thế Trong TodoListView.swift

```diff
  .navigationTitle("Công việc")
  .toolbar {
      toolbarContent
  }
- .searchable(text: $searchText, prompt: "Tìm kiếm công việc...")
+ 
+ // Thêm SearchBar vào body, ngay trước todoListContent
+ private var todoListContent: some View {
+     VStack(spacing: 0) {
+         SearchBar(text: $searchText, placeholder: "Tìm kiếm công việc...")
+         
+         // Filter buttons
+         filterBar
+         // ... rest of content
+     }
+ }
```

---

## Bước 7: Thay Thế .swipeActions()

### Vấn Đề

`.swipeActions()` modifier là iOS 15+.

### Giải Pháp: Sử Dụng .onDelete() và Context Menu

#### 7.1. Thay Đổi TodoListView.swift

```diff
  ForEach(filteredAndSortedTodos) { todo in
      TodoRowView(...)
          .onTapGesture {
              // ... existing code
          }
-         .swipeActions(edge: .trailing, allowsFullSwipe: true) {
-             Button(role: .destructive) {
-                 deleteTodo(todo)
-             } label: {
-                 Label("Xóa", systemImage: "trash")
-             }
-         }
-         .swipeActions(edge: .leading) {
-             Button {
-                 toggleComplete(todo)
-             } label: {
-                 Label(
-                     todo.isCompleted ? "Chưa xong" : "Hoàn thành",
-                     systemImage: todo.isCompleted ? "arrow.uturn.backward" : "checkmark"
-                 )
-             }
-             .tint(todo.isCompleted ? .orange : .green)
-         }
+         .contextMenu {
+             Button(action: {
+                 toggleComplete(todo)
+             }) {
+                 HStack {
+                     Text(todo.isCompleted ? "Đánh dấu chưa xong" : "Đánh dấu hoàn thành")
+                     Image(systemName: todo.isCompleted ? "arrow.uturn.backward" : "checkmark")
+                 }
+             }
+             
+             Button(action: {
+                 deleteTodo(todo)
+             }) {
+                 HStack {
+                     Text("Xóa")
+                     Image(systemName: "trash")
+                 }
+             }
+         }
  }
+ .onDelete { indexSet in
+     deleteTodos(at: indexSet)
+ }
```

#### 7.2. Thêm Helper Function

```swift
// Trong TodoListView
private func deleteTodos(at offsets: IndexSet) {
    withAnimation {
        let todosToDelete = offsets.map { filteredAndSortedTodos[$0] }
        todosToDelete.forEach { appState.deleteTodo($0) }
    }
}
```

---

## Bước 8: Thay Thế .onChange() Với 2 Parameters

### Vấn Đề

`.onChange(of:)` với closure `(oldValue, newValue)` là iOS 17+.

### Giải Pháp

#### Trong TodoListView.swift và Các View Khác:

```diff
- .onChange(of: searchText) { oldValue, newValue in
+ .onChange(of: searchText) { newValue in
      print("Text tìm kiếm thay đổi: '\(newValue)'")
  }

- .onChange(of: selectedFilter) { oldValue, newValue in
+ .onChange(of: selectedFilter) { newValue in
      print("Filter thay đổi: \(newValue.rawValue)")
  }
```

**Lưu ý:** `.onChange()` có sẵn từ iOS 14, nhưng iOS 13 không có. Cần xử lý khác.

#### Giải Pháp Cho iOS 13:

Sử dụng Combine với `.onReceive()`:

```swift
import Combine

struct TodoListView: View {
    @State private var searchText: String = ""
    
    var body: some View {
        // ... existing code
        .onReceive(Just(searchText)) { newValue in
            print("Text tìm kiếm thay đổi: '\(newValue)'")
        }
    }
}
```

Hoặc đơn giản hơn, bỏ `.onChange()` và xử lý logic trong computed property.

---

## Bước 9: Kiểm Tra Label Với systemImage

### Vấn Đề

`Label` với cú pháp hiện đại là iOS 14+.

### Giải Pháp Cho iOS 13

#### Option 1: Tạo Custom Label

```swift
struct CustomLabel: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
            Text(title)
        }
    }
}
```

#### Option 2: Sử Dụng HStack Trực Tiếp

```diff
- Label("Công việc", systemImage: "checklist")
+ HStack {
+     Image(systemName: "checklist")
+     Text("Công việc")
+ }
```

---

## Bước 10: Cập Nhật Preview

### Vấn Đề

`#Preview` macro là iOS 17+.

### Giải Pháp

```diff
- #Preview {
+ struct ContentView_Previews: PreviewProvider {
+     static var previews: some View {
          ContentView()
              .environmentObject(AppState())
+     }
+ }

- #Preview {
+ struct SettingsView_Previews: PreviewProvider {
+     static var previews: some View {
          SettingsView()
              .environmentObject(AppState())
+     }
+ }
```

---

## Bước 11: Kiểm Tra Các API Khác

### 11.1. ToolbarContentBuilder

iOS 14+, nhưng `toolbar` modifier có từ iOS 14.

**Giải pháp:** Sử dụng `.navigationBarItems()` (deprecated nhưng hoạt động trên iOS 13):

```swift
.navigationBarItems(
    leading: Button("Chọn") {
        isEditMode = true
    },
    trailing: Menu { ... } label: {
        Image(systemName: "ellipsis.circle")
    }
)
```

### 11.2. Menu

Menu có từ iOS 14+.

**Giải pháp iOS 13:** Sử dụng `ActionSheet` hoặc tự tạo custom menu.

```swift
.navigationBarItems(trailing:
    Button(action: {
        showActionSheet = true
    }) {
        Image(systemName: "ellipsis.circle")
    }
)
.actionSheet(isPresented: $showActionSheet) {
    ActionSheet(
        title: Text("Tùy chọn"),
        buttons: [
            .default(Text("Sắp xếp theo ngày")) {
                sortOrder = .date
            },
            .default(Text("Sắp xếp theo ưu tiên")) {
                sortOrder = .priority
            },
            .cancel()
        ]
    )
}
```

---

## Bước 12: Build và Test

### 12.1. Clean Build

```bash
# Trong terminal
cd /Users/MobileDev/ios/Ios/ios_swiftUI_state
# Dùng DerivedData riêng cho dự án, không xóa cache của tất cả dự án.
xcodebuild -project ios_swiftUI_state.xcodeproj \
  -scheme ios_swiftUI_state -derivedDataPath /tmp/ios13-build clean
```

Hoặc trong Xcode: **Product > Clean Build Folder** (Shift + Cmd + K)

### 12.2. Build Project

```bash
xcodebuild -project ios_swiftUI_state.xcodeproj \
           -scheme ios_swiftUI_state \
           -configuration Debug \
           -sdk iphonesimulator \
           IPHONEOS_DEPLOYMENT_TARGET=13.0
```

### 12.3. Test Trên Simulator

1. Mở Xcode
2. Chọn iOS 13.x Simulator (nếu đã cài)
3. Cmd + R để run

**Lưu ý:** Xcode 15/16 có thể không hỗ trợ iOS 13 simulator. Cần Xcode 12.x để test.

---

## Bước 13: Xử Lý Các Vấn Đề Phổ Biến

### 13.1. "Cannot find type 'App' in scope"

→ Đã thay thế bằng AppDelegate + SceneDelegate ở Bước 2.

### 13.2. "Property wrappers are not yet supported on local properties"

Xảy ra với `@StateObject` trong init.
→ Sử dụng `@ObservedObject` thay thế.

### 13.3. List Performance Issues

iOS 13 SwiftUI List performance rất kém với nhiều items.

**Giải pháp:**
- Giới hạn số items hiển thị
- Sử dụng LazyVStack thay vì List (nhưng LazyVStack là iOS 14+)
- Tối ưu TodoRowView, tránh heavy computation

### 13.4. Animation Glitches

iOS 13 có nhiều animation bugs.

**Giải pháp:**
- Giảm số lượng animations
- Sử dụng `.animation(.default)` thay vì `.animation(.spring())`
- Test kỹ trên device thật

---

## Tổng Kết

### Các File Cần Tạo Mới

1. ✅ `AppDelegate.swift`
2. ✅ `SceneDelegate.swift`
3. ✅ `UserDefaultsWrapper.swift` (hoặc `UserPreferencesManager.swift`)

### Các File Cần Chỉnh Sửa

1. ✅ `project.pbxproj` - Deployment target
2. ✅ `ios_swiftUI_stateApp.swift` - Xóa hoặc backup
3. ✅ `ContentView.swift` - @AppStorage, Label
4. ✅ `TodoListView.swift` - @StateObject, .searchable, .swipeActions, .onChange
5. ✅ `SettingsView.swift` - NavigationStack, @AppStorage
6. ✅ Tất cả Preview blocks - #Preview → PreviewProvider
7. ✅ Các ViewModel files - Kiểm tra @Published và Combine

### Checklist Hoàn Thành

Cập nhật ngày 2026-09-16, dựa trên mã nguồn và kết quả build thực tế:

- [x] Thay đổi deployment target thành 13.0 (Debug và Release)
- [x] Tạo AppDelegate và SceneDelegate; cấu hình scene trong Configuration/Info.plist
- [x] Xóa/Comment App protocol; loại file .backup khỏi sản phẩm build
- [x] Loại @StateObject; preferences dùng @ObservedObject với singleton, list/detail đọc trực tiếp AppState để tránh tạo lại ViewModel trong init
- [x] Thay NavigationStack → NavigationView
- [x] Thay @AppStorage → UserPreferencesManager, giữ nguyên các khóa UserDefaults
- [x] Thay .searchable → Custom SearchBar, bỏ @FocusState
- [x] Thay .swipeActions → .contextMenu + .onDelete; chụp danh sách trước khi xóa nhiều chỉ số
- [x] Loại .onChange; UI cập nhật theo @State/@EnvironmentObject
- [x] Thay Label → HStack(Image + Text)
- [x] Thay toàn bộ #Preview → PreviewProvider
- [x] Thay .toolbar → .navigationBarItems
- [x] Thay Menu → ActionSheet
- [x] Thay LazyVGrid/GridItem bằng lưới VStack/HStack thay đổi số cột theo chiều rộng
- [x] Thay TextEditor bằng UITextView bọc UIViewRepresentable
- [x] Thay API font, màu, style, định dạng ngày và symbol không phù hợp iOS 13
- [x] Thêm LaunchScreen.storyboard cho iOS 13
- [x] Truyền AppState vào sheet chỉnh sửa; chi tiết đọc dữ liệu mới nhất sau khi lưu
- [x] Giữ ô tìm kiếm/bộ lọc khi kết quả rỗng; tách vị trí gắn hai sheet
- [x] Build Debug cho iOS Simulator — BUILD SUCCEEDED
- [x] Build Release cho thiết bị arm64, không ký — BUILD SUCCEEDED
- [x] Kiểm tra Info.plist sản phẩm: MinimumOSVersion = 13.0, SceneDelegate và launch storyboard đúng
- [x] Cài và mở app trên iPhone 16 / iOS 18.5; kiểm tra ảnh màn hình công việc
- [ ] Kiểm thử thao tác đầy đủ trên iOS 13.x: thêm/sửa/xóa, tìm kiếm rỗng và xóa tìm kiếm, bộ lọc, context menu, danh mục, theme, lưu dữ liệu sau mở lại app, iPad/xoay màn hình

**Giới hạn kiểm chứng:** Máy hiện có runtime iOS 18.5 và 26.5, chưa có iOS 13.
Build với deployment target 13.0 kiểm tra availability khi biên dịch, chưa thay thế kiểm thử runtime iOS 13.
Smoke test iOS 18.5 chỉ xác nhận khởi động và hiển thị màn hình chính; chưa xác nhận toàn bộ thao tác UI.
Release chưa được ký/cài lên thiết bị thật.

**Lệnh build đã dùng** (không cần ghi đè deployment target, lấy trực tiếp từ project):

```bash
xcodebuild -project ios_swiftUI_state.xcodeproj \
  -scheme ios_swiftUI_state -configuration Debug -sdk iphonesimulator \
  -derivedDataPath /tmp/ios13-build CODE_SIGNING_ALLOWED=NO build

xcodebuild -project ios_swiftUI_state.xcodeproj \
  -scheme ios_swiftUI_state -configuration Release -sdk iphoneos \
  -derivedDataPath /tmp/ios13-device-build CODE_SIGNING_ALLOWED=NO build
```

Log kiểm chứng trong phiên làm việc: /tmp/ios13-build.log và /tmp/ios13-release.log.

---

## Câu Hỏi Thường Gặp

### 1. Có nên hỗ trợ iOS 13 không?

**Không khuyến khích.** iOS 13 chỉ chiếm <5% thị phần (2024 data). SwiftUI trên iOS 13 rất hạn chế và buggy.

**Khuyến nghị:** Minimum iOS 14 hoặc iOS 15.

### 2. Có cách nào dễ hơn không?

Có thể sử dụng `#available` checks:

```swift
if #available(iOS 14.0, *) {
    // Sử dụng @StateObject
} else {
    // Fallback cho iOS 13
}
```

Nhưng code sẽ phức tạp và khó maintain.

### 3. Performance trên iOS 13 như thế nào?

Rất kém, đặc biệt với List và nhiều @State. Cần tối ưu kỹ.

### 4. Có mất tính năng nào không?

Có. Một số tính năng không thể replicate được 100%:
- Search trong navigation bar
- Swipe actions với full swipe
- Modern toolbar system
- @StateObject lifecycle

---

## Tài Liệu Tham Khảo

- [SwiftUI iOS Version Compatibility](https://developer.apple.com/documentation/swiftui)
- [iOS 13 Release Notes](https://developer.apple.com/documentation/ios-release-notes)
- [Migration Guide](https://developer.apple.com/documentation/swiftui/migrating-to-new-swiftui-apis)

---

**Tác giả:** Generated for iOS SwiftUI State Management Project  
**Ngày:** 2026-09-16  
**Phiên bản:** 1.0
