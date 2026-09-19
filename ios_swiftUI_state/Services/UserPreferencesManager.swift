//
//  UserPreferencesManager.swift
//  ios_swiftUI_state
//
//  Created for iOS 13 compatibility - replaces @AppStorage
//

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
            UserDefaults.standard.set(sortOrder.rawValue, forKey: "sortOrder")
        }
    }
    
    @Published var showCompleted: Bool {
        didSet {
            UserDefaults.standard.set(showCompleted, forKey: "showCompleted")
        }
    }
    
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    
    private init() {
        // Load theme
        if let themeRaw = UserDefaults.standard.string(forKey: "theme"),
           let theme = Theme(rawValue: themeRaw) {
            self.theme = theme
        } else {
            self.theme = .system
        }
        
        // Load sortOrder
        if let sortOrderRaw = UserDefaults.standard.string(forKey: "sortOrder"),
           let sortOrder = SortOrder(rawValue: sortOrderRaw) {
            self.sortOrder = sortOrder
        } else {
            self.sortOrder = .date
        }
        
        // Load showCompleted
        if UserDefaults.standard.object(forKey: "showCompleted") != nil {
            self.showCompleted = UserDefaults.standard.bool(forKey: "showCompleted")
        } else {
            self.showCompleted = true
        }
        
        // Load notificationsEnabled
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
    }
}
