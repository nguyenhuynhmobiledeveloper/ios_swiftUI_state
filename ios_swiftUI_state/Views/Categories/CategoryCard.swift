//
//  CategoryCard.swift
//  ios_swiftUI_state
//
//  Created by MobileDev on 14/9/26.
//

import SwiftUI

/// Component hiển thị một category dạng card
struct CategoryCard: View {
    // Không cần state vì chỉ hiển thị dữ liệu được truyền vào
    let category: Category
    let todoCount: Int
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Icon của category
                Image(systemName: category.icon)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(category.displayColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Spacer()
                
                // Badge hiển thị số lượng todo
                Text("\(todoCount)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(Capsule())
            }
            
            // Tên category
            Text(category.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            // Mô tả ngắn
            Text("\(todoCount) nhiệm vụ")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: isSelected ? category.displayColor.opacity(0.3) : Color.black.opacity(0.1),
                        radius: isSelected ? 8 : 4,
                        x: 0,
                        y: isSelected ? 4 : 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? category.displayColor : Color.clear, lineWidth: 2)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7))
    }
}

// Preview
struct CategoryCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CategoryCard(
                category: Category.sampleCategories[0],
                todoCount: 5,
                isSelected: false
            )
        
            CategoryCard(
                category: Category.sampleCategories[1],
                todoCount: 3,
                isSelected: true
            )
        }
        .padding()
    }
}
