import 'dart:io';

enum UserRole { guard, resident, admin }

enum AttendanceStatus { active, inactive, onDuty, offDuty }

class User {
  final String id;
  final String name;
  final UserRole role;
  final String? staffId;
  final String? username;
  final String? pin;
  final String? faceImagePath; // Store path instead of File object

  User({
    required this.id,
    required this.name,
    required this.role,
    this.staffId,
    this.username,
    this.pin,
    this.faceImagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role.toString(),
      'staffId': staffId,
      'username': username,
      'pin': pin,
      'faceImagePath': faceImagePath,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == map['role'],
        orElse: () => UserRole.guard,
      ),
      staffId: map['staffId'],
      username: map['username'],
      pin: map['pin'],
      faceImagePath: map['faceImagePath'],
    );
  }
}

class AttendanceRecord {
  final String guardId;
  final String staffId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String location;
  final AttendanceStatus status;
  File? checkInFaceImage;
  File? checkOutFaceImage;

  AttendanceRecord({
    required this.guardId,
    required this.staffId,
    required this.checkInTime,
    this.checkOutTime,
    required this.location,
    required this.status,
    this.checkInFaceImage,
    this.checkOutFaceImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'guardId': guardId,
      'staffId': staffId,
      'checkInTime': checkInTime.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'location': location,
      'status': status.toString(),
    };
  }
}

class VisitorProfile {
  final String eidNumber;
  String visitorName;
  String phoneNumber;
  String? nationality;
  String? companyName; // Added company name field
  final DateTime firstVisit;
  DateTime lastVisit;
  int visitCount;

  VisitorProfile({
    required this.eidNumber,
    required this.visitorName,
    required this.phoneNumber,
    this.nationality,
    this.companyName, // Added company name parameter
    required this.firstVisit,
    required this.lastVisit,
    this.visitCount = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'eidNumber': eidNumber,
      'visitorName': visitorName,
      'phoneNumber': phoneNumber,
      'nationality': nationality,
      'companyName': companyName, // Added company name to map
      'firstVisit': firstVisit.toIso8601String(),
      'lastVisit': lastVisit.toIso8601String(),
      'visitCount': visitCount,
    };
  }

  factory VisitorProfile.fromMap(Map<String, dynamic> map) {
    return VisitorProfile(
      eidNumber: map['eidNumber'],
      visitorName: map['visitorName'],
      phoneNumber: map['phoneNumber'],
      nationality: map['nationality'],
      companyName: map['companyName'], // Added company name from map
      firstVisit: DateTime.parse(map['firstVisit']),
      lastVisit: DateTime.parse(map['lastVisit']),
      visitCount: map['visitCount'] ?? 1,
    );
  }
}

class VisitorEntry {
  final String id;
  final String eidNumber;
  final String visitorName;
  final String phoneNumber;
  final String purpose;
  final String? companyName;
  final DateTime entryTime;
  final String guardId;
  final String status; // 'allowed', 'pending_resident', 'denied', 'draft'
  final bool isDraft;
  File? photo;

  VisitorEntry({
    required this.id,
    required this.eidNumber,
    required this.visitorName,
    required this.phoneNumber,
    required this.purpose,
    this.companyName,
    required this.entryTime,
    required this.guardId,
    required this.status,
    this.isDraft = false,
    this.photo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eidNumber': eidNumber,
      'visitorName': visitorName,
      'phoneNumber': phoneNumber,
      'purpose': purpose,
      'companyName': companyName,
      'entryTime': entryTime.toIso8601String(),
      'guardId': guardId,
      'status': status,
      'isDraft': isDraft,
    };
  }
}

class PatrolCheckpoint {
  final String id;
  final String name;
  final String qrCode;
  final int sequenceNumber;
  bool isCompleted;
  DateTime? completedAt;
  File? photo;

  PatrolCheckpoint({
    required this.id,
    required this.name,
    required this.qrCode,
    required this.sequenceNumber,
    this.isCompleted = false,
    this.completedAt,
    this.photo,
  });
}

class PatrolSession {
  final String id;
  final String guardId;
  final DateTime startTime;
  DateTime? endTime;
  final List<PatrolCheckpoint> checkpoints;
  bool isPaused;
  bool isOffline;
  int currentCheckpointIndex;
  final List<Map<String, dynamic>> incidents;

  PatrolSession({
    required this.id,
    required this.guardId,
    required this.startTime,
    this.endTime,
    required this.checkpoints,
    this.isPaused = false,
    this.isOffline = false,
    this.currentCheckpointIndex = 0,
    this.incidents = const [],
  });

  double get progress {
    int completed = checkpoints.where((cp) => cp.isCompleted).length;
    return completed / checkpoints.length;
  }
}
