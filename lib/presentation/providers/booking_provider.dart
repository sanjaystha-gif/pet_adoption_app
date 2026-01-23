import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/core/services/api/booking_service.dart';
import 'package:pet_adoption_app/data/models/booking_model.dart';
import 'package:pet_adoption_app/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:pet_adoption_app/presentation/providers/api_providers.dart';

final bookingServiceProvider = Provider<BookingService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingService(apiClient.dio);
});

final userBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final userEntity = ref.watch(currentUserProvider);
  if (userEntity == null) return [];

  final bookingService = ref.watch(bookingServiceProvider);
  try {
    return await bookingService.getUserBookings(userEntity.id);
  } catch (e) {
    return [];
  }
});

final adminBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final bookingService = ref.watch(bookingServiceProvider);
  try {
    return await bookingService.getAllBookings();
  } catch (e) {
    return [];
  }
});

final pendingBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final bookingService = ref.watch(bookingServiceProvider);
  try {
    return await bookingService.getAllBookings(status: 'pending');
  } catch (e) {
    return [];
  }
});

class CreateBookingNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<BookingModel?> createBooking({
    required String userId,
    required String userName,
    required String userEmail,
    required String userPhone,
    required String petId,
    required String petName,
    required String petImageUrl,
  }) async {
    final bookingService = ref.read(bookingServiceProvider);
    try {
      state = const AsyncValue.loading();
      final booking = await bookingService.createBooking(
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        userPhone: userPhone,
        petId: petId,
        petName: petName,
        petImageUrl: petImageUrl,
      );
      state = const AsyncValue.data(null);
      ref.invalidate(userBookingsProvider);
      return booking;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }
}

final createBookingProvider =
    AsyncNotifierProvider<CreateBookingNotifier, void>(
      () => CreateBookingNotifier(),
    );

class CancelBookingNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> cancelBooking(String bookingId) async {
    final bookingService = ref.read(bookingServiceProvider);
    try {
      state = const AsyncValue.loading();
      await bookingService.cancelBooking(bookingId);
      state = const AsyncValue.data(null);
      ref.invalidate(userBookingsProvider);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}

final cancelBookingProvider =
    AsyncNotifierProvider<CancelBookingNotifier, void>(
      () => CancelBookingNotifier(),
    );

class ApproveBookingNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> approveBooking({
    required String bookingId,
    String? adminNotes,
  }) async {
    final bookingService = ref.read(bookingServiceProvider);
    try {
      state = const AsyncValue.loading();
      await bookingService.approveBooking(
        bookingId: bookingId,
        adminNotes: adminNotes,
      );
      state = const AsyncValue.data(null);
      ref.invalidate(adminBookingsProvider);
      ref.invalidate(pendingBookingsProvider);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}

final approveBookingProvider =
    AsyncNotifierProvider<ApproveBookingNotifier, void>(
      () => ApproveBookingNotifier(),
    );

class RejectBookingNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> rejectBooking({
    required String bookingId,
    String? reason,
    String? adminNotes,
  }) async {
    final bookingService = ref.read(bookingServiceProvider);
    try {
      state = const AsyncValue.loading();
      await bookingService.rejectBooking(
        bookingId: bookingId,
        reason: reason,
        adminNotes: adminNotes,
      );
      state = const AsyncValue.data(null);
      ref.invalidate(adminBookingsProvider);
      ref.invalidate(pendingBookingsProvider);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}

final rejectBookingProvider =
    AsyncNotifierProvider<RejectBookingNotifier, void>(
      () => RejectBookingNotifier(),
    );
