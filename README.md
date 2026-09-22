# PadelPro — Mobile Booking App

> **Frontend only.** This repository contains the Flutter mobile application (Android & iOS).
> The backend (PHP CodeIgniter 4 REST API) is maintained separately.
> To request backend access or collaboration, contact us below.

---

## Overview

PadelPro is a cross-platform mobile application for booking padel sports courts.
Users can browse available venues, make bookings, process payments via QRIS, and track their booking history — all from a single app.

Built with **Flutter (Dart)** as the frontend, consuming a **PHP CodeIgniter 4** REST API backend.

---

## Features

- Splash screen & onboarding flow
- User authentication (Register / Login)
- Venue exploration & detail view
- Court booking with date and time selection
- QRIS payment screen
- Booking history & order detail
- User profile management & edit profile
- Notification screen

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Dart |
| Framework | Flutter 3.x |
| HTTP Client | Dio 5.x |
| Local Storage | shared_preferences |
| Fonts | Google Fonts |
| Icons | flutter_svg |
| Image | image_picker |
| Backend | PHP CodeIgniter 4 REST API *(separate repo)* |

---

## Project Structure

```
lib/
├── config/
│   └── api_config.dart       # Base URL configuration
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── main_screen.dart
│   ├── dashboard_screen.dart
│   ├── explore_screen.dart
│   ├── venue_detail_screen.dart
│   ├── booking_screen.dart
│   ├── payment_screen.dart
│   ├── qris_screen.dart
│   ├── success_screen.dart
│   ├── order_detail_screen.dart
│   ├── history_screen.dart
│   ├── notification_screen.dart
│   ├── profile_screen.dart
│   └── edit_profile_screen.dart
├── services/
│   └── auth_service.dart     # Authentication API calls
└── main.dart
```

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.10.7`
- Dart SDK
- Android Studio / VS Code with Flutter extension
- A running instance of the PadelPro backend API

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/OnlyFiksa/frontend_padel_app.git
cd frontend_padel_app

# 2. Install dependencies
flutter pub get

# 3. Configure the API base URL
#    Open lib/config/api_config.dart
#    Replace the baseUrl with your backend server's IP/URL

# 4. Run the app
flutter run
```

### API Configuration

Open `lib/config/api_config.dart` and set your backend URL:

```dart
class ApiConfig {
  static const String baseUrl = 'http://YOUR_BACKEND_IP/api';
}
```

> **Note:** If running on a physical device, use your machine's local IPv4 address (not `localhost`).

---

## Backend

This repository is the **frontend only**.

The backend (PHP CodeIgniter 4 REST API) handles:
- Authentication & session management
- Venue and court data
- Booking logic and availability
- Payment processing
- User management

For backend access, source code, or collaboration inquiries, please contact the team below.

---

## Authors

| Name | Role | GitHub |
|---|---|---|
| Putra Fajar Indra Setiawan | Frontend (Flutter) | [@Patra-fjr](https://github.com/Patra-fjr) |
| OnlyFiksa | Backend (CodeIgniter 4) & Project Lead | [@OnlyFiksa](https://github.com/OnlyFiksa) |

---

## Contact

Have questions, want to collaborate, or need backend access?

- **Putra Fajar** — [putrafajarindrasetiawan@gmail.com](mailto:putrafajarindrasetiawan@gmail.com) · [LinkedIn](https://linkedin.com/in/putra-fajar-indra-setiawan)
- **GitHub Issues** — open an issue on this repo

---

## License

This project was developed as part of an academic assignment at **CEP-CCIT FTUI, Universitas Indonesia** (Semester 4, 2026).
Not licensed for commercial use without permission from the authors.
