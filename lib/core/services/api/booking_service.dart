import 'package:dio/dio.dart';
import 'dart:async';
import 'package:pet_adoption_app/data/models/booking_model.dart';

class BookingService {
  final Dio dio;

  BookingService(this.dio);

  static const Duration _requestTimeout = Duration(seconds: 20);

  String _extractDioMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Request timed out. Please try again.';
    }
    return e.message ?? fallback;
  }

  /// Create a new booking
  Future<BookingModel> createBooking({
    required String userId,
    required String userName,
    required String userEmail,
    required String userPhone,
    required String petId,
    required String petName,
    required String petImageUrl,
    String? address,
    String? reason,
  }) async {
    try {
      final response = await dio
          .post(
            '/bookings/create',
            data: {
              'userId': userId,
              'userName': userName,
              'userEmail': userEmail,
              'userPhone': userPhone,
              'petId': petId,
              'petName': petName,
              'petImageUrl': petImageUrl,
              if (address != null && address.trim().isNotEmpty)
                'address': address.trim(),
              if (reason != null && reason.trim().isNotEmpty)
                'reason': reason.trim(),
              'status': 'pending',
            },
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return BookingModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception('Failed to create booking: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception(
        'Booking creation error: ${_extractDioMessage(e, 'Failed to create booking')}',
      );
    } on TimeoutException {
      throw Exception('Booking creation timed out. Please try again.');
    }
  }

  /// Get all bookings for a specific user
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final response = await dio
          .get('/bookings/user/$userId')
          .timeout(_requestTimeout);

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
      throw Exception(
        'Fetch user bookings error: ${_extractDioMessage(e, 'Failed to fetch bookings')}',
      );
    } on TimeoutException {
      throw Exception('Fetching bookings timed out. Please pull to refresh.');
    }
  }

  /// Get all bookings (admin only)
  Future<List<BookingModel>> getAllBookings({String? status}) async {
    try {
      final params = status != null ? {'status': status} : null;
      final response = await dio
          .get('/bookings/all', queryParameters: params)
          .timeout(_requestTimeout);

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
      throw Exception(
        'Fetch bookings error: ${_extractDioMessage(e, 'Failed to fetch bookings')}',
      );
    } on TimeoutException {
      throw Exception('Fetching booking requests timed out. Please try again.');
    }
  }

  /// Get bookings for a specific pet (admin can see who booked)
  Future<List<BookingModel>> getPetBookings(String petId) async {
    try {
      final response = await dio
          .get('/bookings/pet/$petId')
          .timeout(_requestTimeout);

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
      throw Exception(
        'Fetch pet bookings error: ${_extractDioMessage(e, 'Failed to fetch pet bookings')}',
      );
    } on TimeoutException {
      throw Exception('Fetching pet bookings timed out. Please try again.');
    }
  }

  /// Approve a booking (admin only)
  Future<BookingModel> approveBooking({
    required String bookingId,
    String? adminNotes,
  }) async {
    try {
      final response = await dio
          .put(
            '/bookings/$bookingId/approve',
            data: {
              'status': 'approved',
              'adminNotes': adminNotes,
              'approvedAt': DateTime.now().toIso8601String(),
            },
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        return BookingModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception('Failed to approve booking');
      }
    } on DioException catch (e) {
      throw Exception(
        'Approve booking error: ${_extractDioMessage(e, 'Failed to approve booking')}',
      );
    } on TimeoutException {
      throw Exception('Approve action timed out. Please try again.');
    }
  }

  /// Reject a booking (admin only)
  Future<BookingModel> rejectBooking({
    required String bookingId,
    String? reason,
    String? adminNotes,
  }) async {
    try {
      final response = await dio
          .put(
            '/bookings/$bookingId/reject',
            data: {
              'status': 'rejected',
              'reason': reason,
              'adminNotes': adminNotes,
              'rejectedAt': DateTime.now().toIso8601String(),
            },
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        return BookingModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception('Failed to reject booking');
      }
    } on DioException catch (e) {
      throw Exception(
        'Reject booking error: ${_extractDioMessage(e, 'Failed to reject booking')}',
      );
    } on TimeoutException {
      throw Exception('Reject action timed out. Please try again.');
    }
  }

  /// Cancel a booking (user cancels their own booking)
  Future<BookingModel> cancelBooking(String bookingId) async {
    try {
      final response = await dio
          .put('/bookings/$bookingId/cancel', data: {'status': 'cancelled'})
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        return BookingModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception('Failed to cancel booking');
      }
    } on DioException catch (e) {
      throw Exception(
        'Cancel booking error: ${_extractDioMessage(e, 'Failed to cancel booking')}',
      );
    } on TimeoutException {
      throw Exception('Cancel action timed out. Please try again.');
    }
  }
}
