# Frontend Implementation - Complete Guide

## Overview

This document covers the complete frontend implementation for the Pet Adoption App booking system and real-time pet updates.

---

## File Structure

```
lib/
├── domain/
│   └── entities/
│       └── booking_entity.dart          (NEW)
├── data/
│   └── models/
│       └── booking_model.dart           (NEW)
├── core/
│   └── services/
│       └── api/
│           ├── api_client.dart          (MODIFIED)
│           └── booking_service.dart     (NEW)
└── presentation/
    ├── providers/
    │   ├── pet_provider.dart            (NEW)
    │   ├── booking_provider.dart        (NEW)
    │   └── api_providers.dart           (existing)
    └── screens/
        └── admin/
            └── bookings/
                └── admin_booking_requests_screen.dart  (REDESIGNED)
```

---

## Step-by-Step Implementation Guide

### Step 1: Create BookingEntity

File: lib/domain/entities/booking_entity.dart

Purpose: Define the domain model for bookings with all required fields.

Key Points:
- 14 fields total
- Immutable with copyWith
- Equatable for comparison
- Status as string for flexibility

```dart
import 'package:equatable/equatable.dart';

class BookingEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String petId;
  final String petName;
  final String petImageUrl;
  final String status;
  final String? adminNotes;
  final String reason;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;

  const BookingEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.petId,
    required this.petName,
    required this.petImageUrl,
    required this.status,
    this.adminNotes,
    required this.reason,
    required this.createdAt,
    this.approvedAt,
    this.rejectedAt,
  });

  @override
  List<Object?> get props => [
    id, userId, userName, userEmail, userPhone,
    petId, petName, petImageUrl, status,
    adminNotes, reason, createdAt, approvedAt, rejectedAt,
  ];

  BookingEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? petId,
    String? petName,
    String? petImageUrl,
    String? status,
    String? adminNotes,
    String? reason,
    DateTime? createdAt,
    DateTime? approvedAt,
    DateTime? rejectedAt,
  }) {
    return BookingEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      petImageUrl: petImageUrl ?? this.petImageUrl,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
    );
  }
}
```

---

### Step 2: Create BookingModel

File: lib/data/models/booking_model.dart

Purpose: Data model with JSON serialization for API communication.

Key Points:
- Extends BookingEntity
- fromJson factory for API responses
- toJson for request bodies
- Handles null values properly

```dart
import 'package:pet_adoption_app/domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.userEmail,
    required super.userPhone,
    required super.petId,
    required super.petName,
    required super.petImageUrl,
    required super.status,
    super.adminNotes,
    required super.reason,
    required super.createdAt,
    super.approvedAt,
    super.rejectedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userEmail: json['userEmail'] ?? '',
      userPhone: json['userPhone'] ?? '',
      petId: json['petId'] ?? '',
      petName: json['petName'] ?? '',
      petImageUrl: json['petImageUrl'] ?? '',
      status: json['status'] ?? 'pending',
      adminNotes: json['adminNotes'],
      reason: json['reason'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      rejectedAt: json['rejectedAt'] != null ? DateTime.parse(json['rejectedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'petId': petId,
      'petName': petName,
      'petImageUrl': petImageUrl,
      'status': status,
      'adminNotes': adminNotes,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectedAt': rejectedAt?.toIso8601String(),
    };
  }
}
```

---

### Step 3: Create BookingService

File: lib/core/services/api/booking_service.dart

Purpose: Handle all booking-related API calls.

Key Methods:
1. createBooking
2. getUserBookings
3. getAllBookings
4. getPetBookings
5. approveBooking
6. rejectBooking
7. cancelBooking

Implementation Pattern:
- Try-catch for error handling
- Proper status code checking
- Token included in headers
- Clear error messages

---

### Step 4: Create PetApiClient and Pet Providers

File: lib/presentation/providers/pet_provider.dart

Purpose: Manage pet data with real-time filtering for admin updates.

Key Components:
- PetApiClient class with 3 methods
- 6 Riverpod providers for state
- Filtering logic for admin pets
- Auto-refresh mechanism

Admin Pet Filtering Logic:
```dart
final adminUpdatedPetsProvider = FutureProvider<List<PetModel>>((ref) async {
  final allPets = await ref.watch(allPetsProvider.future);
  return allPets.where((pet) => 
    pet.postedBy == 'admin' || pet.postedByName == 'admin'
  ).toList();
});
```

---

### Step 5: Create Booking State Management

File: lib/presentation/providers/booking_provider.dart

Purpose: Manage booking state with Riverpod for all user and admin actions.

Providers Created:
1. bookingServiceProvider - Service instance
2. userBookingsProvider - Get user bookings
3. adminBookingsProvider - Get all bookings
4. pendingBookingsProvider - Filter pending
5. createBookingProvider - Create action
6. cancelBookingProvider - Cancel action
7. approveBookingProvider - Approve action
8. rejectBookingProvider - Reject action

Each action provider uses AsyncNotifier for proper state management.

---

### Step 6: Update API Client

File: lib/core/services/api/api_client.dart

Change: Add Dio getter

```dart
class ApiClient {
  final Dio _dio;
  
  ApiClient(this._dio) {
    // Setup interceptors, etc.
  }
  
  Dio get dio => _dio;  // NEW: Expose Dio for direct use
}
```

---

### Step 7: Redesign Admin Booking Dashboard

File: lib/presentation/screens/admin/bookings/admin_booking_requests_screen.dart

Changes:
- Changed from StatefulWidget to ConsumerWidget
- Riverpod integration for state
- Pull-to-refresh functionality
- Approval/rejection dialogs
- Loading and error states
- Booking cards with status badges

UI Components:
- _BookingRequestCard: Displays booking details
- _ApprovalDialog: For approving bookings
- _RejectDialog: For rejecting bookings
- Status badges with colors

---

## Real-Time Update Implementation

### Pull-to-Refresh Method

Implementation:
```dart
Future<void> _handleRefresh() async {
  ref.invalidate(allPetsProvider);
  await ref.refresh(allPetsProvider.future);
}
```

User Flow:
1. User pulls down on dashboard
2. Provider is invalidated
3. New fetch request triggered
4. Fresh data loaded
5. UI refreshes automatically

### Admin Pet Update Scenario
1. Admin updates pet in backend
2. PUT /api/v1/items/{id} returns updated pet
3. postedBy field set to 'admin'
4. User refreshes dashboard
5. adminUpdatedPetsProvider filters fresh data
6. Only admin pets shown in update section

---

## State Management Architecture

### Riverpod Patterns Used

1. FutureProvider for async data
   ```dart
   final allPetsProvider = FutureProvider<List<PetModel>>((ref) async {
     return ref.watch(petApiClientProvider).getAllPets();
   });
   ```

2. AsyncNotifier for state mutations
   ```dart
   class CreateBookingNotifier extends AsyncNotifier<BookingEntity> {
     @override
     Future<BookingEntity> build() async {
       return BookingEntity(...);
     }
   }
   ```

3. Provider invalidation for refresh
   ```dart
   ref.invalidate(allPetsProvider);
   ```

---

## Error Handling Pattern

All API calls follow this pattern:

```dart
try {
  final response = await _dio.post(
    '/api/v1/bookings/create',
    data: bookingData,
  );
  
  if (response.statusCode == 201) {
    return BookingModel.fromJson(response.data['data']);
  } else {
    throw Exception('Failed to create booking');
  }
} catch (e) {
  print('Error: $e');
  rethrow;
}
```

UI Error Display:
```dart
if (bookingAsync.isLoading) {
  return CircularProgressIndicator();
} else if (bookingAsync.hasError) {
  return ErrorDialog(error: bookingAsync.error.toString());
} else {
  return BookingsList(bookings: bookingAsync.value ?? []);
}
```

---

## Integration Points with Backend

### API Endpoints Consumed

1. Create Booking
   Method: POST
   Path: /api/v1/bookings/create
   Input: BookingEntity data
   Output: BookingEntity with id and createdAt

2. Get User Bookings
   Method: GET
   Path: /api/v1/bookings/user/:userId
   Output: List<BookingEntity>

3. Get All Bookings
   Method: GET
   Path: /api/v1/bookings/all
   Output: List<BookingEntity>
   Note: Admin only

4. Approve Booking
   Method: PUT
   Path: /api/v1/bookings/:id/approve
   Input: adminNotes
   Output: BookingEntity with status='approved'

5. Reject Booking
   Method: PUT
   Path: /api/v1/bookings/:id/reject
   Input: adminNotes
   Output: BookingEntity with status='rejected'

---

## Testing the Implementation

### Unit Test Pattern

```dart
test('Create booking should return BookingEntity', () async {
  final mockDio = MockDio();
  final service = BookingService(mockDio);
  
  final booking = BookingEntity(...);
  
  final result = await service.createBooking(booking);
  
  expect(result, isA<BookingEntity>());
  expect(result.status, equals('pending'));
});
```

### Widget Test Pattern

```dart
testWidgets('Admin dashboard shows booking requests', (tester) async {
  await tester.pumpWidget(ProviderContainer(...));
  
  expect(find.byType(BookingRequestCard), findsWidgets);
  expect(find.byText('Approve'), findsWidgets);
});
```

### Integration Test Pattern

```dart
test('Full booking flow', () async {
  // Create booking
  final booking = await bookingService.createBooking(newBooking);
  expect(booking.status, equals('pending'));
  
  // Admin approves
  final approved = await bookingService.approveBooking(booking.id, 'Approved');
  expect(approved.status, equals('approved'));
});
```

---

## Performance Optimization

### Caching Strategy
- Riverpod caches provider results automatically
- Manual invalidation only on state changes
- No unnecessary network calls

### UI Optimization
- ConsumerWidget updates only affected widgets
- List rendering optimized with ListTile
- Lazy loading available for future use

### Memory Management
- Providers auto-dispose when unused
- No circular dependencies
- Controllers cleaned up properly

---

## Debugging Tips

### Enable Logging
```dart
InterceptorsWrapper(
  onRequest: (options, handler) {
    print('Request: ${options.method} ${options.path}');
    return handler.next(options);
  },
  onResponse: (response, handler) {
    print('Response: ${response.statusCode}');
    return handler.next(response);
  },
  onError: (error, handler) {
    print('Error: ${error.message}');
    return handler.next(error);
  },
);
```

### Check Provider State
```dart
debugPrintBeforeCallback: true,
debugPrintAfterCallback: true,
```

### Use DevTools
- Flutter DevTools shows provider state
- Network tab shows API calls
- Performance tab shows rebuild counts

---

## Common Issues and Solutions

Issue: Provider rebuilds too often
Solution: Use select() to watch specific fields

Issue: API calls fail with 401
Solution: Verify token is valid and included

Issue: Bookings not appearing in admin dashboard
Solution: Check status filter is correct

Issue: Admin pet updates not showing
Solution: Verify pull-to-refresh invalidates provider

---

## Next Steps After Implementation

1. Backend team implements endpoints
2. Frontend team tests with real backend
3. Fix any integration issues
4. Add WebSocket for real-time updates (optional)
5. Performance testing
6. Deploy to production

---

## Summary

All frontend components are complete and follow clean architecture principles. Integration with backend is straightforward - just connect the service layer to real endpoints.

Code is:
- Type-safe
- Error-handled
- Testable
- Performant
- Maintainable
