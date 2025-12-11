//
//  CustomNotificationItem.swift
//  SwiftUINotificationCenter
//
//  Created by 許佳豪 on 2025/12/11.
//

import SwiftUI

/// 單一一則通知的資料結構
/// - 由 CustomNotificationCenter 管理的「排隊項目」
/// - 不負責動畫邏輯，只存狀態與要顯示的內容
struct CustomNotificationItem: Identifiable, Equatable {
    /// 唯一識別碼，讓 SwiftUI 可以正確追蹤這一則通知
    let id = UUID()
    
    /// 這一則通知要停留在畫面上的時間（秒）
    let duration: TimeInterval
    
    /// 這一則通知結束後，到下一則通知出現前需要等待多久（秒）
    let delayForNext: TimeInterval
    
    /// 使用者點擊這一則通知時要執行的動作（可以為 nil）
    let onTap: (() -> Void)?
    
    /// 要顯示在通知上的實際內容 View
    /// - 用 AnyView 包起來，方便用同一個型別存放各種客製 SwiftUI View
    let content: AnyView
    
    /// 只用 id 判斷是否為同一則通知
    static func == (lhs: CustomNotificationItem, rhs: CustomNotificationItem) -> Bool {
        lhs.id == rhs.id
    }
}
