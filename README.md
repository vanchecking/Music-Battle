# 🎵 Music Battle – Guess Your Songs

An iOS music quiz game where users guess songs from short audio clips. Built with **UIKit** using **MVVM + Coordinator** architecture and **Apple Music (MusicKit)**.

The app is not only about guessing songs — it focuses on **competitive gameplay and music discovery**, helping users explore new and trending tracks in a fast and engaging way.

---

## 🚀 Tech Stack

- UIKit / SwiftUI  
- MVVM + Coordinator architecture  
- Dependency Injection (initializer-based)  
- Combine  
- SnapKit  
- MusicKit (Apple Music integration)  
- Firebase  
- CloudKit  
- AdMob (monetization)  
- Adapty (subscriptions & IAP)  
- Amplitude (analytics)  
- AppsFlyer  
- URLSession  
- StoreKit  
- NSCache / custom caching layer  
- SwiftLint  
- Lottie  

---

## 🧠 Architecture

The app follows a pragmatic **MVVM + Coordinator** architecture designed for real-world UIKit constraints.

- **View (UIView)** – UI layout and rendering only  
- **ViewController** – handles user interaction and binds data to ViewModel (manual binding + Combine where appropriate)  
- **ViewModel** – business logic and state management  
- **Services** – injected via initializers (explicit dependencies, testable design)  
- **Coordinator** – navigation flow and screen transitions  
- Centralized error handling layer for consistent UX  

The architecture follows **SOLID principles**, focusing on modularity, low coupling, and testability through protocol-based abstractions and dependency injection.

---

## 🎮 Key Features

- Multiple game modes:
  - Trending tracks  
  - TikTok-style popular songs  
  - Hits  
  - Artist-based selection  

- Artist mode with dynamic flow:
  - Artist → albums → randomly selected tracks for gameplay variety  

- Music quiz gameplay based on short Apple Music clips  
- Competitive game loop with scoring system  
- Adaptive AI opponent that adjusts difficulty based on player performance  
- Rating system updated after each session  
- Results screen with progress tracking  
- Open tracks in Apple Music + add to library  
- Reactive UI updates using Combine  
- Caching layer for performance optimization  
- Monetization via AdMob + Adapty subscriptions  
- Analytics with Amplitude + AppsFlyer  
- Firebase + CloudKit for data storage  

---

## ⚙️ Core Responsibilities

- Built production iOS features using UIKit and SwiftUI  
- Designed scalable architecture using MVVM + Coordinator  
- Integrated Apple Music (MusicKit) for audio playback  
- Implemented adaptive gameplay systems (AI difficulty scaling)  
- Managed complex async flows using Combine  
- Built caching strategies to reduce network usage  
- Integrated multiple third-party services (Firebase, AdMob, Adapty, etc.)  
- Improved performance through optimization and refactoring  
- Implemented centralized error handling system  
- Worked with both cloud and local storage solutions  
- Supported release cycle via TestFlight & App Store builds  