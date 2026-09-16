//
//  SearchBar.swift
//  ios_swiftUI_state
//
//  Created by MobileDev on 14/9/26.
//

import SwiftUI

// REUSABLE COMPONENT: Thanh tìm kiếm với binding state
struct SearchBar: View {
    // BINDING: Kết nối với state của parent view
    @Binding var text: String
    
    // LOCAL STATE: Quản lý focus state của search field
    @FocusState private var isFocused: Bool
    
    var placeholder: String
    var onClear: (() -> Void)?
    
    init(text: Binding<String>, placeholder: String = "Search...", onClear: (() -> Void)? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.onClear = onClear
    }
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .focused($isFocused)
                .textFieldStyle(.plain)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    isFocused = false
                    onClear?()
                    print("Đã xóa search text") // Log clear action
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
    }
}

#Preview {
    VStack {
        SearchBar(text: .constant(""))
        SearchBar(text: .constant("SwiftUI"))
        SearchBar(text: .constant("Todo"), placeholder: "Search todos...")
    }
    .padding()
}
