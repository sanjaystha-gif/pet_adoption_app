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
  final String status; // 'pending', 'approved', 'rejected', 'cancelled'
  final String? adminNotes;
  final String? reason; // Reason for rejection
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
    this.reason,
    required this.createdAt,
    this.approvedAt,
    this.rejectedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    userEmail,
    userPhone,
    petId,
    petName,
    petImageUrl,
    status,
    adminNotes,
    reason,
    createdAt,
    approvedAt,
    rejectedAt,
  ];

  // CopyWith method for easy updates
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
