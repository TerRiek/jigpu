import 'dart:async';

// import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jigpu_1/models/data_view_model.dart';
// import 'package:jigpu_1/models/news/news_model.dart';
import 'package:jigpu_1/services/musics/i_service_music.dart';
// import 'package:jigpu_1/services/news/i_service_news.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../utils/db_helper/albums/database_helper_album.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final dbHelper = DatabaseHelperAlbum.instance;
  HomeBloc() : super(HomeInitial()) {
    on<HomeEventChangeIndex>(_onHomeEventChangeIndexPage);
    // on<HomeEventInitData>(_onHomeEventInitData);
    // on<HomeEventGetAllSongs>(_onHomeEventGetAllSongs);
    // on<HomeEventGetAllAlbum>(_onHomeEventGetAllAlbum);
    // on<HomeEventGetAllArtist>(_onHomeEventGetAllArtist);
    // on<HomeEventGetAllAlbumHome>(_onHomeEventGetAllAlbumHome);
  }

  // IServiceMusic serviceMusic = ServiceMusic();
  // IServiceNews serviceNews = ServiceNews();
  HomeStateGetAllAlbumHome stateCurrent = HomeStateGetAllAlbumHome();

  FutureOr<void> _onHomeEventChangeIndexPage(HomeEventChangeIndex event, Emitter<HomeState> emit) {
    emit(HomeStateChangeIndexState(indexCurrent: event.index, subIndexCurrent: event.subIndex));
  }

  // FutureOr<void> _onHomeEventGetAllSongs(HomeEventGetAllSongs event, Emitter<HomeState> emit) async {
  //   debugPrint("현재 위치 : HomeBloc _onHomeEventGetAllSongs");
  //   final data = await serviceMusic.getAllSingleAlbum();
  //   emit(HomeStateGetAllSongsState(listData: data?.list ?? []));
  // }

  // FutureOr<void> _onHomeEventGetAllAlbum(HomeEventGetAllAlbum event, Emitter<HomeState> emit) async {
  //   debugPrint("현재 위치 : HomeBloc _onHomeEventGetAllAlbum");
  //   final data = await serviceMusic.getAllEpAlbum();
  //   emit(HomeStateGetAllAlbumsState(listData: data?.list ?? []));
  // }

  // FutureOr<void> _onHomeEventGetAllArtist(HomeEventGetAllArtist event, Emitter<HomeState> emit) async {
  //   debugPrint("현재 위치 : HomeBloc _onHomeEventGetAllArtist");
  //   final data = await serviceMusic.getAllFullAlbum();
  //   emit(HomeStateGetAllArtistsState(listData: data?.list ?? []));
  // }

  // FutureOr<void> _onHomeEventInitData(HomeEventInitData event, Emitter<HomeState> emit) async {
  //   try {
  //     List<NewsModel> listNews = [];
  //     try {
  //       List<NewsModel> listData = [];
  //       Response result = await serviceNews.getListNews(page: 1);
  //       if (result.data['code'] == '000') {
  //         listData = List.from((result.data['list'] as List).map((e) => NewsModel.fromJson(e)));
  //       }
  //       listNews = listData.length > 5 ? listData.sublist(0, 5) : listData;
  //       emit(HomeStateInit(listDataNews: listNews));
  //     } catch (e) {
  //       debugPrint("ERROR===> $e");
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // FutureOr<void> _onHomeEventGetAllAlbumHome(HomeEventGetAllAlbumHome event, Emitter<HomeState> emit) async {
  //   try {
  //     var connectivityResult = await (Connectivity().checkConnectivity());  // 현재 인터넷 상태 확인
  //
  //     debugPrint("-------------------------------- 현재 ep_albums 데이터 가져오기 --------------------------------");
  //     if (connectivityResult == ConnectivityResult.none) {
  //       final localData = await dbHelper.getAlbumsFromDatabase('ep_albums');
  //       if (localData != null && localData.list != null) {
  //         debugPrint("ep_albums 데이터 가져오기 -> ${localData.list.toString()}");
  //         stateCurrent = stateCurrent.copyWith(listSmall: localData.list);
  //       } else {
  //         debugPrint("ep_albums 데이터가 데이터베이스에 없습니다.");
  //       }
  //     } else {
  //       final value = await serviceMusic.getAllAlbumHome(1);
  //       if (value != null && value.list != null) {
  //         debugPrint("서버에서 가져온 ep_albums 데이터 -> ${value.list.toString()}");
  //         stateCurrent = stateCurrent.copyWith(listSmall: value.list);
  //
  //         for (var album in value.list) {
  //           await dbHelper.insertAlbum('ep_albums', album.toMap());
  //           debugPrint("ep_albums 데이터 삽입 -> ${album.toMap().toString()}");
  //         }
  //         debugPrint("ep_albums 데이터 저장 완료 -> ${await dbHelper.getAlbumsFromDatabase('ep_albums')}");
  //       } else {
  //         debugPrint("서버에서 가져온 ep_albums 데이터가 null입니다.");
  //       }
  //     }
  //
  //     emit(stateCurrent);
  //
  //     debugPrint("-------------------------------- 현재 single_albums 데이터 가져오기 --------------------------------");
  //     if (connectivityResult == ConnectivityResult.none) {
  //       final localData = await dbHelper.getAlbumsFromDatabase('single_albums');
  //       if (localData != null && localData.list != null) {
  //         debugPrint("single_albums 데이터 가져오기 -> ${localData.list.toString()}");
  //         stateCurrent = stateCurrent.copyWith(listMedium: localData.list);
  //       } else {
  //         debugPrint("single_albums 데이터가 데이터베이스에 없습니다.");
  //       }
  //     } else {
  //       final value = await serviceMusic.getAllAlbumHome(2);
  //       if (value != null && value.list != null) {
  //         stateCurrent = stateCurrent.copyWith(listMedium: value.list);
  //
  //         for (var album in value.list) {
  //           await dbHelper.insertAlbum('single_albums', album.toMap());
  //           debugPrint("single_albums 데이터 삽입 -> ${album.toMap().toString()}");
  //         }
  //         debugPrint("single_albums 저장 완료 -> ${await dbHelper.getAlbumsFromDatabase('single_albums')}");
  //       } else {
  //         debugPrint("서버에서 가져온 single_albums 데이터가 null입니다.");
  //       }
  //     }
  //
  //     emit(stateCurrent);
  //
  //     debugPrint("-------------------------------- 현재 full_albums 데이터 가져오기 --------------------------------");
  //     if (connectivityResult == ConnectivityResult.none) {
  //       final localData = await dbHelper.getAlbumsFromDatabase('full_albums');
  //       if (localData != null && localData.list != null) {
  //         debugPrint("full_albums 데이터 가져오기 -> ${localData.list.toString()}");
  //         stateCurrent = stateCurrent.copyWith(listBiggest: localData.list);
  //       } else {
  //         debugPrint("full_albums 데이터가 데이터베이스에 없습니다.");
  //       }
  //     } else {
  //       final value = await serviceMusic.getAllAlbumHome(3);
  //       if (value != null && value.list != null) {
  //         stateCurrent = stateCurrent.copyWith(listBiggest: value.list);
  //
  //         for (var album in value.list) {
  //           await dbHelper.insertAlbum('full_albums', album.toMap());
  //           debugPrint("full_albums 데이터 삽입 -> ${album.toMap().toString()}");
  //         }
  //         debugPrint("full_albums 저장 완료 -> ${await dbHelper.getAlbumsFromDatabase('full_albums')}");
  //       } else {
  //         debugPrint("서버에서 가져온 full_albums 데이터가 null입니다.");
  //       }
  //     }
  //
  //     emit(stateCurrent);
  //
  //   } catch (e) {
  //     debugPrint("Error fetching albums: $e");
  //     rethrow;
  //   }
  // }
}