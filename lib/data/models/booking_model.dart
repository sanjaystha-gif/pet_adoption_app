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
    String safeString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map) {
        return (value['_id'] ?? value['id'] ?? value['name'] ?? '').toString();
      }
      return value.toString();
    }

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    final dynamic userObj = json['user'];
    final dynamic petObj = json['pet'] ?? json['petId'];

    final String userId = safeString(
      json['userId'] ??
          json['user_id'] ??
          (userObj is Map ? userObj['_id'] : null),
    );
    final String userName = safeString(
      json['userName'] ??
          json['user_name'] ??
          (userObj is Map
              ? (userObj['name'] ?? userObj['username'] ?? userObj['fullName'])
              : null),
    );
    final String userEmail = safeString(
      json['userEmail'] ??
          json['user_email'] ??
          (userObj is Map ? userObj['email'] : null),
    );
    final String userPhone = safeString(
      json['userPhone'] ??
          json['user_phone'] ??
          (userObj is Map ? userObj['phoneNumber'] ?? userObj['phone'] : null),
    );

    String petImage = safeString(json['petImageUrl'] ?? json['pet_image_url']);
    if (petImage.isEmpty && petObj is Map) {
      final dynamic photos = petObj['photos'];
      final dynamic media = petObj['media'];
      petImage = safeString(
        petObj['mediaUrl'] ??
            petObj['imageUrl'] ??
            ((photos is List && photos.isNotEmpty) ? photos.first : null) ??
            ((media is List && media.isNotEmpty) ? media.first : null),
      );
    }

    return BookingModel(
      id: safeString(json['id'] ?? json['_id']),
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      petId: safeString(
        json['petId'] ??
            json['pet_id'] ??
            (petObj is Map ? petObj['_id'] : null),
      ),
      petName: safeString(
        json['petName'] ??
            json['pet_name'] ??
            (petObj is Map ? petObj['name'] : null),
      ),
      petImageUrl: petImage,
      status: (json['status'] ?? 'pending').toString().toLowerCase(),
      adminNotes: safeString(json['adminNotes'] ?? json['admin_notes']),
      reason: safeString(json['reason']),
      createdAt: parseDate(json['createdAt']),
      approvedAt: json['approvedAt'] != null
          ? parseDate(json['approvedAt'])
          : null,
      rejectedAt: json['rejectedAt'] != null
          ? parseDate(json['rejectedAt'])
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
