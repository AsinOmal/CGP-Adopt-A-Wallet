# Adopt A Wallet

Adopt A Wallet is a Flutter finance app for tracking income and expenses, managing budgets, scheduling reminders, monitoring goals, and reviewing spending reports.

## Features

- Real-time income and expense tracking
- Budget planning and budget limit notifications
- Bill and loan reminders
- Financial goals with progress tracking
- Reports and analytics
- Sinhala and English language support
- Currency conversion
- Feedback, local notifications, QR payments, and card management

## Prerequisites

- Flutter 3.41.6 or newer
- Dart 3.11 or newer
- Android SDK 36
- Android emulator or physical Android device

## Setup

1. Install dependencies:

   ```bash
   flutter pub get
   ```

2. Create the ignored local email credentials file:

   ```bash
   cp lib/data/keys.example.dart lib/data/keys.dart
   ```

   Add real credentials in `lib/data/keys.dart` when email, OTP, or feedback sending needs to work:

   ```dart
   const String username = 'your-gmail-address';
   const String password = 'your-gmail-app-password';
   ```

   Empty values let the project compile, but email sending will fail until real credentials are supplied.

3. Start an Android emulator, then run:

   ```bash
   flutter run -d emulator-5554
   ```

   If your device id is different, list devices first:

   ```bash
   flutter devices
   flutter run -d <device-id>
   ```

## Android Notes

- The Android project targets `compileSdk 36`.
- The Gradle wrapper is `8.7`, Android Gradle Plugin is `8.6.0`, and Kotlin is `2.1.0`.
- A root Gradle compatibility hook supplies namespaces for older Flutter plugins that still declare only an Android manifest package.
