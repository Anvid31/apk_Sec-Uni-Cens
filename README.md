# Caracterización CENS — Flutter Mobile App

Mobile application for field survey and characterization of educational facilities, built for **CENS** (Centrales Eléctricas de Norte de Santander). Enables field staff to collect, photograph, and synchronize site data from remote locations.

## Features

- 📍 **Geolocation** — capture GPS coordinates per surveyed site
- 📸 **Image capture** — attach photos to survey records via camera or gallery
- 📶 **Offline-first** — local Hive database; syncs to PostgreSQL when connectivity is restored
- 📄 **PDF export** — generate and share field reports
- 🔔 **Notifications** — local reminders and sync status alerts

## Stack

- **Framework:** Flutter / Dart
- **State management:** Provider
- **Local storage:** Hive
- **HTTP client:** Dio
- **Remote database:** PostgreSQL
- **Other:** geolocator, image_picker, flutter_local_notifications, share_plus

## Getting started

```bash
flutter pub get
cp .env.example .env    # configure API endpoint and DB credentials
flutter run
```

To build the release APK: run `build_apk.bat` (Windows) or `flutter build apk --release`.