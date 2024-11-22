import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../../models/data_view_model.dart';
import '../../../models/list_data_model.dart';

class DatabaseHelperAlbum {
  static final DatabaseHelperAlbum instance = DatabaseHelperAlbum._init();

  static Database? _database;

  DatabaseHelperAlbum._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('album_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT';
    const integerType = 'INTEGER';

    await db.execute('''
    CREATE TABLE ep_albums (
      idx $idType,
      title $textType,
      title_en $textType,
      name $textType,
      name_en $textType,
      image0 $textType,
      artist $textType,
      artist_en $textType,
      artist_image $textType,
      release_date $textType,
      no $integerType,
      length $integerType,
      music0 $textType,
      playlistName $textType
    )
  ''');

    await db.execute('''
    CREATE TABLE full_albums (
      idx $idType,
      title $textType,
      title_en $textType,
      name $textType,
      name_en $textType,
      image0 $textType,
      artist $textType,
      artist_en $textType,
      artist_image $textType,
      release_date $textType,
      no $integerType,
      length $integerType,
      music0 $textType,
      playlistName $textType
    )
  ''');

    await db.execute('''
    CREATE TABLE single_albums (
      idx $idType,
      title $textType,
      title_en $textType,
      name $textType,
      name_en $textType,
      image0 $textType,
      artist $textType,
      artist_en $textType,
      artist_image $textType,
      release_date $textType,
      no $integerType,
      length $integerType,
      music0 $textType,
      playlistName $textType
    )
  ''');
  }

  Future<int> insertAlbum(String table, Map<String, dynamic> data) async {
    final db = await instance.database;

    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace, // 충돌 발생 시 데이터 교체
    );
  }


  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // SQLite에서 데이터를 가져오는 함수
  Future<ListDataModel<DataViewModel>?> getAlbumsFromDatabase(String table) async {
    final dbHelper = DatabaseHelperAlbum.instance;
    final List<Map<String, dynamic>> albumMaps = await dbHelper.queryAllRows(table);

    if (albumMaps.isNotEmpty) {
      final List<DataViewModel> albums = albumMaps.map((map) => DataViewModel.fromMap(map)).toList();
      final reversedAlbums = albums.reversed.toList(); // 리스트의 순서를 거꾸로 변경
      return ListDataModel<DataViewModel>(list: reversedAlbums);
    } else {
      return null;
    }
  }

  // 테이블에서 모든 데이터 조회
  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    final db = await database;
    return await db.query(table);
  }
}