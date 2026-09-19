//
//  CategoryBadge.swift
//  ios_swiftUI_state
//
//  Created by MobileDev on 14/9/26.
//

import SwiftUI

// REUSABLE COMPONENT: Badge hiển thị category của todo
// Không có state management vì chỉ nhận props và hiển thị
struct CategoryBadge: View {
    let category: Category
    let showIcon: Bool
    
    init(category: Category, showIcon: Bool = true) {
        self.category = category
        self.showIcon = showIcon
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if showIcon {
                Image(systemName: category.icon)
                    .font(.system(size: 11))
            }
            
            Text(category.name)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(category.displayColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(category.displayColor.opacity(0.15))
        .cornerRadius(8)
    }
}

struct CategoryBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            ForEach(Category.sampleCategories) { category in
                CategoryBadge(category: category)
            }
            CategoryBadge(category: Category.sampleCategories[0], showIcon: false)
        }
        .padding()
    }
}
