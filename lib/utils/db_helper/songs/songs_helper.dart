import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../../models/song_model.dart';

class SongsHelper {
  static final SongsHelper _instance = SongsHelper._internal();

  factory SongsHelper() {
    return _instance;
  }

  SongsHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    } else {
      _database = await _initDatabase();
      return _database!;
    }
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'music_player.db');
    await deleteDatabase(path);
    debugPrint('기존 데이터베이스 파일 삭제 완료');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE songs (
        idx INTEGER PRIMARY KEY AUTOINCREMENT,
        id TEXT UNIQUE,
        title TEXT,
        artist TEXT,
        artUri TEXT,
        duration INTEGER,
        playlistName TEXT,
        createdAt TEXT,
        updatedAt TEXT
      );
    ''');
  }

  Future<int> insertSong(SongModel song) async {
    final db = await database;
    int result = await db.insert(
      'songs',
      song.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('노래 삽입 완료: ${song.title}, ID: ${song.idx}');
    return result;
  }

  Future<SongModel?> getSong(int idx) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'songs',
      where: 'idx = ?',
      whereArgs: [idx],
    );

    if (results.isNotEmpty) {
      debugPrint('노래 조회 성공: ID $idx');
      return SongModel.fromJson(results.first);
    } else {
      debugPrint('노래 조회 실패: ID $idx');
      return null;
    }
  }

  Future<List<SongModel>> getAllSongs() async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query('songs');
    debugPrint('총 ${results.length}개의 노래가 조회됨');
    return results.map((song) => SongModel.fromJson(song)).toList();
  }

  Future<int> deleteSong(int idx) async {
    final db = await database;
    return await db.delete(
      'songs',
      where: 'idx = ?',
      whereArgs: [idx],
    );
  }
}
