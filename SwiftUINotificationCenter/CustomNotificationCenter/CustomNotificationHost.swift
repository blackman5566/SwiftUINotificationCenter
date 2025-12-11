//
//  CustomNotificationDraggableView.swift
//  SwiftUINotificationCenter
//
//  Created by 許佳豪 on 2025/12/11.
//

import SwiftUI

/// 將 CustomNotification 疊加在整個 App 視圖層級最上方的 ViewModifier
/// - 使用方式：在最外層 View 呼叫 `.withDaiNotification()`
/// - 當 CustomNotificationCenter.current 有值時，就顯示一個可拖曳的通知視圖
struct CustomNotificationHost: ViewModifier {
    
    /// 全域共用的通知中心
    /// - 用 @StateObject 持有，確保生命週期與畫面綁在一起
    @StateObject private var center = CustomNotificationCenter.shared
    
    func body(content: Content) -> some View {
        ZStack {
            // 原本的畫面內容
            content
            
            // 如果目前有要顯示的通知，就疊一層在上面
            if let item = center.current {
                VStack {
                    CustomNotificationDraggableView(
                        item: item,
                        onCompleted: {
                            // 整個「往上滑出去 + 淡出」動畫結束後，
                            // 通知 Center：這則結束，可以準備顯示下一則
                            center.notifyDismissCompleted()
                        },
                        onTap: item.onTap
                    )
                    // 這裡只負責淡入 / 淡出效果
                    // 垂直滑入 / 滑出的動畫則由 CustomNotificationDraggableView 自己處理
                    .transition(.opacity)
                    
                    Spacer()
                }
                // 確保通知永遠顯示在最上層（避免被其他內容蓋掉）
                .zIndex(999)
            }
        }
        // 將通知中心注入 Environment，方便其他地方需要時也能取得
        .environmentObject(center)
    }
}

extension View {
    
    /// 在整個 View 樹上啟用 DaiNotification 功能
    /// - 建議掛在 App 入口，例如：
    ///   `WindowGroup { RootView().withDaiNotification() }`
    func withDaiNotification() -> some View {
        self.modifier(CustomNotificationHost())
    }
}
