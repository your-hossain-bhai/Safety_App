# Human Safety App (SafeShake)

A **Flutter + Firebase** safety app that shows live location on Google Maps, warns if you enter predefined **danger zones**, and lets you **triple-shake** your phone to quickly open the dialer to call the nearest police station (via Google Places API). If no station is found, the app falls back to **999** (you can change this to your country’s emergency number).

---

## 🚀 Features
- Firebase **Email/Password Auth**
- **Google Maps** integration with live location
- **Danger Zone alerts** (radius detection + red/yellow circles)
- **Triple-shake gesture** within 1.5s → call nearest police
- **Manual emergency call button**
- Configurable fallback number (default: `999`)

---

## 🛠 Tech Stack
- Flutter (Dart)
- Firebase Auth
- Google Maps SDK for Android
- Places API (nearest police)

