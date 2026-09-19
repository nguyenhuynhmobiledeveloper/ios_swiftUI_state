//
//  ContentView.swift
//  ios_swiftUI_state
//
//  Created by MobileDev on 14/9/26.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var preferences = UserPreferencesManager.shared

    var body: some View {
        TabView {
            TodoListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Công việc")
                }

            CategoriesView()
                .tabItem {
                    Image(systemName: "folder")
                    Text("Danh mục")
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Cài đặt")
                }
        }
        .preferredColorScheme(colorScheme)
    }

    private var colorScheme: ColorScheme? {
        switch preferences.theme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}
