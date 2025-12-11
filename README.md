<div align="left">
  <a href="README_CN.md"><img alt="中文" src="https://img.shields.io/badge/Documentation-中文-blue"></a>
</div>


# SwiftUINotificationCenter  
### A Modular, Queue-Driven, Draggable Notification System for SwiftUI

SwiftUI provides basic alert and toast components, but when you need  
**queued scheduling, draggable interactions, and fully controllable animations**,  
a more complete architecture is required.

Based on this need, I refactored and abstracted a notification component I used in UIKit,  
and rebuilt it using a SwiftUI-friendly, declarative design — resulting in a  
**clean, modular, and maintainable Notification system**.

This component is not just a “banner that drops down.”  
It is a system designed to be **predictable, testable, and scalable**.

> **The goal is not just to “make a feature,” but to build a stable system that can scale with real products.**

---

## Demo  
(You may replace this with your own GIF)

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

## Features

### ✔ Queue-based Notification Management
Only one notification is shown at a time; others wait in a queue.  
Prevents animation overlap and inconsistent UI states — ideal for production apps.

### ✔ Draggable + Interactive Animations
Supports upward swipe-to-dismiss, smooth spring animations, and fade transitions.  
All animation logic is encapsulated in `CustomNotificationDraggableView`.

### ✔ Independent Lifecycle Control
Each notification manages its own Task:

- Display duration  
- Tap to dismiss  
- Cancel auto-dismiss on interaction  
- Trigger next item only after animation completes  

Clear lifecycle → predictable behavior.

### ✔ Zero‑Intrusion Host Overlay
Attach `.withDaiNotification()` at the App root,  
and the system automatically overlays notifications on every screen.

Zero modification to existing code.

### ✔ Clean, Extensible Architecture
Responsibilities are separated clearly across Item, Center, Host, and Draggable View.  
Easy to maintain and extend.

---

## Quick Start

### 1. Enable Notification Host

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

### 2. Show a Notification

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

### 3. Support Tap, Delay, Queue Control

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

## Architecture Overview

```
RootView
 └── withDaiNotification()
       └── CustomNotificationHost
             └── CustomNotificationDraggableView
                   └── CustomNotificationItem
             └── CustomNotificationCenter (queue manager)
```

### Responsibility Breakdown

| Component | Responsibilities | Not Responsible For |
|----------|------------------|---------------------|
| **CustomNotificationCenter** | Queue, lifecycle, scheduling | UI / animation / gestures |
| **CustomNotificationDraggableView** | Animations, drag gestures, dismissing | Queue logic |
| **CustomNotificationHost** | Overlay mounting, display timing | Animation content |
| **CustomNotificationItem** | Data model, identity | Logic, animation |

---

## Engineering Philosophy  

The real focus of this project is not the animation —  
it's the **architecture** behind it.

### ✔ Turning small features into a scalable system  
### ✔ Decoupling UI / data / control flow  
### ✔ Ensuring predictable and testable behavior  
### ✔ Preventing long‑term project complexity  

> **A good engineer doesn't just ship features — they build systems that last.**

---

## 🔧 Future Extensions

Built with extensibility in mind:

- Lottie / Rive animation support  
- Predefined templates (Success / Warning / Error)  
- Top / Center / Bottom positioning  
- Custom transitions  
- Queue priority  
- Async/await show API  
- Persistent (non‑auto‑dismiss) banners  

---

## 📄 License  
MIT License — Free to use, modify, and extend.
