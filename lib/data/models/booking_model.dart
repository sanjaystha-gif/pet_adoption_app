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
    super.reason,
    required super.createdAt,
    super.approvedAt,
    super.rejectedAt,
  });

  // Convert API response JSON to BookingModel
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely convert values to strings
    String _safeString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map) {
        return (value['_id'] ?? value['id'] ?? value.toString()).toString();
      }
      return value.toString();
    }

    return BookingModel(
      id: _safeString(json['id'] ?? json['_id']),
      userId: _safeString(json['userId'] ?? json['user_id']),
      userName: _safeString(json['userName'] ?? json['user_name']),
      userEmail: _safeString(json['userEmail'] ?? json['user_email']),
      userPhone: _safeString(json['userPhone'] ?? json['user_phone']),
      petId: _safeString(json['petId'] ?? json['pet_id']),
      petName: _safeString(json['petName'] ?? json['pet_name']),
      petImageUrl: _safeString(json['petImageUrl'] ?? json['pet_image_url']),
      status: json['status'] ?? 'pending',
      adminNotes: _safeString(json['adminNotes'] ?? json['admin_notes']),
      reason: _safeString(json['reason']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'].toString())
          : null,
      rejectedAt: json['rejectedAt'] != null
          ? DateTime.parse(json['rejectedAt'].toString())
          : null,
    );
  }

  // Convert BookingModel to JSON for API requests
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
