//
//  CustomNotificationCenter.swift
//  SwiftUINotificationCenter
//
//  Created by 許佳豪 on 2025/12/11.
//

import SwiftUI

// MARK: - Center

/// SwiftUI 版的輕量通知中心
///
/// 職責：
/// - 管理通知佇列（queue）
/// - 控制一次只顯示一則通知
/// - 等到「收起動畫」結束後，才顯示下一則
///
/// 不負責：
/// - 個別通知的動畫與手勢（由 `CustomNotificationDraggableView` 處理）
@MainActor
final class CustomNotificationCenter: ObservableObject {
    
    /// 全域共用的通知中心實例（Singleton）
    static let shared = CustomNotificationCenter()
    
    /// 目前正在畫面上顯示的通知
    /// - 為 `nil` 代表目前沒有任何通知顯示中
    @Published private(set) var current: CustomNotificationItem?
    
    /// 等待顯示中的通知佇列
    private var queue: [CustomNotificationItem] = []
    
    /// 是否有一則通知正在顯示中
    /// - 用來避免同時顯示多則通知
    private var isShowing = false
    
    /// 強制使用 Singleton，不對外開放 init
    private init() {}
}

// MARK: - Cancel API

extension CustomNotificationCenter {
    
    /// 只清掉「排隊中」的通知，讓目前這一則播完就結束
    /// - 例：畫面狀態改變時，不希望後面排隊的通知繼續被播放
    func cancelPending() {
        queue.removeAll()
    }
    
    /// 直接取消目前與後續所有通知
    /// - 不保證會有收起動畫，偏向「強制立即關閉」
    func cancelAll() {
        queue.removeAll()
        current = nil
        isShowing = false
    }
    
    /// 類方法版本：只清掉排隊中的通知
    static func cancelPending() {
        CustomNotificationCenter.shared.cancelPending()
    }
    
    /// 類方法版本：強制取消目前與後續所有通知
    static func cancelAll() {
        CustomNotificationCenter.shared.cancelAll()
    }
}

// MARK: - Public API

extension CustomNotificationCenter {
    
    /// 加入一則新的通知到佇列中，必要時觸發顯示流程（instance 版本）
    func show<Content: View>(
        duration: TimeInterval,
        delayForNext: TimeInterval = 0,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        let item = CustomNotificationItem(
            duration: duration,
            delayForNext: delayForNext,
            onTap: onTap,
            content: AnyView(content())
        )
        queue.append(item)
        processNextIfNeeded()
    }
    
    /// 類方法版本：方便直接呼叫，不需要先拿 `shared`
    ///
    /// ```swift
    /// CustomNotificationCenter.show(duration: 2) {
    ///     MyBannerView()
    /// }
    /// ```
    static func show<Content: View>(
        duration: TimeInterval,
        delayForNext: TimeInterval = 0,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        CustomNotificationCenter.shared.show(
            duration: duration,
            delayForNext: delayForNext,
            onTap: onTap,
            content: content
        )
    }
}

// MARK: - Queue 控制

extension CustomNotificationCenter {
    
    /// 檢查是否可以顯示下一則通知：
    /// - 沒有正在顯示中的通知（`!isShowing`）
    /// - `current == nil`
    /// - 佇列中有下一則可顯示
    private func processNextIfNeeded() {
        guard !isShowing, current == nil, let next = queue.first else { return }
        isShowing = true
        current = next
        // 之後的顯示／停留／收起動畫交給 `CustomNotificationDraggableView` 處理
    }
    
    /// 由通知 View 通知中心：「這一則通知的收起動畫已經完整結束」
    func notifyDismissCompleted() {
        // 先把 current 取出來存成 item，避免與屬性名稱混淆
        guard let item = current else { return }
        let delay = item.delayForNext
        
        // 清掉目前這一則的狀態
        self.current = nil
        isShowing = false
        
        Task { @MainActor in
            // 若有設定下一則的間隔時間，先等待
            if delay > 0 {
                try? await Task.sleep(
                    nanoseconds: UInt64(delay * 1_000_000_000)
                )
            }
            
            // 這一則播完，從佇列中移除
            if !queue.isEmpty {
                queue.removeFirst()
            }
            
            // 檢查是否還有下一則可以顯示
            self.processNextIfNeeded()
        }
    }
}
