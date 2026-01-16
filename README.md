# Inventory Management App (Flutter)

A fully offline **Inventory Management Android application** built using **Flutter** as part of the AlgoBotix Flutter Developer machine test.

The app enables users to manage products with local persistence, stock tracking, image handling, and QR-based product identification.

---

## ✨ Features

### ✅ Core Features
- Add, view, edit, and delete products
- Unique **Product ID** (exactly 5 alphanumeric characters)
- Product attributes: name, description, stock
- Image selection via **Camera or Gallery**
- Stock increment and decrement (never below zero)
- Search products by Product ID
- Persistent local storage using **SQLite**
- Offline-first design (no internet required)

### ⭐ Bonus Features
- **Stock History Tracking** with timestamps
- **QR Code Scan** to directly open product details
- Clean and responsive UI with proper navigation handling

---

## 📱 Screens
- Home Screen (Product List & Search)
- Add Product
- Product Detail
- Edit Product
- Stock History
- QR Code Scanner

---

## 🛠️ Tech Stack
- **Framework:** Flutter
- **Language:** Dart
- **Database:** SQLite (sqflite)
- **State Management:** Stateful Widgets
- **QR Scanner:** mobile_scanner
- **Image Picker:** image_picker

---

## 📦 Packages Used

| Package | Purpose |
|------|--------|
| sqflite | Local SQLite database |
| path_provider | Database file storage |
| image_picker | Camera & gallery image selection |
| mobile_scanner | QR code scanning |
| intl | Date & time formatting |

---

## 🔐 Permissions
- Camera (QR scanning & image capture)
- Media / Storage (image selection)

Permissions are requested at runtime and handled safely.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (stable)
- Android Studio / VS Code
- Android device or emulator

### Run Locally
```bash
flutter pub get
flutter run
