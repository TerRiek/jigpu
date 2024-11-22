import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'; // 캐시 매니저 추가
import 'package:sqflite/sqflite.dart';  // SQLite 데이터베이스 관리

// 커스텀 FIFO 캐시 매니저 클래스 (FIFO 삭제 정책 구현)
class FifoCacheManager {
  static const String key = 'MusicCacheKey';
  static FifoCacheManager? _instance;
  static const int maxCacheSizeInBytes = 4 * 1024 * 1024 * 1024; // 4GB
  static Database? _database; // 데이터베이스 인스턴스

  // Singleton 방식으로 캐시 매니저 생성
  factory FifoCacheManager() {
    _instance ??= FifoCacheManager._();
    return _instance!;
  }

  FifoCacheManager._();

  final CacheManager cacheManager = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 60), // 2개월
      maxNrOfCacheObjects: 1000, // 최대 파일 수를 설정, 약 4GB에 해당
    ),
  );

  // 캐시 디렉토리 경로 가져오기
  Future<String> getCacheDirectoryPath() async {
    final cacheDirectory = await getTemporaryDirectory();
    final cachePath = '${cacheDirectory.path}/$key';
    debugPrint('캐시 디렉토리 경로: $cachePath');
    return cachePath;
  }

  // 데이터베이스 초기화
  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/music_cache.db';

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE file_cache (
            cacheId INTEGER PRIMARY KEY AUTOINCREMENT,
            songIdx INTEGER,
            filePath TEXT,
            fileSize INTEGER,
            createdAt TEXT,
            updatedAt TEXT
          )
        ''');
      },
    );
  }

  // 캐시에 파일 정보 저장
  Future<void> _insertFileIntoCache(int songIdx, String filePath, int fileSize) async {
    final db = await _database;
    final currentTime = DateTime.now().toIso8601String();
    await db!.insert(
      'file_cache',
      {
        'songIdx': songIdx,
        'filePath': filePath,
        'fileSize': fileSize,
        'createdAt': currentTime,
        'updatedAt': currentTime,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('파일이 캐시에 저장되었습니다: $filePath');
  }

  // 캐시에서 파일 삭제
  Future<void> _removeFileFromCache(String filePath) async {
    final db = await _database;
    await db!.delete(
      'file_cache',
      where: 'filePath = ?',
      whereArgs: [filePath],
    );
    debugPrint('파일이 캐시에서 삭제되었습니다: $filePath');
  }

  // 캐시의 FIFO 정책을 구현하는 메서드
  Future<void> manageCache() async {
    await _initDatabase();
    final cacheDirPath = await getCacheDirectoryPath();
    final cacheDirectory = Directory(cacheDirPath);

    if (await cacheDirectory.exists()) {
      final cachedFiles = cacheDirectory.listSync();

      // 파일 크기 계산 및 파일 삭제 시작
      int currentCacheSize = cachedFiles.fold<int>(0, (sum, file) {
        if (file is File) {
          final fileSize = file.lengthSync();
          debugPrint('파일: ${file.path}, 크기: $fileSize 바이트');
          return sum + fileSize; // 각 파일의 크기를 더함
        }
        return sum;
      });

      // 캐시가 최대 크기를 초과하면 오래된 파일부터 삭제 (FIFO)
      if (currentCacheSize > maxCacheSizeInBytes) {
        debugPrint('캐시가 최대 크기를 초과했습니다. 오래된 파일부터 삭제를 시작합니다.');

        // 파일을 마지막으로 수정된 시간에 따라 오래된 파일부터 정렬
        cachedFiles.sort((a, b) {
          if (a is File && b is File) {
            return a.lastModifiedSync().compareTo(b.lastModifiedSync());
          }
          return 0;
        });

        // FIFO 방식으로 캐시 삭제
        for (var file in cachedFiles) {
          if (file is File) {
            if (currentCacheSize <= maxCacheSizeInBytes) break;
            final fileSize = file.lengthSync();
            await _removeFileFromCache(file.path);  // 캐시 테이블에서도 파일 삭제
            await file.delete();  // 실제 파일 삭제
            currentCacheSize -= fileSize;
            debugPrint('FIFO 삭제: ${file.path}, 삭제된 크기: $fileSize 바이트');
          }
        }
      }
    } else {
      debugPrint('캐시 디렉토리가 존재하지 않습니다.');
    }

    debugPrint('캐시 관리 작업이 완료되었습니다.');
  }
}
