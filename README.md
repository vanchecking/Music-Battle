# 🎵 Music Battle – Guess Your Songs

An iOS music quiz game where users guess songs from short audio clips. Built with **UIKit** using **MVVM + Coordinator** architecture and **Apple Music (MusicKit)**.

The app is not only about guessing songs — it focuses on **competitive gameplay and music discovery**, helping users explore new and trending tracks in a fast and engaging way.

## 🎬 Demo

### 🔐 Login Flow
<img src="https://github.com/vanchecking/Music-Battle/releases/download/release/login.gif" width="300" />


### 🎮 Gameplay (5 Tint Mode)
<img src="https://github.com/vanchecking/Music-Battle/releases/download/release/5tint.gif" width="300" />


### 💰 History & Payment
<img src="https://github.com/vanchecking/Music-Battle/releases/download/release/historyandpayment.gif" width="300" />

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
- **ViewController** – handles user interaction and binds data to ViewModel  
- **ViewModel** – business logic and state management  
- **Services** – injected via initializers  
- **Coordinator** – navigation flow and screen transitions  
- Centralized error handling layer  

The architecture follows **SOLID principles**, focusing on modularity and testability.

---

## 🎮 Key Features

- Multiple game modes:
  - Trending tracks  
  - TikTok-style popular songs  
  - Hits  
  - Artist-based selection  

- Artist mode with dynamic flow (artist → albums → tracks)  
- Apple Music-based quiz gameplay  
- Competitive scoring system  
- Adaptive AI opponent difficulty  
- Results + progress tracking  
- Open track in Apple Music  
- Combine-based reactive UI  
- Performance caching layer  
- Monetization (AdMob + subscriptions)  
- Analytics (Amplitude + AppsFlyer)  
- Firebase + CloudKit integration  
