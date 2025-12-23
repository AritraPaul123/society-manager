import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:society_man/core/models/auth_models.dart';

class LocalStorageService {
  static const String _visitorProfilesKey = 'visitor_profiles';
  static const String _draftEntriesKey = 'draft_entries';
  static const String _pendingPatrolDataKey = 'pending_patrol_data';
  static const String _activePatrolKey = 'active_patrol';
  static const String _attendanceRecordsKey = 'attendance_records';

  // Visitor Profile Management
  static Future<void> saveVisitorProfile(VisitorProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profiles = await getAllVisitorProfiles();

    // Update or add profile
    profiles[profile.eidNumber] = profile;

    final profilesMap = profiles.map(
      (key, value) => MapEntry(key, value.toMap()),
    );

    await prefs.setString(_visitorProfilesKey, jsonEncode(profilesMap));
  }

  static Future<Map<String, VisitorProfile>> getAllVisitorProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profilesJson = prefs.getString(_visitorProfilesKey);

    if (profilesJson == null) return {};

    final Map<String, dynamic> decoded = jsonDecode(profilesJson);
    return decoded.map(
      (key, value) => MapEntry(key, VisitorProfile.fromMap(value)),
    );
  }

  static Future<VisitorProfile?> getVisitorProfile(String eidNumber) async {
    final profiles = await getAllVisitorProfiles();
    return profiles[eidNumber];
  }

  // Draft Entries Management
  static Future<void> saveDraft(VisitorEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getAllDrafts();

    drafts[entry.id] = entry.toMap();
    await prefs.setString(_draftEntriesKey, jsonEncode(drafts));
  }

  static Future<Map<String, dynamic>> getAllDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? draftsJson = prefs.getString(_draftEntriesKey);

    if (draftsJson == null) return {};
    return jsonDecode(draftsJson);
  }

  static Future<void> deleteDraft(String draftId) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getAllDrafts();

    drafts.remove(draftId);
    await prefs.setString(_draftEntriesKey, jsonEncode(drafts));
  }

  static Future<void> deleteExpiredDrafts(Duration expiryDuration) async {
    final drafts = await getAllDrafts();
    final now = DateTime.now();

    drafts.removeWhere((key, value) {
      final entryTime = DateTime.parse(value['entryTime']);
      return now.difference(entryTime) > expiryDuration;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_draftEntriesKey, jsonEncode(drafts));
  }

  // Patrol Data (Offline Mode)
  static Future<void> savePendingPatrolData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final pending = await getPendingPatrolData();

    pending.add(data);
    await prefs.setString(_pendingPatrolDataKey, jsonEncode(pending));
  }

  static Future<List<dynamic>> getPendingPatrolData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? pendingJson = prefs.getString(_pendingPatrolDataKey);

    if (pendingJson == null) return [];
    return jsonDecode(pendingJson);
  }

  static Future<void> clearPendingPatrolData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingPatrolDataKey);
  }

  // Active Patrol Session
  static Future<void> saveActivePatrol(PatrolSession? session) async {
    final prefs = await SharedPreferences.getInstance();

    if (session == null) {
      await prefs.remove(_activePatrolKey);
      return;
    }

    final sessionData = {
      'id': session.id,
      'guardId': session.guardId,
      'startTime': session.startTime.toIso8601String(),
      'endTime': session.endTime?.toIso8601String(),
      'isPaused': session.isPaused,
      'isOffline': session.isOffline,
      'currentCheckpointIndex': session.currentCheckpointIndex,
      'incidents': session.incidents,
      'checkpoints': session.checkpoints
          .map(
            (cp) => {
              'id': cp.id,
              'name': cp.name,
              'qrCode': cp.qrCode,
              'sequenceNumber': cp.sequenceNumber,
              'isCompleted': cp.isCompleted,
              'completedAt': cp.completedAt?.toIso8601String(),
            },
          )
          .toList(),
    };

    await prefs.setString(_activePatrolKey, jsonEncode(sessionData));
  }

  static Future<Map<String, dynamic>?> getActivePatrol() async {
    final prefs = await SharedPreferences.getInstance();
    final String? patrolJson = prefs.getString(_activePatrolKey);

    if (patrolJson == null) return null;
    return jsonDecode(patrolJson);
  }

  // Attendance Records
  static Future<void> saveAttendanceRecord(AttendanceRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getAttendanceRecords();

    records.add(record.toMap());
    await prefs.setString(_attendanceRecordsKey, jsonEncode(records));
  }

  static Future<List<dynamic>> getAttendanceRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString(_attendanceRecordsKey);

    if (recordsJson == null) return [];
    return jsonDecode(recordsJson);
  }

  static Future<AttendanceRecord?> getActiveAttendance(String guardId) async {
    final records = await getAttendanceRecords();

    for (var record in records.reversed) {
      if (record['guardId'] == guardId && record['checkOutTime'] == null) {
        return AttendanceRecord(
          guardId: record['guardId'],
          staffId: record['staffId'],
          checkInTime: DateTime.parse(record['checkInTime']),
          checkOutTime: record['checkOutTime'] != null
              ? DateTime.parse(record['checkOutTime'])
              : null,
          location: record['location'],
          status: record['status'] == 'AttendanceStatus.active'
              ? AttendanceStatus.active
              : AttendanceStatus.onDuty,
        );
      }
    }
    return null;
  }
}
