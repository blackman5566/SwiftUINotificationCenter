//
//  CustomNotificationDraggableView.swift
//  SwiftUINotificationCenter
//
//  Created by 許佳豪 on 2025/12/11.
//

import SwiftUI

/// 單一一則通知的顯示 View
/// - 負責：
///   1. 從畫面上方掉下來的進場動畫
///   2. 停留指定秒數後，自動往上滑出去＋淡出
///   3. 處理使用者點擊與上滑手勢
/// - 不負責排隊邏輯，由 CustomNotificationCenter 管理顯示順序
struct CustomNotificationDraggableView: View {
    
    /// 要顯示的通知內容與設定（停留時間、點擊 callback…）
    let item: CustomNotificationItem
    
    /// 通知完整「收起動畫」結束後呼叫
    /// - 通常用來通知 CustomNotificationCenter：「這一則播完，可以輪到下一則」
    let onCompleted: () -> Void
    
    /// 使用者點擊通知時要執行的動作（可以為 nil）
    let onTap: (() -> Void)?
    
    /// 垂直位移（Y 軸），用來控制從上方掉下來、滑回上方的動畫
    @State private var offsetY: CGFloat = 0
    
    /// 通知 View 的實際高度，會在 onAppear 時由 GeometryReader 測量
    @State private var height: CGFloat = 0
    
    /// 控制自動消失計時的 Task（方便在點擊／拖曳時取消）
    @State private var autoTask: Task<Void, Never>?
    
    /// 透明度，用來做淡入／淡出效果
    @State private var opacity: Double = 1
    
    var body: some View {
        item.content
            // 讓外部傳入的 View 可以套用淡入／淡出
            .opacity(opacity)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            // 取得實際高度，方便計算從畫面外「完全隱藏」的位置
                            height = geo.size.height
                            
                            // 初始：視圖放在上方（看不到）
                            offsetY = -height
                            
                            // 進場動畫：從上掉到 0（貼齊螢幕頂端）
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                                offsetY = 0
                            }
                            
                            // 開始計時，準備之後自動收起
                            startAutoDismiss()
                        }
                        // 高度改變時（例如動態內容），同步更新 height
                        .onChange(of: geo.size.height) { _, newValue in
                            height = newValue
                        }
                }
            )
            // 套用垂直位移，配合 offsetY 做上下移動的動畫
            .offset(y: offsetY)
            // 上滑手勢：可以把通知往上拖走
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let translation = value.translation.height
                        // 只允許「往上」拖（負值），往下則限制在 0（不讓使用者把通知往下拉出畫面）
                        offsetY = min(0, translation)
                    }
                    .onEnded { value in
                        let final = min(0, value.translation.height)
                        // 拖動超過自身高度的 1/3，就視為要收起通知
                        let threshold = -height / 3.0
                        
                        if final <= threshold {
                            // 超過 1/3 高度 → 執行收起動畫
                            animateDismiss()
                        } else {
                            // 不到門檻 → 彈回原位
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                                offsetY = 0
                            }
                        }
                    }
            )
            // 點擊通知
            .onTapGesture {
                // 先停止自動消失的計時
                autoTask?.cancel()
                // 呼叫使用者自訂的 onTap 動作（如果有）
                onTap?()
                // 點擊後一併收起通知（滑回上方＋淡出）
                animateDismiss()
            }
            // 當 View 被移除（例如 current = nil）時，確保 Task 一併取消，避免掉在背景
            .onDisappear {
                autoTask?.cancel()
            }
    }
    
    /// 開始自動消失計時：停留 item.duration 秒後自動執行收起動畫
    private func startAutoDismiss() {
        autoTask?.cancel()
        autoTask = Task {
            // 等待指定秒數
            try? await Task.sleep(nanoseconds: UInt64(item.duration * 1_000_000_000))
            // 回到主執行緒，做 UI 動畫
            await MainActor.run {
                animateDismiss()
            }
        }
    }
    
    /// 從目前位置滑回上方並淡出，動畫完成後通知 Center
    private func animateDismiss() {
        // 先停止任何正在跑的自動計時
        autoTask?.cancel()
        
        // 若高度異常（尚未量到），就直接結束 callback
        guard height > 0 else {
            onCompleted()
            return
        }
        
        // 用彈性動畫，讓通知往上滑回畫面外，並同時淡出
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            offsetY = -height
            opacity = 0
        }
        
        // 等動畫跑完一小段時間後，再通知外部「這一則真的結束了」
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            onCompleted()
        }
    }
}
