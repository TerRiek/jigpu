// import 'dart:async';
//
// import 'package:audio_service/audio_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:jigpu_1/models/song_model.dart';
// import 'package:jigpu_1/services/musics/i_service_music.dart';
//
// part 'song_event.dart';
// part 'song_state.dart';
//
// class SongBloc extends Bloc<SongEvent, SongState> {
//   SongBloc() : super(SongInitial()) {
//     on<SongEventGetSongRecommend>(_onSongEventGetSongRecommend);
//     on<SongEventWriteReview>(_onSongEventWriteReview);
//     on<SongEventFavorite>(_onSongEventFavorite);
//   }
//
//   // final IServiceMusic _serviceMusic = ServiceMusic();
//   //
//   FutureOr<void> _onSongEventGetSongRecommend(SongEventGetSongRecommend event, Emitter<SongState> emit) async {
//     // final listData = await _serviceMusic.getAllSongTest();
//     // listData.removeWhere((element) => element.song?.artUri.toString() == event.data.artUri.toString());
//     // emit(SongStateGetSongRecommend(listData.map((e) => e.song!).toList()));
//     emit(SongStateGetSongRecommend(const []));
//   }
//
//   FutureOr<void> _onSongEventWriteReview(SongEventWriteReview event, Emitter<SongState> emit) async {
//     try {
//       final response = await _serviceMusic.writeReview(comment: event.comment, score: event.score, idx: event.idx);
//       if (response != null) {
//         emit(SongStateWriteReview(success: true));
//       } else {
//         emit(SongStateWriteReview(success: false));
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   FutureOr<void> _onSongEventFavorite(SongEventFavorite event, Emitter<SongState> emit) async {
//     try {
//       dynamic response;
//       if (event.type == TypeFavorite.add) {
//         response = await _serviceMusic.addBookmark(idx: event.idx);
//       } else {
//         response = await _serviceMusic.deleteBookmark(idx: event.idx);
//       }
//       if (response != null) {
//         emit(SongStateWriteReview(success: true));
//       } else {
//         emit(SongStateWriteReview(success: false));
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
