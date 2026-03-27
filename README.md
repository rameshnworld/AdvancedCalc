# Advanced Calculator

A feature-rich calculator app built with Flutter.

## Features
- **Basic Calculator** - Standard arithmetic operations
- **Scientific Calculator** - sin, cos, tan, log, ln, sqrt, power with DEG/RAD toggle
- **Unit Converter** - Length, Weight, Temperature
- **Currency Converter** - 15+ currencies with real exchange rates
- **Price Calculator** - Weight-based price calculator (e.g., 50kg = ₹1400 → price per gram/100g/kg)
- **History** - Saves last 100 calculations
- **Themes** - 6 accent colors + Light/Dark/System mode
- **Animations** - Smooth button press and transition animations

## Build APK via GitHub Actions

1. Fork or push this code to a GitHub repository
2. Go to **Actions** tab in your repository
3. Click **"Build APK"** workflow → **"Run workflow"**
4. Wait ~5 minutes for the build to complete
5. Download the APK from **Artifacts** section

## Local Development

```bash
flutter pub get
flutter run         # Debug on connected device
flutter build apk   # Release APK
```

## Requirements
- Flutter 3.22+
- Android SDK (minSdk 21)
- Java 17
