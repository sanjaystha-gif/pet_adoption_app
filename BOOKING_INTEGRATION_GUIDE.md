# Integration Guide: Adding Booking to Pet Details Screen

This guide helps you add the booking functionality to your existing pet details screen.

## Quick Integration Steps

### Step 1: Import Required Providers
Add these imports to your `pet_details_screen.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/presentation/providers/booking_provider.dart';
import 'package:pet_adoption_app/presentation/providers/api_providers.dart';
```

### Step 2: Convert Screen to ConsumerWidget
Change your StatelessWidget to ConsumerWidget:

```dart
// Before:
class PetDetailsScreen extends StatelessWidget {

// After:
class PetDetailsScreen extends ConsumerWidget {
```

### Step 3: Add "Book This Pet" Button
Add this button in your pet details UI (usually in the action buttons section):

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final pet = ... // your pet data
  
  return Scaffold(
    // ... existing code ...
    bottomNavigationBar: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Existing favorite button
          // ...
          
          Expanded(
            child: ElevatedButton(
              onPressed: () => _handleBookPet(context, ref, pet),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF67D2C),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Book This Pet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    // ... rest of your code ...
  );
}
```

### Step 4: Add the Booking Handler Method
Add this method to your screen class:

```dart
Future<void> _handleBookPet(
  BuildContext context,
  WidgetRef ref,
  dynamic pet, // your pet object
) async {
  // Check if user is logged in
  final currentUser = ref.read(currentUserProvider);
  
  if (currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please login to book a pet'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  // Show confirmation dialog
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Booking'),
      content: Text(
        'Do you want to book ${pet.name}?\n\n'
        'An admin will review your request and contact you soon.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF67D2C),
          ),
          child: const Text('Book Now'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  // Show loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  try {
    // Create booking
    final bookingNotifier = ref.read(createBookingProvider.notifier);
    final booking = await bookingNotifier.createBooking(
      userId: currentUser.id,
      userName: currentUser.firstName,
      userEmail: currentUser.email,
      userPhone: currentUser.phoneNumber ?? '',
      petId: pet.id,
      petName: pet.name,
      petImageUrl: pet.mediaUrl,
    );

    if (!context.mounted) return;
    Navigator.pop(context); // Close loading dialog

    if (booking != null) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Booking request submitted successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              // Navigate to user's bookings
              // Navigator.pushNamed(context, '/my-bookings');
            },
          ),
        ),
      );

      // Optionally navigate back after booking
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          Navigator.pop(context);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create booking. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    Navigator.pop(context); // Close loading dialog
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

### Step 5: Add User Bookings Screen (Optional)
Create a new screen to show user their bookings in their profile:

```dart
// lib/presentation/screens/main/bookings/my_bookings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/presentation/providers/booking_provider.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(userBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bookings yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      booking.petImageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(Icons.pets),
                      ),
                    ),
                  ),
                  title: Text(booking.petName),
                  subtitle: Text('Status: ${booking.status}'),
                  trailing: _statusBadge(booking.status),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = status == 'pending'
        ? Colors.orange
        : status == 'approved'
            ? Colors.green
            : status == 'rejected'
                ? Colors.red
                : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
```

## Data Flow Diagram

```
┌─────────────────┐
│ Pet Details UI  │
│                 │
│ "Book This Pet" │
│    button       │
└────────┬────────┘
         │ User clicks
         ▼
┌─────────────────────────────────────┐
│ _handleBookPet()                    │
│ - Verify user logged in             │
│ - Show confirmation dialog          │
└────────┬────────────────────────────┘
         │ User confirms
         ▼
┌─────────────────────────────────────┐
│ createBookingProvider.notifier      │
│ .createBooking()                    │
└────────┬────────────────────────────┘
         │ API call
         ▼
┌──────────────────────────────┐
│ Backend:                     │
│ POST /api/v1/bookings/create │
└────────┬─────────────────────┘
         │ Returns created booking
         ▼
┌─────────────────────────────────────┐
│ Frontend invalidates:                │
│ - userBookingsProvider              │
│ - allPetsProvider                   │
└────────┬────────────────────────────┘
         │ Data refreshed
         ▼
┌─────────────────────────────────────┐
│ Show success message                │
│ "Booking request submitted!"        │
└─────────────────────────────────────┘
```

## Testing the Integration

1. **Test Login Flow:**
   - Ensure user must be logged in before booking
   - Non-logged-in users should see "Please login" message

2. **Test Booking Creation:**
   - Click "Book This Pet"
   - Fill confirmation dialog
   - Should see success message
   - Booking should appear in My Bookings

3. **Test Admin View:**
   - Admin should see the booking in Admin Dashboard
   - Admin can approve/reject
   - Status should update on both sides

4. **Test Error Handling:**
   - Try booking same pet twice
   - Backend should handle duplicate bookings
   - Show appropriate error messages

## Common Issues & Solutions

### Issue: "currentUserProvider is null"
**Solution:** User is not logged in. Add navigation to login.

### Issue: "Booking not appearing in admin dashboard"
**Solution:** 
- Check backend endpoint `/api/v1/bookings/all` returns data
- Verify JWT token is sent in request headers
- Check admin has permission to view all bookings

### Issue: "Network error when creating booking"
**Solution:**
- Verify backend is running
- Check base URL in `api_client.dart`
- Check all required fields are provided
- Verify user phone is not empty (might be null)

## Next Steps

1. Add "My Bookings" link to user profile
2. Add booking cancellation for pending bookings
3. Add notification when booking is approved/rejected
4. Implement booking history with filters
