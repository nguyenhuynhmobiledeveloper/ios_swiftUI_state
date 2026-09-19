//
//  PriorityBadge.swift
//  ios_swiftUI_state
//
//  Created by MobileDev on 14/9/26.
//

import SwiftUI

// REUSABLE COMPONENT: Badge hiển thị priority của todo
// Không có state management vì chỉ nhận props và hiển thị
struct PriorityBadge: View {
    let priority: Priority
    let showIcon: Bool
    
    init(priority: Priority, showIcon: Bool = true) {
        self.priority = priority
        self.showIcon = showIcon
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if showIcon {
                Image(systemName: priority.icon)
                    .font(.system(size: 11))
            }
            
            Text(priority.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(priority.color)
        .cornerRadius(8)
    }
}

struct PriorityBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            PriorityBadge(priority: .high)
            PriorityBadge(priority: .medium)
            PriorityBadge(priority: .low)
            PriorityBadge(priority: .high, showIcon: false)
        }
        .padding()
    }
}
