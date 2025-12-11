//
//  ContentView.swift
//  SwiftUINotificationCenter
//
//  Created by 許佳豪 on 2025/12/11.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        VStack(spacing: 24) {
            Button("Show Basic Notification") {
                CustomNotificationCenter.show(
                    duration: 2.0,
                    delayForNext: 0.5
                ) {
                    basicBanner(message: "Hello from DaiNotification SwiftUI!")
                }
            }
            
            Button("Show Clickable Notification") {
                CustomNotificationCenter.show(
                    duration: 3.0,
                    delayForNext: 0.5,
                    onTap: {
                        print("User tapped notification")
                    },
                    content: {
                        clickableBanner(title: "Tapped Banner",
                                        message: "Tap me to trigger callback.")
                    }
                )
            }
            
            Button("Show Multiple (Queue)") {
                for index in 1...6 {
                    CustomNotificationCenter.show(
                        duration: 1.5,
                        delayForNext: 0.3
                    ) {
                        basicBanner(message: "Notification #\(index)")
                    }
                }
            }
        }
        .padding()
    }
    
    // MARK: - Example custom UIs
    
    func basicBanner(message: String) -> some View {
        Text(message)
            .font(.system(.subheadline, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.blue.gradient)
            )
            .shadow(radius: 18)
            .padding(.horizontal, 16)
    }
    
    func clickableBanner(title: String, message: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "bell.badge.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 20))
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundColor(.white)
                Text(message)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.85))
        )
        .shadow(radius: 20)
        .padding(.horizontal, 16)
    }
}


#Preview {
    ContentView()
}
