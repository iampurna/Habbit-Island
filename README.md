# habbit_island

Habit Island is a cross-platform, gamified habit tracker built with Flutter, designed to help users build consistency through calm, visual progress instead of pressure or social competition.

By completing daily habits, users grow a beautiful virtual island. When habits are missed, the island gently reflects that through weather and decay — encouraging recovery, not guilt.

✨ Core Philosophy-
Simple habit tracking paired with meaningful visual rewards
Solo-focused experience — no leaderboards, no social pressure
Visual consequences without punishment
Calm, aesthetic-first design that encourages consistency

🚀 Features (MVP)-
Habit Management
Create, edit, and delete habits
Four core habit types:
💧 Water
🏃 Exercise
📖 Reading
🧘 Meditation
Flexible schedules: daily, specific days, or times per week
Optional reminders
One-tap completion with animations
Streak tracking and history calendar

Island Growth System-
Each habit appears as a physical object on the island
Habit streaks visually upgrade objects (growth levels)
Missed habits trigger gentle decay (clouds, storms, wilting)
Recovery is always possible through continued completion

Weather System-
Island-wide weather reflects overall habit completion
Conditions range from sunny and rainbow-filled to stormy

Progression & Rewards-
XP-based leveling system
Daily login rewards
Streak milestones (7-day, 30-day bonuses)
💰 Monetization-
Free Tier
Up to 7 active habits
Full island growth system
Rewarded ads (optional) for bonus XP
Premium
Unlimited habits
No ads
Streak protection (shields)
Vacation mode
Advanced insights & analytics
Custom themes and icons
Multiple islands

🧠 Tech Stack-
Frontend
Flutter (iOS & Android)
BLoC for state management
Flame Engine for island rendering, animations, and particles
Hive for offline-first local storage
Backend & Services
Supabase (PostgreSQL + Auth + Cloud Sync)
Firebase Analytics & Crashlytics
OneSignal for push notifications
AdMob (rewarded ads only)
RevenueCat for subscriptions

🏗 Architecture Overview-
Local-first design: instant UI updates, background sync
Offline support with conflict resolution
Server as source of truth
Streaks are always recalculated from completion history
Clear separation between Flutter UI logic and Flame game rendering

🎨 Design System-
Soft pastel color palette
Accessible contrast (WCAG AA)
Nunito & Inter typography
Motion-reduced mode supported
Self-designed pixel and isometric assets
Designs are created in Figma with a component-first approach and handed off directly to Flutter.

🗺 Development Timeline-
90-day MVP roadmap
Parallel design and development
Iterative delivery with early beta testing

📱 Platform Support-
iOS 15+
Android (API 23+)
🔐 Security & Privacy
No social data sharing
User data protected via Row-Level Security
Optional analytics
No forced ads

🧪 Status-
🚧 Active Development (MVP)
This project is currently under active development as an indie-built product.

📄 License-
This project is currently proprietary. Licensing details will be added before public release.

🌱 Vision-
Habit Island aims to make habit-building feel calm, rewarding, and human — turning consistency into something you can see, not just count.
Grow your habits. Grow your island.

## Getting Started

# Flutter

A modern Flutter-based mobile application utilizing the latest mobile development technologies and tools for building responsive cross-platform applications.

## 📋 Prerequisites

- Flutter SDK (^3.38.4)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android SDK / Xcode (for iOS development)

## 🛠️ Installation

1. Install dependencies:

```bash
flutter pub get
```

2. Run the application:
