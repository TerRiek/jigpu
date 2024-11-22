import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PlaybackHelper {
  static final PlaybackHelper _instance = PlaybackHelper._internal();

  factory PlaybackHelper() {
    return _instance;
  }

  PlaybackHelper._internal();

  static Database? _database;

  // 데이터베이스 접근 시 연결 상태 확인 및 필요 시 초기화
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    } else {
      _database = await _initDatabase();
      return _database!;
    }
  }

  // 데이터베이스 초기화
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'music_player.db');

    try {
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          debugPrint("onCreate 호출됨.");
          await _onCreate(db, version);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          debugPrint("onUpgrade 호출됨.");
          await _onUpgrade(db, oldVersion, newVersion);
        },
      );
    } catch (e) {
      debugPrint("데이터베이스 초기화 중 오류 발생: $e");
      rethrow;
    }
  }

  // 테이블 생성
  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
      CREATE TABLE playback (
        sessionId INTEGER PRIMARY KEY AUTOINCREMENT,
        songIdx INTEGER,
        sessionStartTime TEXT,
        sessionEndTime TEXT,
        totalDuration INTEGER DEFAULT 0,
        currentPosition INTEGER DEFAULT 0,
        playCount INTEGER DEFAULT 0,
        playbackTime TEXT
      );
      ''');
      debugPrint("playback 테이블이 성공적으로 생성되었습니다.");
    } catch (e) {
      debugPrint("테이블 생성 중 오류 발생: $e");
      rethrow;
    }
  }

  // 데이터베이스 업그레이드 처리
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      try {
        await db.execute('DROP TABLE IF EXISTS playback');
        await _onCreate(db, newVersion);
      } catch (e) {
        debugPrint("테이블 업그레이드 중 오류 발생: $e");
        rethrow;
      }
    }
  }

  // 재생 기록 및 세션 추가
  Future<int> addPlaybackHistorySession(int songIdx) async {
    final db = await database;
    try {
      int result = await db.insert(
        'playback',
        {
          'songIdx': songIdx,
          'sessionStartTime': DateTime.now().toIso8601String(),
          'playbackTime': DateTime.now().toIso8601String(),
          'playCount': 1,
          'totalDuration': 0,
          'currentPosition': 0
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('재생 기록 및 세션 추가: 노래 ID $songIdx, 기록 ID $result');
      return result;
    } catch (e) {
      debugPrint("재생 기록 및 세션 추가 중 오류 발생: $e");
      rethrow;
    }
  }

  // 재생 기록 및 세션 업데이트
  Future<void> updatePlaybackHistorySession(int sessionId, int currentPosition, int playCount, int totalDuration) async {
    final db = await database;
    try {
      await db.update(
        'playback',
        {
          'currentPosition': currentPosition,
          'totalDuration': totalDuration,
          'playCount': playCount,
          'playbackTime': DateTime.now().toIso8601String(),
        },
        where: 'sessionId = ?',
        whereArgs: [sessionId],
      );
      debugPrint('재생 기록 및 세션 업데이트 완료: 세션 ID $sessionId');
    } catch (e) {
      debugPrint("재생 기록 및 세션 업데이트 중 오류 발생: $e");
      rethrow;
    }
  }

  // 재생 기록 및 세션 종료
  Future<int> endPlaybackSession(int sessionId, int totalDuration) async {
    final db = await database;
    try {
      int result = await db.update(
        'playback',
        {
          'sessionEndTime': DateTime.now().toIso8601String(),
          'totalDuration': totalDuration,
        },
        where: 'sessionId = ?',
        whereArgs: [sessionId],
      );
      debugPrint('재생 세션 종료: 세션 ID $sessionId, 총 재생 시간: $totalDuration');
      return result;
    } catch (e) {
      debugPrint("세션 종료 중 오류 발생: $e");
      rethrow;
    }
  }

  // 재생 기록 및 세션 조회
  Future<List<Map<String, dynamic>>> getPlaybackHistorySession() async {
    final db = await database;
    try {
      return await db.query('playback');
    } catch (e) {
      debugPrint("재생 기록 및 세션 조회 중 오류 발생: $e");
      rethrow;
    }
  }

  // 재생 기록 및 세션 삭제
  Future<int> deletePlaybackHistorySession(int sessionId) async {
    final db = await database;
    try {
      return await db.delete(
        'playback',
        where: 'sessionId = ?',
        whereArgs: [sessionId],
      );
    } catch (e) {
      debugPrint("재생 기록 및 세션 삭제 중 오류 발생: $e");
      rethrow;
    }
  }
}
