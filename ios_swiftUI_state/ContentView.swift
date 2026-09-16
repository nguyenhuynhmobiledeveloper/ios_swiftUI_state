//
//  ContentView.swift
//  ios_swiftUI_state
//
//  Created by MobileDev on 14/9/26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("theme") private var theme: Theme = .system

    var body: some View {
        TabView {
            TodoListView()
                .tabItem {
                    Label("Công việc", systemImage: "checklist")
                }

            CategoriesView()
                .tabItem {
                    Label("Danh mục", systemImage: "folder")
                }

            SettingsView()
                .tabItem {
                    Label("Cài đặt", systemImage: "gearshape")
                }
        }
        .preferredColorScheme(colorScheme)
    }

    private var colorScheme: ColorScheme? {
        switch theme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
