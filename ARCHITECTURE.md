# Pet Adoption App - Clean Architecture Structure

## 📁 Folder Organization

```
lib/
├── main.dart                          # App entry point
├── app/
│   └── App.dart                       # Root widget configuration
│
├── config/                            # Configuration files
│   └── routes/                        # Routing configuration
│
├── core/                              # Core functionality
│   ├── constants/                     # App constants
│   ├── error/                         # Error handling
│   ├── services/                      # Hive, API services
│   └── utils/                         # Utility functions
│
├── data/                              # Data Layer
│   ├── datasources/                   # Remote/Local data sources
│   ├── models/                        # Data models
│   └── repositories/                  # Repository implementations
│
├── domain/                            # Business Logic Layer
│   ├── entities/                      # Core business objects
│   ├── repositories/                  # Abstract repositories
│   └── usecases/                      # Business use cases
│
└── presentation/                      # Presentation Layer
    ├── screens/                       # All UI Screens
    │   ├── auth/                      # Authentication screens
    │   │   ├── login_screen.dart
    │   │   ├── registration_screen.dart
    │   │   ├── splash_screen.dart
    │   │   └── admin_login_screen.dart
    │   │
    │   ├── onboarding/                # Onboarding/Intro screens
    │   │   └── getstarted_screen.dart
    │   │
    │   ├── main/                      # Main app screens (after login)
    │   │   ├── main_navigation_screen.dart
    │   │   ├── home/
    │   │   │   └── homepage_screen.dart
    │   │   ├── search/
    │   │   │   └── search_screen.dart
    │   │   ├── favorites/
    │   │   │   └── favorites_screen.dart
    │   │   ├── profile/
    │   │   │   └── profile_screen.dart
    │   │   ├── pet_details/
    │   │   │   └── pet_details_screen.dart
    │   │   └── bookings/
    │   │       ├── booking_form_screen.dart
    │   │       └── my_bookings_screen.dart
    │   │
    │   └── admin/                     # Admin panel screens
    │       ├── dashboard/
    │       │   └── admin_dashboard_screen.dart
    │       ├── pets/
    │       │   ├── admin_pets_list_screen.dart
    │       │   ├── admin_add_pet_screen.dart
    │       │   └── admin_edit_pet_screen.dart
    │       └── bookings/
    │           └── admin_booking_requests_screen.dart
    │
    ├── widgets/                       # Reusable widgets
    └── providers/                     # Riverpod state management
```

## 🏗️ Architecture Layers

### 1. **Presentation Layer** (`presentation/`)
   - Handles UI and user interactions
   - Contains screens organized by feature
   - Uses Riverpod for state management
   - Example: `screens/auth/login_screen.dart`

### 2. **Domain Layer** (`domain/`)
   - Contains business logic and use cases
   - Defines abstract repositories
   - Independent of frameworks
   - Will contain: entities, repositories, usecases

### 3. **Data Layer** (`data/`)
   - Handles data sources (local/remote)
   - Repository implementations
   - Data models and mappers
   - Will contain: datasources, models, repositories

### 4. **Core Layer** (`core/`)
   - Shared utilities across layers
   - Constants, error handling
   - Services (Hive, API)
   - Platform-specific utilities

### 5. **Configuration** (`config/`)
   - App routing configuration
   - Theme configuration
   - Dependency injection setup

## 📝 Migration Guide

### Old Structure → New Structure
```
lib/screens/login_screen.dart
  → lib/presentation/screens/auth/login_screen.dart

lib/screens/homepage_screen.dart
  → lib/presentation/screens/main/home/homepage_screen.dart

lib/screens/pet_details_screen.dart
  → lib/presentation/screens/main/pet_details/pet_details_screen.dart

lib/screens/admin_dashboard_screen.dart
  → lib/presentation/screens/admin/dashboard/admin_dashboard_screen.dart
```

## 🎯 Import Pattern

After migration, imports follow this pattern:
```dart
// Import from presentation layer
import 'package:pet_adoption_app/presentation/screens/auth/login_screen.dart';

// Import from domain layer
import 'package:pet_adoption_app/domain/entities/user.dart';

// Import from core layer
import 'package:pet_adoption_app/core/services/hive/hive_service.dart';
```

## ✅ Benefits

1. **Scalability**: Easy to add new features
2. **Testability**: Clear separation of concerns
3. **Maintainability**: Organized structure
4. **Reusability**: Share components across features
5. **Performance**: Better tree shaking and code splitting
