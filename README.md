# Lib Folder Structure

This directory contains the core Dart and Flutter code for the **DevRumble** application.

## Directory Structure

```text
lib/
├── main.dart
├── navbar.dart
│
├── core/
│   └── utils/
│       └── .gitkeep
│
├── models/
│   └── .gitkeep
│
├── providers/
│   └── .gitkeep
│
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   │
│   ├── camera/
│   │   ├── analysis_result_screen.dart
│   │   ├── camera.dart
│   │   └── history.dart
│   │
│   ├── crop/
│   │   └── crop.dart
│   │
│   ├── home/
│   │   ├── home.dart
│   │   └── weather/
│   │       └── weather.dart
│   │
│   ├── market/
│   │   └── market.dart
│   │
│   └── profile/
│       └── profile.dart
│
├── services/
│   ├── MarketAPI.dart
│   ├── crop_service.dart
│   ├── image_service.dart
│   └── scan_service.dart
│
└── theme/
    └── app_theme.dart
```

## Project Overview

**DevRumble** is a Flutter-based agricultural application designed to provide farmers with useful tools and information in one platform.

The application includes:

* User authentication
* AI-powered crop scanning and analysis
* Crop scan history
* Real-time weather information
* Live agricultural market prices
* User profile management
* Firebase authentication and Firestore data storage
* Backend services powered by Django

## Key Components

### Screens

The `screens/` directory contains the main user-facing interfaces of the application.

* **Auth** — Handles user registration and login.
* **Home** — Provides the main dashboard with quick actions, weather information, and crop summaries.
* **Camera** — Handles crop image capture, AI analysis, analysis results, and scan history.
* **Crop** — Displays saved crop scans and detailed crop analysis.
* **Weather** — Displays real-time weather information.
* **Market** — Displays agricultural market prices.
* **Profile** — Handles user profile information and account-related functionality.

### Services

The `services/` directory contains the application's external integrations and data-handling logic.

* **MarketAPI.dart** — Fetches agricultural market price information from the Kalimati Market data source.
* **crop_service.dart** — Handles crop-related Firestore operations.
* **image_service.dart** — Handles image processing, resizing, compression, and Base64 conversion.
* **scan_service.dart** — Handles crop scan storage, retrieval, and analysis data through Firebase.

### Firebase

Firebase is used throughout the application for:

* User authentication
* Firestore database
* Crop scan storage
* User profile data
* Scan history

Crop scan records are associated with the authenticated user's Firebase UID, allowing users to access their own crop analysis history.

### Backend

The backend is developed using **Django** and provides the server-side functionality required by the application.

The Django backend is responsible for handling backend APIs and data processing that connects the Flutter frontend with external and application services.

## Team Contributions

The DevRumble project was developed collaboratively, with each team member responsible for a specific area of the application.

| Team Member          | Responsibility               |
| -------------------- | ---------------------------- |
| **Subin Tamang**     | Flutter Frontend Development |
| **Aayusha Shrestha** | Market API Development       |
| **Aasha Thapa**      | UI/UX Design                 |
| **Nishcal Bhujel**   | Django Backend Development   |

### Subin Tamang — Flutter Frontend

Responsible for the Flutter application and frontend implementation, including:

* Application structure
* Navigation
* Authentication screens
* Home dashboard
* Crop management interface
* Camera and crop scanning interface
* Weather interface
* Market interface integration
* Profile interface
* Firebase integration on the frontend
* Firestore data display
* Responsive and interactive UI implementation

### Aayusha Shrestha — Market API and Weather API

Responsible for the agricultural market API integration, including:

* Market data retrieval
* Kalimati Market data integration
* Market price API functionality
* Providing market data for the Flutter application

### Aasha Thapa — UI/UX Design

Responsible for the application's overall UI/UX design, including:

* Visual design
* User experience
* Screen layouts
* Color schemes
* Typography
* Component design
* User interaction flow
* Overall design consistency

### Nishcal Bhujel — Django Backend

Responsible for the Django backend, including:

* Backend architecture
* Django API development
* Server-side functionality
* API endpoints
* Backend data processing
* Communication between the frontend and backend services

## Technology Stack

### Frontend

* Flutter
* Dart
* Material Design
* Google Fonts

### Backend

* Django
* Django REST Framework

### Database & Authentication

* Firebase Authentication
* Cloud Firestore

### APIs & Services

* Market API
* Weather API
* AI Crop Analysis
* Django REST APIs

### Image Processing

* Dart image processing
* Base64 image conversion
* Image compression and resizing

## Development Notes

* Dart source files are maintained without inline comments where required by the project conventions.
* Firebase is used for authentication and Firestore-based application data.
* Crop scans are linked to individual Firebase users through their UID.
* Market information is retrieved through the market API developed by Aayusha Shrestha.
* The Flutter frontend is developed by Subin Tamang.
* The UI/UX design is created by Aasha Thapa.
* The Django backend is developed by Nishcal Bhujel.
* The project follows a modular structure separating screens, services, models, providers, utilities, and application themes.
