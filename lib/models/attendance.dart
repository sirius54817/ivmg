import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String id;
  final String staffId;
  final String staffName;
  final DateTime checkInTime;
  final double latitude;
  final double longitude;
  final String? faceImagePath;
  final bool isWithinRange;

  Attendance({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.checkInTime,
    required this.latitude,
    required this.longitude,
    this.faceImagePath,
    required this.isWithinRange,
  });

  factory Attendance.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Attendance(
      id: doc.id,
      staffId: data['staffId'] ?? '',
      staffName: data['staffName'] ?? '',
      checkInTime: (data['checkInTime'] as Timestamp).toDate(),
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      faceImagePath: data['faceImagePath'],
      isWithinRange: data['isWithinRange'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'checkInTime': Timestamp.fromDate(checkInTime),
      'latitude': latitude,
      'longitude': longitude,
      'faceImagePath': faceImagePath,
      'isWithinRange': isWithinRange,
    };
  }
}
