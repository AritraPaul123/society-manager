import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class OfflineSyncService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'patrol_offline.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE patrols(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            guardId INTEGER,
            routeId INTEGER,
            startTime TEXT,
            status TEXT,
            isSynced INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE patrol_logs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            patrolId INTEGER,
            qrPointId INTEGER,
            scannedTime TEXT,
            comments TEXT,
            photoUrl TEXT,
            latitude REAL,
            longitude REAL,
            FOREIGN KEY (patrolId) REFERENCES patrols (id)
          )
        ''');
      },
    );
  }

  Future<int> savePatrolOffline(
    Map<String, dynamic> patrolData,
    List<Map<String, dynamic>> logs,
  ) async {
    final db = await database;
    int patrolId = await db.insert('patrols', patrolData);
    for (var log in logs) {
      log['patrolId'] = patrolId;
      await db.insert('patrol_logs', log);
    }
    return patrolId;
  }

  Future<void> syncWithServer(String baseUrl, String token) async {
    final db = await database;
    List<Map<String, dynamic>> unsyncedPatrols = await db.query(
      'patrols',
      where: 'isSynced = ?',
      whereArgs: [0],
    );

    for (var patrol in unsyncedPatrols) {
      List<Map<String, dynamic>> logs = await db.query(
        'patrol_logs',
        where: 'patrolId = ?',
        whereArgs: [patrol['id']],
      );

      Map<String, dynamic> syncData = {
        'guardId': patrol['guardId'],
        'routeId': patrol['routeId'],
        'startTime': patrol['startTime'],
        'logs': logs,
      };

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/v1/patrols/sync'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode([syncData]),
        );

        if (response.statusCode == 200) {
          await db.update(
            'patrols',
            {'isSynced': 1},
            where: 'id = ?',
            whereArgs: [patrol['id']],
          );
        }
      } catch (e) {
        print('Sync failed for patrol ${patrol['id']}: $e');
      }
    }
  }
}
