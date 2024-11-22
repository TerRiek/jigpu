import 'package:jigpu_1/models/data_view_model.dart';
import 'package:jigpu_1/models/song_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelperPlaylist {
  static final DatabaseHelperPlaylist instance = DatabaseHelperPlaylist._init();
  static Database? _database;

  DatabaseHelperPlaylist._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sqflite_playlist.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB,
      onOpen: (db) async {
        // 데이터베이스가 열릴 때마다 테이블 존재 여부 확인
        if (!(await isTableExists(db, 'dataViewPlaylist'))) {
          print("dataViewPlaylist 테이블 재생성");
          await _createDB(db, 1);
        }
        if(!(await isTableExists(db, 'song'))) {
          print("song 테이블 재생성");
          await _createDBSong(db, 1);
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE dataViewPlaylist(
      idx INTEGER,
      title TEXT,
      titleEn TEXT,
      name TEXT,
      nameEn TEXT,
      image0 TEXT,
      artist TEXT,
      artistEn TEXT,
      artistImage TEXT,
      releaseDate TEXT,
      entertainment TEXT,
      no INTEGER,
      length INTEGER,
      music0 TEXT,
      playlistName TEXT,
      albumKo TEXT,
      publishDate TEXT,
      songTime TEXT,
      albumCode TEXT,
      song TEXT,
      songCode TEXT PRIMARY KEY
    )
    ''');
  }

  Future _createDBSong(Database db, int version) async {
    await db.execute('''
    CREATE TABLE song (
      idx INTEGER DEFAULT -1,
      id TEXT,
      title TEXT,
      artist TEXT,
      artUri TEXT,
      duration INTEGER,
      songRating INTEGER DEFAULT 0,
      playlistName TEXT,
      image0 TEXT,
      songCode TEXT PRIMARY KEY,
      favorite INTEGER DEFAULT 0,
      noteReview TEXT,
      rating INTEGER,
      userEmail TEXT,
      createdAt TEXT,
      updatedAt TEXT 
    )
    ''');
  }

  Future<List<DataViewModel>?> getItems(String playlistName) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> songMaps = await db.query(
      "song",
      where: 'playlistName = ?',
      whereArgs: [playlistName],
    );
    print("in getItems - songMaps : ${songMaps.length}, $playlistName");

    List<SongModel> songList = List.generate(songMaps.length, (i) {
      return SongModel(
        idx: songMaps[i]['idx'] ?? -1,
        id: songMaps[i]['id'] ?? "",
        title: songMaps[i]['title'] ?? "",
        artist: songMaps[i]['artist'] ?? "",
        artUri: Uri.parse(songMaps[i]['artUri'] ?? ""),
        duration: Duration(milliseconds: songMaps[i]['duration'] ?? 0),
        playlistName: songMaps[i]['playlistName'] ?? "",
        songRating: songMaps[i]['songRating'] ?? 0,
        // You can add more fields if needed
      )..setSongCode(songMaps[i]['songCode'])
        ..setFavorite(songMaps[i]['favorite'] ?? 0);
    });
    print("songList in getItems : $songList");
    //======================================================

    final List<Map<String, dynamic>> maps = await db.query(
      "dataViewPlaylist",
      where: 'playlistName = ?',
      whereArgs: [playlistName],
    );

    print("in getItems - dataViewMaps : ${maps.length}, $playlistName");

    return List.generate(maps.length, (i) {
      DataViewModel temp = DataViewModel(
        idx: maps[i]['idx'] ?? -1,
        title: maps[i]['title'] ?? "",
        titleEn: maps[i]['titleEn'] ?? "",
        image0: maps[i]['image0'] ?? "",
        artist: maps[i]['artist'] ?? "",
        artistEn: maps[i]['artistEn'] ?? "",
        no: maps[i]['no'] ?? 0,
        song: songList[i],
      );
      temp.setName(maps[i]['name'] ?? "");
      temp.setSongTime(maps[i]['songTime'] ?? "");
      temp.setEntertainment(maps[i]['entertainment'] ?? "");
      temp.setPublishDate(maps[i]['publishDate'] ?? "");
      temp.setPlaylistName(maps[i]['playlistName'] ?? "");
      temp.setAlbumCode(maps[i]['albumCode'] ?? "");
      temp.setSongCode(maps[i]['songCode'] ?? "");

      return temp;
    });
  }

  //db와 무관계
  DataViewModel generateDataViewModel({String id = "", String title = "", String artist = "", Uri? artUri, Duration? duration, String playlistName = "", int songRating = 0, String songCode = "", int favorite = 0}) {
    SongModel songValue = SongModel(
      idx: -1,
      id: id,
      title: title,
      artist: artist,
      artUri: artUri,
      duration: duration,
      playlistName: playlistName,
      songRating: songRating,
      // noteReview: maps[i]['noteReview'],
      // rating: maps[i]['rating'],
      // userEmail: maps[i]['userEmail'],
      // createdAt: DateTime.parse(maps[i]['createdAt']),
      // updatedAt: DateTime.parse(maps[i]['updatedAt']),
    );
    songValue.setSongCode(songCode);
    songValue.setFavorite(favorite); //0 or 1

    DataViewModel rtValue = DataViewModel(
      title: title.trim(),
      artist: artist.trim(),
      //artistEn: artistEn.trim(),
      image0: "https://avatar-ex-swe.nixcdn.com/playlist/2023/02/14/d/d/b/8/1676351753231_500.jpg",
      song: songValue,
    );
    // rtValue.setAlbum(albumKo);
    // rtValue.setPublishDate(date);
    // rtValue.setSongTime(duration);
    // rtValue.setAlbumCode(albumCode);
    rtValue.setSongCode(songCode);
    rtValue.setPlaylistName(playlistName);

    return rtValue;
  }

  Future<int> insertItem(String table, DataViewModel data) async {
    print("inserted item - Table dataViewModel : $data");

    //song 테이블에 데이터 추가
    await insertItemSong(dataViewModelToSongModel(data));

    final db = await instance.database;
    return await db.transaction((txn) async {
      var map = data.toMapForSqflite();
      print("map before insert - Table dataViewModel : $map");
      map['song'] = '';
      return await txn.insert(
        table,
        map,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    });
  }

  Future<int> insertItemSong(SongModel data) async {
    print("inserted item - Table song : $data");

    final db = await instance.database;
    return await db.transaction((txn) async {
      var map = data.toMapForSqflite();
      print("map before insert - Table song : $map");
      var newMap = Map<String, dynamic>.from(map);

      // Duration을 문자열로 변경
      newMap['duration'] = data.duration?.inMilliseconds.toString();

      return await txn.insert(
        "song",
        newMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    });
  }

  Future<List<SongModel>> getAllSongs() async {
    print("in getAllSongs");
    final db = await instance.database;
    print("in getAllSongs - db");

    final List<Map<String, dynamic>> maps = await db.query('dataViewPlaylist');
    print("in getAllSongs - map");

    return List.generate(maps.length, (i) {
      return SongModel(
        idx: maps[i]['idx'] ?? -1,
        id: maps[i]['id'] ?? "",
        title: maps[i]['title'] ?? "",
        artist: maps[i]['artist'] ?? "",
        artUri: maps[i]['artUri'] ?? Uri.parse(""),
        duration: maps[i]['duration'] ?? const Duration(),
        playlistName: maps[i]['playlistName'] ?? "",
        songRating: maps[i]['songRating'] ?? "",
        // noteReview: maps[i]['noteReview'],
        // rating: maps[i]['rating'],
        // userEmail: maps[i]['userEmail'],
        // createdAt: maps[i]['createdAt'] != null ? DateTime.parse(maps[i]['createdAt']) : null,
        // updatedAt: maps[i]['updatedAt'] != null ? DateTime.parse(maps[i]['updatedAt']) : null,
      )..setSongCode(maps[i]['songCode'])
        ..setFavorite(0);
    });
  }

  Future<int> getSongsCount() async {
    final db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM dataViewPlaylist')) ?? 0;
  }

  Future<void> deleteDataViewTable() async {
    final db = await instance.database;
    await db.execute('DROP TABLE IF EXISTS dataViewPlaylist');
    print('dataViewPlaylist 테이블이 삭제되었습니다.');
  }

  Future<void> deleteSongTable() async {
    final db = await instance.database;
    await db.execute('DROP TABLE IF EXISTS song');
    print('song 테이블이 삭제되었습니다.');
  }

  Future<bool> isTableExists(Database db, String tableName) async {
    var tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'"
    );
    return tables.isNotEmpty;
  }

  ///dataViewModel을 입력하면 동일한 데이터를 가지는 SongModel을 반환
  SongModel dataViewModelToSongModel(DataViewModel data) {
    SongModel songModel = SongModel(
      idx: data.idx ?? -1,
      id: data.song?.id ?? '',
      title: data.title ?? '',
      artist: data.artist ?? '',
      artUri: Uri.parse(data.image0 ?? ''),
      duration: data.song?.duration ?? Duration.zero,
      playlistName: data.playlistName,
    );

    // SongModel의 추가 필드 설정
    songModel.songRating = data.song?.songRating ?? 0;
    songModel.image0 = data.image0;
    songModel.songCode = data.songCode;
    songModel.favorite = data.song?.favorite ?? 0;

    return songModel;
  }
}