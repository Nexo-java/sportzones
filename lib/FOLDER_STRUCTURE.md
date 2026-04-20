# SportZones - Folder Structure Documentation

This document explains the project folder structure and organization.

## 📂 Project Structure

```
lib/
├── core/                          # Core app-wide configurations
│   ├── constants/                 # App constants
│   │   ├── app_colors.dart       # Color palette
│   │   ├── app_strings.dart      # Text constants
│   │   └── app_routes.dart       # Route names
│   │
│   └── utils/                     # Utility functions
│       └── validators.dart       # Form validators
│
├── features/                      # Feature-based architecture
│   └── authentication/            # Authentication feature
│       ├── screens/               # Auth screens
│       │   ├── splash_screen.dart
│       │   ├── logo_animation_screen.dart
│       │   └── login_screen.dart
│       │
│       └── models/                # Auth data models
│           ├── user_model.dart
│           └── auth_response.dart
│
├── shared/                        # Shared/reusable components
│   ├── widgets/                   # Common widgets
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── loading_indicator.dart
│   │   └── empty_state.dart
│   │
│   └── models/                    # Shared models
│       └── base_response.dart
│
├── config/                        # App configuration
│   └── routes.dart               # Navigation config
│
└── main.dart                      # App entry point
```

## 📋 Folder Purpose

### **core/** - Core Application Logic
Contains app-wide configurations, constants, themes, and utilities used across the entire application.

- **constants/**: Static values (colors, strings, routes)
- **utils/**: Helper functions and validators

### **features/** - Feature Modules
Each feature is self-contained with screens, widgets, models, services, and state management.

**Current Features:**
- **authentication/**: Login, register, splash screens

**To Add:**
- **home/**: Main dashboard
- **news/**: Sports news
- **sports/**: Sports venues and bookings

### **shared/** - Shared Components
Reusable widgets and models used across multiple features.

- **widgets/**: Common UI components (buttons, inputs, loaders)
- **models/**: Generic data models

### **config/** - Configuration
Application-level configuration files.

- **routes.dart**: Route definitions and navigation

## 🎯 Benefits

✅ **Scalable**: Easy to add new features  
✅ **Maintainable**: Clear separation of concerns  
✅ **Testable**: Isolated feature modules  
✅ **Clean**: Organized and professional structure  

## 📌 Adding New Features

1. Create a new folder under `features/`
2. Add subfolders: `screens/`, `widgets/`, `models/`, `services/`, `providers/`
3. Update routes in `config/routes.dart`
4. Add constants in `core/constants/`

## 🔄 Import Conventions

```dart
// Core imports
import 'package:sportzones/core/constants/app_colors.dart';

// Feature imports
import 'package:sportzones/features/authentication/screens/login_screen.dart';

// Shared imports
import 'package:sportzones/shared/widgets/custom_button.dart';
```
