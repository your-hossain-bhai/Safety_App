🚨 SafeShake – Human Safety App

SafeShake is a Flutter + Firebase powered safety app designed to protect you in emergencies.
It tracks your live location on Google Maps, alerts you when you enter predefined danger zones, and lets you triple-shake your phone to quickly call the nearest police station (via Google Places API). If no station is found, it falls back to 999 (you can change this to your country’s emergency number).

✨ Features

✅ Authentication

🔑 Login with Firebase Email/Password

📝 Signup for new users

🚪 Easy logout

✅ Safety Tools

🗺 Google Maps integration with real-time location tracking

⚠️ Danger Zone alerts (colored circles → red = high risk, yellow = moderate risk)

📳 Triple-shake gesture (within 1.5s) → instantly call nearest police station

☎️ Manual "Call Police" button for emergencies

🔄 Fallback number (default = 999, configurable)

🛠 Tech Stack

Flutter (Dart)

Firebase Auth (Login/Signup/Logout)

Google Maps SDK for Android

Geolocator (GPS tracking)

Sensors Plus (shake detection)

Google Places API (nearest police station lookup)

📸 Suggested Screenshots

Login screen with SafeShake logo

Signup screen

Home screen with live Google Map

Danger Zone alert view

Emergency Call button
