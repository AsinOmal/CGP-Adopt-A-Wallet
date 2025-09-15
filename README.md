# Adopt A Wallet – Financial Manager App

[![Flutter](https://img.shields.io/badge/Flutter-3.0-blue?logo=flutter\&logoColor=white)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-orange?logo=firebase\&logoColor=white)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

The **Financial Manager App** helps students and individuals manage their money effectively. It provides real-time expense tracking, budget planning, bill reminders, financial goals, reports, and multi-language support.

This project was developed as part of a Module called **"Computing Group Project"** at the University.

---

## 📦 Features

* **Real-time Expense Tracking** – Add, update, and categorize income/expenses instantly
* **Budget Management** – Set monthly budgets and receive alerts when nearing limits
* **Bill & Loan Reminders** – Get notified about due payments
* **Financial Goals** – Track savings or target-based goals
* **Detailed Reports** – Visual charts and spending summaries
* **Multi-language Support** – Available in **Sinhala** and **English**
* **Secure Data** – Encrypted storage using Firebase Authentication & Firestore
* **Currency Converter** – Real-time exchange rates
* **Split-Budget Management** - Split budgets among your friends, roommates, colleagues

---

## 🛠️ Getting Started

### ✅ Prerequisites

* Install **Flutter SDK**: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
* Install **Dart SDK** (comes with Flutter)
* Install an IDE (VS Code / Android Studio recommended)
* Setup an **Android/iOS emulator** or connect a physical device

### 🚀 Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/AsinOmal/CGP-Adopt-A-Wallet.git
   cd CGP-Adopt-A-Wallet
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**

   * Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   * Add Android/iOS app configurations
   * Download `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) and place them in the appropriate directories
   * Enable **Firestore**, **Authentication**, and **Realtime Database**

4. **Run the app:**

   ```bash
   flutter run
   ```

---

## 🧩 Project Structure

```
CGP-Adopt-A-Wallet/
├── lib/
│   ├── models/        # Data models (transactions, goals, budgets)
│   ├── screens/       # UI screens
│   ├── widgets/       # Reusable UI components
│   ├── services/      # Firebase and API integrations
│   └── main.dart      # App entry point
├── android/           # Android-specific code
├── ios/               # iOS-specific code
├── assets/            # Images, icons, translations
├── pubspec.yaml       # Dependencies and assets config
└── README.md          # Documentation
```

---

## 🔑 Environment Variables

You’ll need Firebase configuration files to run the app:

* **Android** → `android/app/google-services.json`
* **iOS** → `ios/Runner/GoogleService-Info.plist`

Additionally:

* Currency converter uses a public API (can integrate [ExchangeRate API](https://exchangerate.host/) or similar).

---

## 🚀 Deployment

To build the app for production:

**Android APK:**

```bash
flutter build apk --release
```

**iOS:**

```bash
flutter build ios --release
```

Upload the generated build files to the Google Play Store or the Apple App Store.

---

## 🤝 Contributing

Contributions are welcome!

1. Fork the repository
2. Create a new branch (`git checkout -b feature-name`)
3. Commit changes (`git commit -m "Added feature"`)
4. Push the branch (`git push origin feature-name`)
5. Open a Pull Request

---

## 📜 License

This project is licensed under the MIT License.

---

## 🙌 Acknowledgements

* Special thanks to [**Udara Wickramaratne**](http://github.com/UdaraWickramarathne) for guidance and support
* Team Members of **Computing Group Project**
* [Flutter](https://flutter.dev/)
* [Firebase](https://firebase.google.com/)
* [ExchangeRate API](https://exchangerate.host/)





