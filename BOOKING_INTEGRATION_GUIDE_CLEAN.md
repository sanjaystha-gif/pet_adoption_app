# Booking Integration Guide

## Quick Start: How to Integrate Booking UI with Existing Screens

This guide shows how to add booking functionality to any screen in your app.

---

## Integration Pattern

All booking integration follows the same simple pattern:

1. Wrap widget with ConsumerWidget
2. Get the create booking provider
3. Show dialog or form
4. Call the booking action
5. Handle success/error
6. Refresh pet list

---

## Option 1: Add to Pet Details Screen

File: lib/presentation/screens/user/pet_details_screen.dart

Current State: Shows pet details

Goal: Add "Book This Pet" button

### Step-by-Step

Step 1: Change widget type
```dart
// Before
class PetDetailsScreen extends StatefulWidget { ... }

// After
class PetDetailsScreen extends ConsumerWidget { ... }
```

Step 2: Update build method
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Your existing code
}
```

Step 3: Add booking button
```dart
ElevatedButton.icon(
  icon: Icon(Icons.check_circle),
  label: Text('Book This Pet'),
  onPressed: () => _showBookingDialog(context, ref, pet),
)
```

Step 4: Implement booking dialog
```dart
void _showBookingDialog(
  BuildContext context,
  WidgetRef ref,
  PetModel pet,
) {
  final reasonController = TextEditingController();
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Book ${pet.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Reason for booking',
                hintText: 'e.g., I want to adopt this pet',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            await _handleBooking(
              context,
              ref,
              pet,
              reasonController.text,
            );
          },
          child: Text('Confirm Booking'),
        ),
      ],
    ),
  );
}
```

Step 5: Handle booking action
```dart
Future<void> _handleBooking(
  BuildContext context,
  WidgetRef ref,
  PetModel pet,
  String reason,
) async {
  final currentUser = ref.watch(currentUserProvider);
  
  if (currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please login first')),
    );
    return;
  }
  
  final booking = BookingEntity(
    id: '',
    userId: currentUser.id,
    userName: currentUser.name,
    userEmail: currentUser.email,
    userPhone: currentUser.phone ?? '',
    petId: pet.id,
    petName: pet.name,
    petImageUrl: pet.imageUrl,
    status: 'pending',
    reason: reason,
    createdAt: DateTime.now(),
  );
  
  final createBooking = ref.watch(createBookingProvider);
  final result = await ref.read(createBookingProvider.notifier)
    .createBooking(booking);
  
  if (!context.mounted) return;
  
  if (result != null) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking submitted successfully!')),
    );
    ref.invalidate(userBookingsProvider);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to create booking')),
    );
  }
}
```

---

## Option 2: Add to Search Results

File: lib/presentation/screens/user/search_results_screen.dart

Goal: Show "Book" button on each search result card

Implementation:

```dart
class PetSearchCard extends ConsumerWidget {
  final PetModel pet;

  const PetSearchCard(this.pet);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: Image.network(pet.imageUrl),
        title: Text(pet.name),
        subtitle: Text(pet.breed),
        trailing: IconButton(
          icon: Icon(Icons.book),
          onPressed: () => _bookPet(context, ref),
        ),
      ),
    );
  }

  void _bookPet(BuildContext context, WidgetRef ref) {
    // Same implementation as pet details screen
    _showBookingDialog(context, ref, pet);
  }
}
```

---

## Option 3: Add to Dashboard Card

File: lib/presentation/screens/user/user_dashboard_screen.dart

Goal: Add booking button to pet cards shown in dashboard

Implementation:

```dart
Stack(
  children: [
    Image.network(pet.imageUrl),
    Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black54,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                pet.name,
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.book),
              label: Text('Book'),
              onPressed: () => _showBookingDialog(context, ref, pet),
            ),
          ],
        ),
      ),
    ),
  ],
)
```

---

## Complete Example: Pet Details Screen

Here's a complete, working example:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/domain/entities/booking_entity.dart';
import 'package:pet_adoption_app/data/models/pet_model.dart';
import 'package:pet_adoption_app/presentation/providers/api_providers.dart';
import 'package:pet_adoption_app/presentation/providers/booking_provider.dart';

class PetDetailsScreen extends ConsumerWidget {
  final PetModel pet;

  const PetDetailsScreen(this.pet, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(pet.name)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(pet.imageUrl),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text('${pet.breed} - ${pet.age} years'),
                  SizedBox(height: 20),
                  Text(pet.description),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.check_circle),
                      label: Text('Book This Pet'),
                      onPressed: () => _showBookingDialog(context, ref),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDialog(BuildContext context, WidgetRef ref) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book ${pet.name}'),
        content: TextField(
          controller: reasonController,
          decoration: InputDecoration(
            labelText: 'Reason for booking',
            hintText: 'Why do you want to adopt this pet?',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _handleBooking(context, ref, reasonController.text);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBooking(
    BuildContext context,
    WidgetRef ref,
    String reason,
  ) async {
    final currentUser = ref.watch(currentUserProvider);
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login first')),
      );
      return;
    }

    final booking = BookingEntity(
      id: '',
      userId: currentUser.id,
      userName: currentUser.name,
      userEmail: currentUser.email,
      userPhone: currentUser.phone ?? '',
      petId: pet.id,
      petName: pet.name,
      petImageUrl: pet.imageUrl,
      status: 'pending',
      reason: reason,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(createBookingProvider.notifier).createBooking(booking);
      
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking submitted successfully!')),
      );
      
      ref.invalidate(userBookingsProvider);
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
```

---

## Key Code Patterns

### Pattern 1: Using ConsumerWidget

```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access providers here
    final booking = ref.watch(userBookingsProvider);
    return Container();
  }
}
```

### Pattern 2: Calling a Provider Action

```dart
// Get current user
final currentUser = ref.watch(currentUserProvider);

// Create booking
await ref.read(createBookingProvider.notifier)
  .createBooking(booking);

// Approve booking (admin only)
await ref.read(approveBookingProvider.notifier)
  .approveBooking(bookingId, adminNotes);
```

### Pattern 3: Invalidating Providers

```dart
// Refresh user bookings
ref.invalidate(userBookingsProvider);

// Refresh all pets
ref.invalidate(allPetsProvider);
```

### Pattern 4: Watching Provider State

```dart
final bookingAsync = ref.watch(userBookingsProvider);

bookingAsync.when(
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
  data: (bookings) => ListView(
    children: bookings.map((b) => BookingCard(b)).toList(),
  ),
);
```

---

## Common Integration Scenarios

### Scenario 1: Booking from Pet Grid

```dart
GridView.builder(
  itemCount: pets.length,
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
  ),
  itemBuilder: (context, index) {
    final pet = pets[index];
    return Stack(
      children: [
        Image.network(pet.imageUrl),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ElevatedButton(
            onPressed: () => _showBookingDialog(context, ref, pet),
            child: Text('Book'),
          ),
        ),
      ],
    );
  },
)
```

### Scenario 2: Quick Booking from List

```dart
ListTile(
  title: Text(pet.name),
  subtitle: Text(pet.breed),
  trailing: ElevatedButton(
    onPressed: () => _quickBook(context, ref, pet),
    child: Text('Book'),
  ),
)
```

### Scenario 3: Booking in Modal

```dart
showModalBottomSheet(
  context: context,
  builder: (context) => PetBookingSheet(pet: pet),
)
```

---

## Error Handling Best Practices

### Pattern 1: User Feedback

```dart
try {
  await createBooking();
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Booking created!'),
      backgroundColor: Colors.green,
    ),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Error: ${e.toString()}'),
      backgroundColor: Colors.red,
    ),
  );
}
```

### Pattern 2: Validation Before Submit

```dart
if (reason.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Please enter a reason')),
  );
  return;
}

if (currentUser == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Please login first')),
  );
  return;
}
```

### Pattern 3: Loading State

```dart
bool isLoading = false;

ElevatedButton(
  onPressed: isLoading ? null : _handleBooking,
  child: isLoading 
    ? CircularProgressIndicator()
    : Text('Book'),
)
```

---

## Testing the Integration

### Manual Testing Steps

1. Open app and login as user
2. Navigate to pet details
3. Click "Book This Pet"
4. Enter reason
5. Click confirm
6. See success message
7. Go to "My Bookings"
8. Verify booking appears
9. Check admin dashboard
10. Admin should see pending booking

### What to Verify

- Booking created with correct pet ID
- Status is 'pending'
- All user fields populated
- Timestamp recorded
- Admin can see in dashboard
- No console errors

---

## Troubleshooting

### Issue: Button not appearing
Solution: Check ConsumerWidget is used and WidgetRef parameter exists

### Issue: Booking not created
Solution: Verify backend endpoint is working, check network logs

### Issue: Error after booking
Solution: Check error message, verify all required fields filled

### Issue: Admin doesn't see booking
Solution: Check booking status is 'pending', admin dashboard has permission

---

## Advanced: Custom Booking Flows

### Add Confirmation Dialog

```dart
Future<void> _handleBooking(...) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Confirm Booking'),
      content: Text('Are you sure you want to book ${pet.name}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Confirm'),
        ),
      ],
    ),
  );
  
  if (confirmed == true) {
    // Proceed with booking
  }
}
```

### Add Success Animation

```dart
if (success) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Booking created!'),
      action: SnackBarAction(
        label: 'View Booking',
        onPressed: () => Navigator.pushNamed(
          context,
          '/my-bookings',
        ),
      ),
    ),
  );
}
```

---

## Summary

Integration is simple:
1. Wrap widget with ConsumerWidget
2. Access ref parameter
3. Show dialog to get reason
4. Create BookingEntity
5. Call createBookingProvider
6. Show success/error
7. Invalidate related providers

All patterns are consistent across the app. Copy-paste the example and modify for your specific screen.

Enjoy!
