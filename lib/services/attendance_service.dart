import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/attendance.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Office location (replace with your actual coordinates)
  static const double officeLatitude = 37.7749; // Example: San Francisco
  static const double officeLongitude = -122.4194;
  static const double maxDistanceInMeters = 50.0;

  // Calculate distance from office
  double calculateDistance(double latitude, double longitude) {
    return Geolocator.distanceBetween(
      officeLatitude,
      officeLongitude,
      latitude,
      longitude,
    );
  }

  // Check if location is within office range
  bool isWithinOfficeRange(double latitude, double longitude) {
    final distance = calculateDistance(latitude, longitude);
    return distance <= maxDistanceInMeters;
  }

  // Mark attendance
  Future<void> markAttendance({
    required String staffId,
    required String staffName,
    required double latitude,
    required double longitude,
    String? faceImagePath,
  }) async {
    final isWithinRange = isWithinOfficeRange(latitude, longitude);

    if (!isWithinRange) {
      throw Exception(
        'You are not within 50m of the office location. Please come closer.',
      );
    }

    // Check if already marked today
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final existingAttendance = await _firestore
        .collection('attendance')
        .where('staffId', isEqualTo: staffId)
        .where('checkInTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('checkInTime', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    if (existingAttendance.docs.isNotEmpty) {
      throw Exception('Attendance already marked for today');
    }

    final attendanceData = {
      'staffId': staffId,
      'staffName': staffName,
      'checkInTime': Timestamp.fromDate(DateTime.now()),
      'latitude': latitude,
      'longitude': longitude,
      'faceImagePath': faceImagePath,
      'isWithinRange': isWithinRange,
    };

    await _firestore.collection('attendance').add(attendanceData);
  }

  // Get attendance for a staff member
  Stream<List<Attendance>> getStaffAttendance(String staffId) {
    return _firestore
        .collection('attendance')
        .where('staffId', isEqualTo: staffId)
        .snapshots()
        .map((snapshot) {
      final attendances =
          snapshot.docs.map((doc) => Attendance.fromFirestore(doc)).toList();
      attendances.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
      return attendances;
    });
  }

  // Get all attendance records
  Stream<List<Attendance>> getAllAttendance() {
    return _firestore.collection('attendance').snapshots().map((snapshot) {
      final attendances =
          snapshot.docs.map((doc) => Attendance.fromFirestore(doc)).toList();
      attendances.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
      return attendances;
    });
  }

  // Check current location permission and get position
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable them.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Please enable them in settings.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
