import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/data_view_model.dart';
import '../../../models/song_model.dart';

class DatabaseHelperFavoriteSong {
  static final DatabaseHelperFavoriteSong _instance = DatabaseHelperFavoriteSong
      ._internal();
  static Database? _database;
  final currentTime = DateTime.now().toIso8601String();

  factory DatabaseHelperFavoriteSong() {
    return _instance;
  }

  Future<String?> getUserEmailFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  DatabaseHelperFavoriteSong._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'music_playlist.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: (db) async {
        await _checkAndCreateTable(db);
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createSongsTable(db);
    await _createFilePathsTable(db);
  }

  Future<void> _createSongsTable(Database db) async {
    await db.execute('''
      CREATE TABLE songs(
        idx INTEGER PRIMARY KEY AUTOINCREMENT,
        id TEXT UNIQUE,
        title TEXT,
        artist TEXT,
        artUri TEXT,
        duration INTEGER,
        playlistName TEXT,
        songRating INTEGER,
        favorite INTEGER,
        noteReview TEXT,
        rating INTEGER,
        userEmail TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        isDownloaded INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _createFilePathsTable(Database db) async {
    await db.execute('''
      CREATE TABLE file_paths(
        songIdx INTEGER PRIMARY KEY,
        filePath TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');
  }

  Future<void> _checkAndCreateTable(Database db) async {
    var result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='songs'");
    if (result.isEmpty) {
      await _createSongsTable(db);
    }
    result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='file_paths'");
    if (result.isEmpty) {
      await _createFilePathsTable(db);
    }
  }

  Future<void> insertSong(SongModel song, String review, int rating,
      String filePath, bool favorite) async {
    final db = await database;
    final userEmail = await getUserEmailFromPrefs();
    final songData = song.toJson();

    songData['favorite'] = favorite;
    songData['noteReview'] = review;
    songData['rating'] = rating;
    songData['userEmail'] = userEmail;
    songData['createdAt'] = currentTime;
    songData['updatedAt'] = currentTime;

    int songIdx = await db.insert(
        'songs', songData, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert(
      'file_paths',
      {
        'songIdx': songIdx,
        'filePath': filePath,
        'createdAt': currentTime,
        'updatedAt': currentTime,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 아직 파일을 다운로드하지 않고, 음원 리뷰 데이터만 데이터베이스에 음원 정보를 삽입합니다.
  Future<void> insertSongWithoutFile(SongModel song, String review, int rating,
      bool favorite) async {
    final db = await database;
    final userEmail = await getUserEmailFromPrefs();
    final songData = song.toJson();

    final currentTime = DateTime.now().toIso8601String();

    songData['favorite'] = favorite ? 1 : 0;
    songData['noteReview'] = review;
    songData['rating'] = rating;
    songData['userEmail'] = userEmail;
    songData['createdAt'] = currentTime;
    songData['updatedAt'] = currentTime;

    //print("songData : ${songData.runtimeType} $songData");
    await db.insert('songs', songData, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SongModel>> getSongs() async {
    final db = await database;
    final userEmail = await getUserEmailFromPrefs();
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      where: 'userEmail = ?',
      whereArgs: [userEmail],
    );
    // 각 음원의 파일 경로를 가져오기
    for (var map in maps) {
      final List<Map<String, dynamic>> filePathMap = await db.query(
        'file_paths',
        where: 'songIdx = ?',
        whereArgs: [map['idx']],
      );
      if (filePathMap.isNotEmpty) {
        map['filePath'] = filePathMap.first['filePath'];
      }
    }

    return List.generate(maps.length, (i) {
      return SongModel.fromJson(maps[i]);
    });
  }

  Future<void> deleteSongFromDatabase(String songIdx) async {
    final db = await DatabaseHelperFavoriteSong().database;
    final userEmail = await getUserEmailFromPrefs();
/*
    // 파일 삭제
    final fileDeleter = DeleteFavoriteSongFile();
    await fileDeleter.deleteFavoriteSongFile(songIdx);

    // 파일 테이블의 파일 주소를 ""으로 수정하고 업데이트 날짜를 변경
    await db.update(
      'file_paths',
      {
        'filePath': '',
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'songIdx = ?',
      whereArgs: [songIdx],
    );

    // 파일 삭제
    final fileDeleter = DeleteFavoriteSongFile();
    await fileDeleter.deleteFavoriteSongFile(songIdx);

    // 파일 테이블의 파일 주소를 ""으로 수정하고 업데이트 날짜를 변경
    await db.update(
      'file_paths',
      {
        'filePath': '',
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'songIdx = ?',
      whereArgs: [songIdx],
    );
    */
    // 음악 테이블의 좋아요 여부를 false로 수정
    await db.update(
      'songs',
      {
        'favorite': 0,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'idx = ? AND userEmail = ?',
      whereArgs: [songIdx, userEmail],
    );
  }

/*
  String extractIdxFromFilePath(String filePath) {
    final regex = RegExp(r'\/(\d+)\.');
    final match = regex.firstMatch(filePath);

    if (match != null && match.groupCount > 0) {
      return match.group(1)!; // idx 추출
    } else {
      throw Exception('파일 경로에서 idx를 추출할 수 없습니다.');
    }
  }*/

  Future<bool> isSongByIdx(int idx) async {
    final db = await database;
    final userEmail = await getUserEmailFromPrefs();
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      where: 'idx = ? AND userEmail = ?',
      whereArgs: [idx, userEmail],
    );
    final isStored = maps.isNotEmpty;
    return maps.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getSongDetailsByIdx(int idx) async {
    final db = await database;
    final userEmail = await getUserEmailFromPrefs();
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      where: 'idx = ? AND userEmail = ?',
      whereArgs: [idx, userEmail],
    );

    if (maps.isNotEmpty) {
      final songDetails = maps.first;
      return songDetails;
    } else {
      return null;
    }
  }

  Future<List<DataViewModel>> getFavoriteDataViewModels() async {
    final db = await database;
    final userEmail = await getUserEmailFromPrefs();

    //select는 순서를 보장하지 않아 order by를 추가함
    //createdAt, updatedAt, pk(idx)는 정상적으로 정렬되지 않음
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
    SELECT * FROM songs WHERE userEmail = ? AND favorite = 1
    ORDER BY idx DESC
    ''',
      [userEmail],
    );

    List<DataViewModel> dataViewModels = [];

    //map은 QueryRow 타입
    for (var map in maps) {
      debugPrint("map : ${map.runtimeType} $map");
      // 'map'을 읽기 전용이기 때문에 수정하려면 복사본을 사용해야 함.
      final mutableMap = Map<String, dynamic>.from(map);

      final List<Map<String, dynamic>> filePathMap = await db.query(
        'file_paths',
        where: 'songIdx = ?',
        whereArgs: [map['idx']],
      );

      SongModel song;

      if (filePathMap.isNotEmpty) {
        mutableMap['filePath'] = filePathMap.first['filePath'];
        song = SongModel(
          idx: mutableMap['idx'],
          id: "file://${mutableMap['filePath']}",
          title: mutableMap['title'],
          artist: mutableMap['artist'],
          artUri: mutableMap['artUri'] != null
              ? Uri.parse(mutableMap['artUri'])
              : null,
          duration: mutableMap['duration'] != null ? Duration(
              milliseconds: mutableMap['duration']) : null,
          playlistName: mutableMap['playlistName'],
          songRating: mutableMap['songRating'],
        );
      }else {
        song = SongModel(
          idx: mutableMap['idx'],
          id: mutableMap['id'],
          title: mutableMap['title'],
          artist: mutableMap['artist'],
          artUri: mutableMap['artUri'] != null
              ? Uri.parse(mutableMap['artUri'])
              : null,
          duration: mutableMap['duration'] != null ? Duration(
              milliseconds: mutableMap['duration']) : null,
          playlistName: mutableMap['playlistName'],
          songRating: mutableMap['songRating'],
        );
      }

      dataViewModels.add(
        DataViewModel(
          idx: song.idx,
          title: song.title,
          titleEn: song.title,
          artist: song.artist,
          image0: song.artUri?.toString(),
          song: song,
        ),
      );
    }
    return dataViewModels;
  }

  Future<int> countFavoriteSongs() async {
    final db = await database;
    final userEmail = await getUserEmailFromPrefs();

    final result = await db.rawQuery(
      '''
    SELECT COUNT(*) as count FROM songs WHERE userEmail = ? AND favorite = 1
    ''',
      [userEmail],
    );

    final count = result.isNotEmpty ? result[0]['count'] as int : 0;
    return count;
  }

  Future<void> updateFavoriteStatus(int idx, String review, int rating,
      bool favorite, Uri artUri) async {
    final db = await database;
    final userEmail = await getUserEmailFromPrefs();
    await db.update(
      'songs',
      {
        'favorite': favorite ? 1 : 0,
        'noteReview': review,
        'rating': rating,
        'updatedAt': currentTime,
        'artUri': artUri.toString(),
      },
      where: 'idx = ? AND userEmail = ?',
      whereArgs: [idx, userEmail],
    );
  }

  Future<void> updateIsDownloaded(int idx, bool isDownloaded) async {
    final db = await database;
    final userEmail = await getUserEmailFromPrefs();
    await db.update(
      'songs',
      {
        'isDownloaded': isDownloaded ? 1 : 0,
      },
      where: 'idx = ? AND userEmail = ?',
      whereArgs: [idx, userEmail],
    );
  }

  Stream<Map<String, dynamic>?> watchSongDetailsByIdx(int idx) async* {
    final db = await database;
    final userEmail = await getUserEmailFromPrefs();

    yield* Stream.periodic(Duration(seconds: 1), (_) async {
      final List<Map<String, dynamic>> maps = await db.query(
        'songs',
        where: 'idx = ? AND userEmail = ?',
        whereArgs: [idx, userEmail],
      );
      if (maps.isNotEmpty) {
        final details = maps.first;
        return details;
      } else {
        return null;
      }
    }).asyncMap((event) async => await event);
  }

  /*
  Future<void> updateSongFavoriteStatus(int idx, bool favorite) async {
    final db = await database;
    final userEmail = await getUserEmailFromPrefs();

    await db.update(
      'songs',
      {
        'favorite': favorite ? 1 : 0,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'idx = ? AND userEmail = ?',
      whereArgs: [idx, userEmail],
    );
    debugPrint("음원의 좋아요 상태가 업데이트되었습니다. (idx=$idx, favorite=$favorite)");
  }
  */

  /// 파일 경로를 업데이트하고, 업데이트 날짜를 현재 시간으로 설정합니다.
  Future<void> updateFilePath(int songIdx, String newPath) async {
    final db = await database;
    await db.update(
      'file_paths',
      {
        'filePath': newPath,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'songIdx = ?',
      whereArgs: [songIdx],
    );
  }

  /// 파일 경로를 삽입하고, 생성 날짜와 업데이트 날짜를 현재 시간으로 설정합니다.
  Future<void> insertFilePath(int songIdx, String filePath) async {
    final db = await database;
    await db.insert(
      'file_paths',
      {
        'songIdx': songIdx,
        'filePath': filePath,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint("파일 경로가 삽입되었습니다. (songIdx=$songIdx, filePath=$filePath)");
  }

  /// songIdx를 이용해 file_paths 테이블에서 파일 경로 데이터를 조회합니다.
  Future<Map<String, dynamic>?> getFilePathBySongIdx(int songIdx) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'file_paths',
      where: 'songIdx = ?',
      whereArgs: [songIdx],
    );

    if (maps.isNotEmpty) {
      final filePath = maps.first;
      // debugPrint("파일 경로 정보 (songIdx=$songIdx): $filePath");
      return filePath;
    } else {
      // debugPrint("파일 경로 정보를 찾을 수 없습니다 (songIdx=$songIdx)");
      return null;
    }
  }

  Stream<int> watchFavoriteSongsCount() async* {
    final db = await database;
    final userEmail = await getUserEmailFromPrefs();

    yield* Stream.periodic(Duration(seconds: 1), (_) async {
      final result = await db.rawQuery(
        '''
        SELECT COUNT(*) as count FROM songs WHERE userEmail = ? AND favorite = 1
        ''',
        [userEmail],
      );
      final count = result.isNotEmpty ? result[0]['count'] as int : 0;
      return count;
    }).asyncMap((event) async => await event);
  }
}