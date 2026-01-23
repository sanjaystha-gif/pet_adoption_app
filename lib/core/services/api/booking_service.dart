import 'package:dio/dio.dart';
import 'package:pet_adoption_app/data/models/booking_model.dart';

class BookingService {
  final Dio dio;

  BookingService(this.dio);

  /// Create a new booking
  Future<BookingModel> createBooking({
    required String userId,
    required String userName,
    required String userEmail,
    required String userPhone,
    required String petId,
    required String petName,
    required String petImageUrl,
  }) async {
    try {
      final response = await dio.post(
        '/bookings/create',
        data: {
          'userId': userId,
          'userName': userName,
          'userEmail': userEmail,
          'userPhone': userPhone,
          'petId': petId,
          'petName': petName,
          'petImageUrl': petImageUrl,
          'status': 'pending',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return BookingModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception('Failed to create booking: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Booking creation error: ${e.message}');
    }
  }

  /// Get all bookings for a specific user
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final response = await dio.get('/bookings/user/$userId');

      if (response.statusCode == 200) {
        final List<dynamic> bookingsList =
            response.data['data'] ?? response.data;
        return bookingsList
            .map((booking) => BookingModel.fromJson(booking))
            .toList();
      } else {
        throw Exception('Failed to fetch user bookings');
      }
    } on DioException catch (e) {
      throw Exception('Fetch user bookings error: ${e.message}');
    }
  }

  /// Get all bookings (admin only)
  Future<List<BookingModel>> getAllBookings({String? status}) async {
    try {
      final params = status != null ? {'status': status} : null;
      final response = await dio.get('/bookings/all', queryParameters: params);

      if (response.statusCode == 200) {
        final List<dynamic> bookingsList =
            response.data['data'] ?? response.data;
        return bookingsList
            .map((booking) => BookingModel.fromJson(booking))
            .toList();
      } else {
        throw Exception('Failed to fetch bookings');
      }
    } on DioException catch (e) {
      throw Exception('Fetch bookings error: ${e.message}');
    }
  }

  /// Get bookings for a specific pet (admin can see who booked)
  Future<List<BookingModel>> getPetBookings(String petId) async {
    try {
      final response = await dio.get('/bookings/pet/$petId');

      if (response.statusCode == 200) {
        final List<dynamic> bookingsList =
            response.data['data'] ?? response.data;
        return bookingsList
            .map((booking) => BookingModel.fromJson(booking))
            .toList();
      } else {
        throw Exception('Failed to fetch pet bookings');
      }
    } on DioException catch (e) {
      throw Exception('Fetch pet bookings error: ${e.message}');
    }
  }

  /// Approve a booking (admin only)
  Future<BookingModel> approveBooking({
    required String bookingId,
    String? adminNotes,
  }) async {
    try {
      final response = await dio.put(
        '/bookings/$bookingId/approve',
        data: {
          'status': 'approved',
          'adminNotes': adminNotes,
          'approvedAt': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        return BookingModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception('Failed to approve booking');
      }
    } on DioException catch (e) {
      throw Exception('Approve booking error: ${e.message}');
    }
  }

  /// Reject a booking (admin only)
  Future<BookingModel> rejectBooking({
    required String bookingId,
    String? reason,
    String? adminNotes,
  }) async {
    try {
      final response = await dio.put(
        '/bookings/$bookingId/reject',
        data: {
          'status': 'rejected',
          'reason': reason,
          'adminNotes': adminNotes,
          'rejectedAt': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        return BookingModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception('Failed to reject booking');
      }
    } on DioException catch (e) {
      throw Exception('Reject booking error: ${e.message}');
    }
  }

  /// Cancel a booking (user cancels their own booking)
  Future<BookingModel> cancelBooking(String bookingId) async {
    try {
      final response = await dio.put(
        '/bookings/$bookingId/cancel',
        data: {'status': 'cancelled'},
      );

      if (response.statusCode == 200) {
        return BookingModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception('Failed to cancel booking');
      }
    } on DioException catch (e) {
      throw Exception('Cancel booking error: ${e.message}');
    }
  }
}
