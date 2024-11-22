// import 'dart:convert';
//
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:jigpu_1/config/config_base_domain.dart';
// import 'package:jigpu_1/config/config_service.dart';
// import 'package:jigpu_1/models/data_view_model.dart';
// import 'package:jigpu_1/models/list_data_model.dart';
// import 'package:jigpu_1/models/reviews/review_model.dart';
// import 'package:jigpu_1/models/song_model.dart';
// import 'package:jigpu_1/utils/components/cache/component_cache_data.dart';
// import 'package:jigpu_1/utils/gen/assets.gen.dart';
// import 'package:jigpu_1/utils/sqflite/database_helper_playlist.dart';
//
// part 'service_music.dart';
//
// abstract class IServiceMusic {
//   final api = ConfigService.instant.init();
//
//   Future<List<DataViewModel>> getAllSongTest();
//   Future<ListDataModel<DataViewModel>?> getAllSingleAlbum();
//   Future<ListDataModel<DataViewModel>?> getAllFullAlbum();
//   Future<ListDataModel<DataViewModel>?> getAllEpAlbum();
//   Future getAllAlbumHome(int step);
//   Future getAllSearch({
//     String? keyword,
//     int? speed,
//     int? beat,
//     int? electronic,
//     int? vocal,
//     dynamic act,
//     dynamic tendency,
//     dynamic religion,
//     int? instrument,
//     dynamic era,
//     int? play,
//     dynamic stype,
//     int? emotion,
//     int? pop,
//   });
//
//   ///```dart
//   ///{
//   ///   "list": List<DataViewModel>,
//   ///   "details_data": DataViewModel,
//   ///   "song_list": List<DataViewModel>,
//   ///}
//   ///```
//   Future getDetailAlbum({required int idx});
//
//   Future writeReview({required String comment, required int score, required int idx});
//   Future<List<ReviewModel>> getListReview({required int idx});
//   Future addBookmark({required int idx});
//   Future deleteBookmark({required int idx});
//   Future listBookmark();
//   Future updatePlaylist({required dynamic playlist});
//   Future getPlaylist();
//
//   Future getPlaylistAirplane({required String playlistName});
//
//
// }
