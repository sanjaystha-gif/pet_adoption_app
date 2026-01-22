# Project Structure Guide 📁

## Quick Navigation

### 🔐 Authentication & Onboarding
- **Splash Screen** → `lib/presentation/screens/auth/splash_screen.dart`
  - Shows on app launch (2.5 second delay)
  - Navigates to: Get Started Screen

- **Get Started Screen** → `lib/presentation/screens/onboarding/getstarted_screen.dart`
  - Onboarding carousel with 3 slides
  - Navigates to: Login Screen

- **Login Screen** → `lib/presentation/screens/auth/login_screen.dart`
  - Email/password validation
  - Admin login button
  - Navigates to: Main Navigation (user) or Admin Dashboard (admin)

- **Registration Screen** → `lib/presentation/screens/auth/registration_screen.dart`
  - Email/password/confirm password validation
  - 8+ character password requirement
  - Navigates to: Login Screen

- **Admin Login Screen** → `lib/presentation/screens/auth/admin_login_screen.dart`
  - Separate admin authentication
  - Navigates to: Admin Dashboard

### 🏠 Main App (User Features)

**Main Navigation** → `lib/presentation/screens/main/main_navigation_screen.dart`
- Bottom navigation bar with 4 tabs
- Houses: Home, Search, Favorites, Profile

**Home / Browse Pets** → `lib/presentation/screens/main/home/homepage_screen.dart`
- Grid of pet cards
- Category filters
- Navigates to: Pet Details Screen

**Search** → `lib/presentation/screens/main/search/search_screen.dart`
- Search functionality for pets

**Favorites** → `lib/presentation/screens/main/favorites/favorites_screen.dart`
- List of favorite pets

**Profile** → `lib/presentation/screens/main/profile/profile_screen.dart`
- User profile information
- "My Bookings" button

**Pet Details** → `lib/presentation/screens/main/pet_details/pet_details_screen.dart`
- Full pet information
- Favorite toggle
- "Adopt Now" button
- Navigates to: Booking Form Screen

**Booking Form** → `lib/presentation/screens/main/bookings/booking_form_screen.dart`
- Adoption request form
- Family & housing info
- Agreement checkboxes

**My Bookings** → `lib/presentation/screens/main/bookings/my_bookings_screen.dart`
- View all booking requests
- Filter by status (pending, approved, rejected)

### 🛠️ Admin Dashboard

**Admin Dashboard** → `lib/presentation/screens/admin/dashboard/admin_dashboard_screen.dart`
- Overview of admin features
- Quick access to pets and bookings management

**Pets Management**:
- **List** → `lib/presentation/screens/admin/pets/admin_pets_list_screen.dart`
  - View all pets
  - Edit/Delete options
  
- **Add Pet** → `lib/presentation/screens/admin/pets/admin_add_pet_screen.dart`
  - Create new pet listing
  - Image placeholder & form fields

- **Edit Pet** → `lib/presentation/screens/admin/pets/admin_edit_pet_screen.dart`
  - Update pet information

**Booking Requests** → `lib/presentation/screens/admin/bookings/admin_booking_requests_screen.dart`
- View adoption requests
- Approve/Reject buttons
- Status management

### 🔧 Core Infrastructure

**Core Services** → `lib/core/services/`
- Hive local storage
- API client (optional)
- Authentication service (planned)

**Constants** → `lib/core/constants/`
- App constants
- Color codes
- String constants

**Error Handling** → `lib/core/error/`
- Custom exceptions
- Error handling logic

## Import Patterns

### Standard Imports
```dart
// Import screens from auth
import 'package:pet_adoption_app/presentation/screens/auth/login_screen.dart';

// Import screens from main
import 'package:pet_adoption_app/presentation/screens/main/home/homepage_screen.dart';
import 'package:pet_adoption_app/presentation/screens/main/pet_details/pet_details_screen.dart';

// Import admin screens
import 'package:pet_adoption_app/presentation/screens/admin/dashboard/admin_dashboard_screen.dart';

// Import core services
import 'package:pet_adoption_app/core/services/hive/hive_service.dart';
```

## Feature Flow Diagram

```
┌─────────────────┐
│ Splash Screen   │ (2.5 sec)
└────────┬────────┘
         ↓
┌─────────────────┐
│ Get Started     │ (Onboarding)
└────────┬────────┘
         ↓
┌──────────────────┬──────────────────┐
│  Login Screen    │ Admin Login       │
└────────┬─────────┴─────────┬────────┘
         ↓                   ↓
   ┌──────────────┐   ┌──────────────────┐
   │ Main Nav     │   │ Admin Dashboard  │
   │ (4 screens)  │   │ (Pets + Bookings)│
   └──────────────┘   └──────────────────┘
```

## File Count Summary

| Layer | Count | Type |
|-------|-------|------|
| **Auth** | 4 | Screens |
| **Onboarding** | 1 | Screen |
| **Main App** | 8 | Screens |
| **Admin** | 5 | Screens |
| **Total Screens** | **18** | **Files** |
| **Core** | 3+ | Directories |
| **Data** | 3 | Directories |
| **Domain** | 3 | Directories |
| **Config** | 1 | Directory |

## Development Checklist

When adding new features:

- [ ] Create feature folder in appropriate layer (`main/` or `admin/`)
- [ ] Create screen file(s)
- [ ] Use absolute imports: `package:pet_adoption_app/presentation/screens/...`
- [ ] Update navigation in existing screens
- [ ] Test navigation flow
- [ ] Run `flutter analyze` to check for errors

## Validation Features

All authentication screens include:
- ✅ Email format validation (regex)
- ✅ Password length validation (8+ characters)
- ✅ Error message display
- ✅ Confirmation password matching (signup)
- ✅ Form validation before navigation

## State Management

Currently using:
- **Riverpod** for reactive state management
- **Hive** for local data persistence

Future additions:
- Repository pattern for data access
- Use cases for business logic
- Service locator for dependency injection

---

*Last Updated: January 22, 2026*
*Structure: Clean Architecture*
*Status: ✅ Production Ready*
