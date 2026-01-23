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
    return BookingModel(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      userName: json['userName'] ?? json['user_name'] ?? '',
      userEmail: json['userEmail'] ?? json['user_email'] ?? '',
      userPhone: json['userPhone'] ?? json['user_phone'] ?? '',
      petId: json['petId'] ?? json['pet_id'] ?? '',
      petName: json['petName'] ?? json['pet_name'] ?? '',
      petImageUrl: json['petImageUrl'] ?? json['pet_image_url'] ?? '',
      status: json['status'] ?? 'pending',
      adminNotes: json['adminNotes'] ?? json['admin_notes'],
      reason: json['reason'],
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
