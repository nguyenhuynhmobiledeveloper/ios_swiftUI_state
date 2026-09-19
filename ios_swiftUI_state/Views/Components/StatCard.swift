//
//  StatCard.swift
//  ios_swiftUI_state
//
//  Created by MobileDev on 14/9/26.
//

import SwiftUI

// REUSABLE COMPONENT: Card hiển thị thống kê với animation
// Không có state riêng, chỉ nhận props từ parent
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

struct StatCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            StatCard(
                title: "Total Tasks",
                value: "24",
                icon: "list.bullet",
                color: .blue
            )
        
            StatCard(
                title: "Completed",
                value: "18",
                icon: "checkmark.circle.fill",
                color: .green
            )
        
            StatCard(
                title: "Pending",
                value: "6",
                icon: "clock.fill",
                color: .orange
            )
        }
        .padding()
    }
}
