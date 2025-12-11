# SwiftUINotificationCenter  
### A Modular, Queue-Driven, Draggable Notification System for SwiftUI

SwiftUI 雖然提供了基本的提示元件，但如果要支援  
**佇列排程、可拖曳手勢、動畫可控的通知樣式**，仍需要自行設計完整架構。

基於這個需求，我將過去在 UIKit 時期使用過的通知元件重新整理與抽象化，  
並以 SwiftUI 宣告式風格重新打造，形成這套  
**乾淨、模組化、可長期維護的 Notification 系統**。

這個元件不只是做出「通知會掉下來」的效果，而是：

> **把零散的功能收斂成穩定、可預測、可測試、可長期維護的系統。**

---

## ✨ Demo  
（你未來可放 GIF 或影片）

```
[ Notification dropping down ]
[ Swipe to dismiss ]
[ Queue showing next item ]
```

<p align="center">
  <img 
    src="https://github.com/blackman5566/SwiftUINotificationCenter/blob/main/demo.gif" 
    alt="Notification Demo" 
    width="320"
  />
</p>

---

## 🔥 Features

### ✔ Queue-based Notification Management（排隊顯示）
一次只會顯示一則通知，其餘自動排隊。  
避免動畫重疊、狀態錯亂，適合中大型 App。

### ✔ Draggable + Animated（可拖曳與動態收合）
支援手勢上滑移除、彈性動畫、淡入淡出。  
所有動畫行為完全封裝在 `CustomNotificationDraggableView`。

### ✔ Independent Lifecycle（可控生命週期）
每則通知都有獨立 Task：  
- 停留時間  
- 點擊後立即消失  
- 手勢取消自動計時  
- 收合動畫完成才繼續下一則  

生命週期明確、可預測。

### ✔ Zero-Intrusion Host Overlay（不入侵既有畫面）
只要在 App 根節點掛上 `.withDaiNotification()`  
通知就會以 overlay 形式加在所有畫面最上層。

完全不需要改動現有頁面。

### ✔ Clean, Extensible Architecture（乾淨的架構設計）
資料（Item）、動畫（DraggableView）、排程（Center）、掛載（Host）  
全部分離，便於維護與擴充。

---

## 🚀 Quick Start

### 1. 啟用 Notification Host

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .withDaiNotification()
        }
    }
}
```

### 2. 顯示一則通知

```swift
CustomNotificationCenter.show(duration: 2) {
    HStack {
        Image(systemName: "bell.fill")
            .foregroundColor(.white)
        Text("Saved successfully!")
            .foregroundColor(.white)
    }
    .padding()
    .background(Color.blue)
    .cornerRadius(12)
}
```

### 3. 支援點擊、延遲、排隊控制

```swift
CustomNotificationCenter.show(
    duration: 2,
    delayForNext: 0.3,
    onTap: { print("Tapped!") }
) {
    MyCustomBannerView()
}
```

---

## 🧩 Architecture Overview

```
RootView
 └── withDaiNotification()
       └── CustomNotificationHost
             └── CustomNotificationDraggableView
                   └── CustomNotificationItem
             └── CustomNotificationCenter (queue manager)
```

### 分工清楚、責任邊界明確

| 元件 | 負責 | 不負責 |
|-----|------|---------|
| **CustomNotificationCenter** | 佇列管理、生命週期、排程 | UI、動畫、手勢 |
| **CustomNotificationDraggableView** | 動畫、手勢、上滑收合 | 佇列與資料管理 |
| **CustomNotificationHost** | 疊加於最上層、顯示時機 | 內容動畫 |
| **CustomNotificationItem** | 承載資料、唯一識別 | 動畫、邏輯 |

---

## 🧠 Engineering Philosophy  

這個作品背後真正的重點不是動畫本身，而是：

### ✔ 把功能系統化  
### ✔ 把 UI／資料／控制流 解耦  
### ✔ 讓元件可控、可測、可預測  
### ✔ 避免後期專案失控  

> **工程師的價值不只是“寫得出功能”，而是能建立穩定可維護的系統。**

---

## 🔧 Future Extensions

這套架構已為以下功能預留 extension hooks：

- Lottie / Rive 動畫樣式  
- Success / Warning / Error 預設模板  
- Bottom / Center / Top 多位置支援  
- Custom Transition  
- Queue priority（高優先權通知）  
- Async/await show APIs  
- Persistent（可常駐）樣式  

---

## 📄 License  
MIT License

歡迎自由使用、修改、擴充。
