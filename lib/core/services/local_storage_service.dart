import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:society_man/core/models/auth_models.dart';

class LocalStorageService {
  static const String _visitorProfilesKey = 'visitor_profiles';
  static const String _draftEntriesKey = 'draft_entries';
  static const String _pendingPatrolDataKey = 'pending_patrol_data';
  static const String _activePatrolKey = 'active_patrol';
  static const String _attendanceRecordsKey = 'attendance_records';
  static const String _visitorEntriesKey = 'visitor_entries';

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
    try {
      final decoded = jsonDecode(draftsJson);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {};
    } catch (e) {
      print('Error decoding drafts: $e');
      return {};
    }
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

  // Visitor Entry Management
  static Future<void> saveVisitorEntry(VisitorEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAllVisitorEntries();

    entries[entry.id] = entry.toMap();
    await prefs.setString(_visitorEntriesKey, jsonEncode(entries));
  }

  static Future<Map<String, dynamic>> getAllVisitorEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesJson = prefs.getString(_visitorEntriesKey);

    if (entriesJson == null) return {};
    try {
      final decoded = jsonDecode(entriesJson);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {};
    } catch (e) {
      print('Error decoding visitor entries: $e');
      return {};
    }
  }

  static Future<List<VisitorEntry>> getVisitorEntriesList() async {
    final entriesMap = await getAllVisitorEntries();
    return entriesMap.values
        .map((e) => VisitorEntry.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> updateVisitorExit(String entryId) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAllVisitorEntries();

    if (entries.containsKey(entryId)) {
      final entryMap = Map<String, dynamic>.from(entries[entryId]);
      final entry = VisitorEntry.fromMap(entryMap);

      entry.exitTime = DateTime.now();
      entry.status = 'checked_out';

      entries[entryId] = entry.toMap();
      await prefs.setString(_visitorEntriesKey, jsonEncode(entries));
    }
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
    try {
      final decoded = jsonDecode(pendingJson);
      if (decoded is List) {
        return decoded;
      }
      return [];
    } catch (e) {
      print('Error decoding pending patrol data: $e');
      return [];
    }
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
              'photoPath':
                  cp.photo?.path, // Store photo path instead of File object
            },
          )
          .toList(),
    };

    await prefs.setString(_activePatrolKey, jsonEncode(sessionData));
  }

  static Future<PatrolSession?> getActivePatrolSession() async {
    final prefs = await SharedPreferences.getInstance();
    final String? patrolJson = prefs.getString(_activePatrolKey);

    if (patrolJson == null) return null;

    final Map<String, dynamic> patrolData = jsonDecode(patrolJson);

    // Reconstruct checkpoints with photo files
    final List<PatrolCheckpoint> checkpoints = [];
    if (patrolData['checkpoints'] != null) {
      for (var cpData in patrolData['checkpoints']) {
        File? photo;
        if (cpData['photoPath'] != null) {
          // Check if the file still exists before creating File object
          photo = File(cpData['photoPath']);
          if (!await photo.exists()) {
            photo = null; // Don't include if file doesn't exist
          }
        }

        checkpoints.add(
          PatrolCheckpoint(
            id: cpData['id'],
            name: cpData['name'],
            qrCode: cpData['qrCode'],
            sequenceNumber: cpData['sequenceNumber'],
            isCompleted: cpData['isCompleted'],
            completedAt: cpData['completedAt'] != null
                ? DateTime.parse(cpData['completedAt'])
                : null,
            photo: photo,
          ),
        );
      }
    }

    return PatrolSession(
      id: patrolData['id'],
      guardId: patrolData['guardId'],
      startTime: DateTime.parse(patrolData['startTime']),
      endTime: patrolData['endTime'] != null
          ? DateTime.parse(patrolData['endTime'])
          : null,
      checkpoints: checkpoints,
      isPaused: patrolData['isPaused'] ?? false,
      isOffline: patrolData['isOffline'] ?? false,
      currentCheckpointIndex: patrolData['currentCheckpointIndex'] ?? 0,
      incidents: patrolData['incidents'] != null
          ? List<Map<String, dynamic>>.from(patrolData['incidents'])
          : const [],
    );
  }

  // Keep the original method for backward compatibility
  static Future<Map<String, dynamic>?> getActivePatrol() async {
    final prefs = await SharedPreferences.getInstance();
    final String? patrolJson = prefs.getString(_activePatrolKey);

    if (patrolJson == null) return null;
    return jsonDecode(patrolJson);
  }

  // Attendance Records
  static Future<void> saveAttendanceRecord(AttendanceRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recordsJson;
    try {
      recordsJson = prefs.getStringList('attendance_records') ?? [];
    } catch (e) {
      print('Error retrieving attendance_records for save: $e');
      // Corrupted data, clear it
      await prefs.remove('attendance_records');
      recordsJson = [];
    }

    recordsJson.add(json.encode(record.toJson()));
    await prefs.setStringList('attendance_records', recordsJson);
  }

  static Future<List<AttendanceRecord>> getAttendanceRecords() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recordsJsonList = [];
    try {
      recordsJsonList = prefs.getStringList('attendance_records') ?? [];
    } catch (e) {
      print('Error retrieving attendance_records list: $e');
      // If the data is corrupted (e.g., stored as String instead of List),
      // we try to recover or just start fresh.
      try {
        await prefs.remove('attendance_records');
      } catch (_) {}
      recordsJsonList = [];
    }

    List<AttendanceRecord> records = [];
    for (String recordJson in recordsJsonList) {
      try {
        final decoded = jsonDecode(recordJson);
        if (decoded is Map<String, dynamic>) {
          records.add(AttendanceRecord.fromJson(decoded));
        }
      } catch (e) {
        print('Error decoding attendance record: $e');
      }
    }
    return records;
  }

  static Future<AttendanceRecord?> getActiveAttendance(String guardId) async {
    final records = await getAttendanceRecords();

    for (var record in records.reversed) {
      if (record.guardId == guardId && record.checkOutTime == null) {
        return record;
      }
    }
    return null;
  }

  static Future<void> markAttendanceCheckIn({
    required String guardId,
    required String staffId,
    required String location,
    File? faceImage,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Create a new attendance record
      final attendanceRecord = AttendanceRecord(
        id: 'ATT_${DateTime.now().millisecondsSinceEpoch}',
        guardId: guardId,
        staffId: staffId,
        guardName: 'Rajesh Kumar', // You should get this from user data
        checkInTime: DateTime.now(),
        checkOutTime: null,
        location: location,
        notes: 'Check-in via mobile app',
        createdAt: DateTime.now(),
        checkInFaceImagePath: faceImage?.path,
      );

      // Get existing records
      // Get existing records
      List<String> recordsJson;
      try {
        recordsJson = prefs.getStringList('attendance_records') ?? [];
      } catch (e) {
        print('Error retrieving attendance_records for check-in: $e');
        await prefs.remove('attendance_records');
        recordsJson = [];
      }

      // Add new record
      recordsJson.add(json.encode(attendanceRecord.toJson()));

      // Save back to storage
      await prefs.setStringList('attendance_records', recordsJson);

      print('DEBUG: Check-in recorded for guard $guardId');
    } catch (e) {
      print('Error marking check-in: $e');
      rethrow;
    }
  }

  static Future<void> markAttendanceCheckOut({
    required String guardId,
    required String location,
    File? faceImage,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get all records as Json strings
      List<String> recordsJson =
          prefs.getStringList('attendance_records') ?? [];

      // Parse records to find the one to update
      int updateIndex = -1;
      AttendanceRecord? recordToUpdate;

      for (int i = recordsJson.length - 1; i >= 0; i--) {
        final record = AttendanceRecord.fromJson(jsonDecode(recordsJson[i]));
        if (record.guardId == guardId && record.checkOutTime == null) {
          updateIndex = i;
          recordToUpdate = record;
          break;
        }
      }

      if (updateIndex != -1 && recordToUpdate != null) {
        // Update with check-out time
        final updatedRecord = AttendanceRecord(
          id: recordToUpdate.id,
          guardId: recordToUpdate.guardId,
          staffId: recordToUpdate.staffId,
          guardName: recordToUpdate.guardName,
          checkInTime: recordToUpdate.checkInTime,
          checkOutTime: DateTime.now(),
          location: recordToUpdate.location,
          notes: '${recordToUpdate.notes ?? ''} - Check-out via mobile app',
          createdAt: recordToUpdate.createdAt,
          checkInFaceImagePath: recordToUpdate.checkInFaceImagePath,
          checkOutFaceImagePath: faceImage?.path,
        );

        recordsJson[updateIndex] = json.encode(updatedRecord.toJson());

        // Save back to storage
        await prefs.setStringList('attendance_records', recordsJson);
        print('DEBUG: Check-out recorded for guard $guardId');
        return;
      }

      throw Exception('No active check-in found for guard $guardId');
    } catch (e) {
      print('Error marking check-out: $e');
      rethrow;
    }
  }
}
