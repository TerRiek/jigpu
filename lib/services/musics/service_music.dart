// part of './i_service_music.dart';
//
// class ServiceMusic extends IServiceMusic {
//   @override
//   Future<List<DataViewModel>> getAllSongTest() async {
//     return [
//       DataViewModel(
//           title: "Shopper",
//           artist: "IU",
//           image0: "https://avatar-ex-swe.nixcdn.com/song/2024/02/20/9/7/d/e/1708425396789_500.jpg",
//           song: SongModel(
//             id: 'https://drive.usercontent.google.com/u/0/uc?id=1hid36awUAxK5AxZbpNH0AaVXlKFQrAHR&export=download',
//             title: "Shopper",
//             artist: "IU",
//             duration: const Duration(minutes: 3, seconds: 36),
//             artUri: Uri.parse('https://avatar-ex-swe.nixcdn.com/song/2024/02/20/9/7/d/e/1708425396789_500.jpg'),idx: -1,
//           )),
//       DataViewModel(
//           title: "Khi Người Mình Yêu Khóc",
//           artist: "Phan Mạnh Quỳnh",
//           image0: 'https://avatar-ex-swe.nixcdn.com/playlist/2016/01/13/8/1/5/5/1452661529166_500.jpg',
//           song: SongModel(
//             id: 'https://drive.usercontent.google.com/u/0/uc?id=1ShKat1DxlIWMDQEb4RQIXV8yh2bB_vt6&export=download',
//             title: "Khi Người Mình Yêu Khóc",
//             artist: "Phan Mạnh Quỳnh",
//             duration: const Duration(minutes: 3, seconds: 43),
//             artUri: Uri.parse('https://avatar-ex-swe.nixcdn.com/playlist/2016/01/13/8/1/5/5/1452661529166_500.jpg'),idx: -1,
//           )),
//       DataViewModel(
//           title: "Cho Tôi Lang Than",
//           artist: "Ngọt, Đen",
//           image0: "https://avatar-ex-swe.nixcdn.com/playlist/2023/02/14/d/d/b/8/1676351753231_500.jpg",
//           song: SongModel(
//             // id: 'https://drive.usercontent.google.com/u/0/uc?id=1JvVTspI8jPUHDeUj3MS14IIBTPCCP4cy&export=download',
//             id: 'https://drive.usercontent.google.com/u/0/uc?id=1JvVTspI8jPUHDeUj3MS14IIBTPCCP4cy&export=download',
//             title: "Cho Tôi Lang Than",
//             artist: "Ngọt, Đen",
//             duration: const Duration(minutes: 4, seconds: 19),
//             artUri: Uri.parse('https://avatar-ex-swe.nixcdn.com/playlist/2023/02/14/d/d/b/8/1676351753231_500.jpg'),idx: -1,
//           )),
//       DataViewModel(
//           title: "Gieo Que",
//           artist: "HoangThuyLinh Feat Den",
//           image0: "https://avatar-ex-swe.nixcdn.com/song/2021/12/31/5/e/3/2/1640937980335_500.jpg",
//           song: SongModel(
//             id: 'https://drive.usercontent.google.com/u/0/uc?id=1P-vA8l6leIxEGnGY5i2lyExORlBpCIOX&export=download',
//             title: "Gieo Que",
//             artist: "HoangThuyLinh Feat Den",
//             duration: const Duration(minutes: 3, seconds: 19),
//             artUri: Uri.parse('https://avatar-ex-swe.nixcdn.com/song/2021/12/31/5/e/3/2/1640937980335_500.jpg'),idx: -1,
//           )),
//       DataViewModel(
//           artist: "Bạch Tuyết, Nal",
//           title: "Cô Ba Ca Cổ",
//           image0: "https://avatar-ex-swe.nixcdn.com/playlist/2023/04/18/3/e/2/b/1681788974565_500.jpg",
//           song: SongModel(
//             id: 'https://drive.usercontent.google.com/u/0/uc?id=1L74aPU8Mg4xlliDyWOrDX5A5C1Q5n7Xc&export=download',
//             title: "Cô Ba Ca Cổ",
//             artist: "Bạch Tuyết, Nal",
//             duration: const Duration(minutes: 4, seconds: 13),
//             artUri: Uri.parse('https://avatar-ex-swe.nixcdn.com/playlist/2023/04/18/3/e/2/b/1681788974565_500.jpg'),idx: -1,
//           )),
//       DataViewModel(
//           title: "Galz Xypher - XG",
//           artist: "XG",
//           image0: "https://avatar-ex-swe.nixcdn.com/song/2023/03/21/5/5/b/2/1679387716471_500.jpg",
//           song: SongModel(
//             id: 'https://drive.usercontent.google.com/u/0/uc?id=1zXhOah8p60cAgYbsNUVlQxhj_Ev-bYLZ&export=download',
//             title: "Galz Xypher - XG",
//             artist: "XG",
//             duration: const Duration(minutes: 5, seconds: 39),
//             artUri: Uri.parse('https://avatar-ex-swe.nixcdn.com/song/2023/03/21/5/5/b/2/1679387716471_500.jpg'),idx: -1,
//           )),
//       DataViewModel(
//           title: "Run Run",
//           artist: "PROWDMON, LAS",
//           image0: "https://avatar-ex-swe.nixcdn.com/song/2022/12/29/e/e/f/b/1672303146880_500.jpg",
//           song: SongModel(
//             id: 'https://drive.usercontent.google.com/u/0/uc?id=12_GU627jnHHxmpSdTMeqYj_-ETymkb70&export=download',
//             title: "Run Run",
//             artist: "PROWDMON, LAS",
//             duration: const Duration(minutes: 2, seconds: 48),
//             artUri: Uri.parse('https://avatar-ex-swe.nixcdn.com/song/2022/12/29/e/e/f/b/1672303146880_500.jpg'), idx: -1,
//           )),
//     ];
//   }
//
//   // 요청 발생 시 로그 출력
//   void _logRequest(RequestOptions options) {
//     debugPrint('리퀘스트 [${options.method}] ${options.uri}');
//   }
//   @override
//   Future<ListDataModel<DataViewModel>?> getAllEpAlbum() async {
//     try {
//
//       // 요청 전에 로그 출력
//       api.interceptors.add(InterceptorsWrapper(
//         onRequest: (options, handler) {
//           _logRequest(options);
//           return handler.next(options);
//         },
//       ));
//
//       Response result = await api.get('${ConfigBaseDomain.instant.baseDomain}/?_action=album&_plugin=keiser&_action_type=ep');
//       debugPrint("result: $result");
//       if (result.statusCode == 200) {
//         ListDataModel<DataViewModel>? data = ListDataModel.fromJson(result.data, DataViewModel());
//
//         return data;
//       } else {
//         _handleErrorStatusCode(result.statusCode);
//       }
//     } catch (e) {
//       if (e is DioError) {
//         _handleDioError(e);
//       }
//       return null;
//     }
//   }
//
//   @override
//   Future<ListDataModel<DataViewModel>?> getAllFullAlbum() async {
//     try {
//       // 요청 전에 로그 출력
//       api.interceptors.add(InterceptorsWrapper(
//         onRequest: (options, handler) {
//           _logRequest(options);
//           return handler.next(options);
//         },
//       ));
//       Response result = await api.get('${ConfigBaseDomain.instant.baseDomain}/?_action=album&_plugin=keiser&_action_type=full');
//
//       if (result.statusCode == 200) {
//         ListDataModel<DataViewModel>? data = ListDataModel.fromJson(result.data, DataViewModel());
//
//         return data;
//       } else {
//         _handleErrorStatusCode(result.statusCode);
//       }
//     } catch (e) {
//       if (e is DioError) {
//         _handleDioError(e);
//       }
//       return null;
//     }
//   }
//
//   @override
//   Future<ListDataModel<DataViewModel>?> getAllSingleAlbum() async {
//     try {
//       // 요청 전에 로그 출력
//       api.interceptors.add(InterceptorsWrapper(
//         onRequest: (options, handler) {
//           _logRequest(options);
//           return handler.next(options);
//         },
//       ));
//       Response result = await api.get('${ConfigBaseDomain.instant.baseDomain}/?_action=album&_plugin=keiser&_action_type=single');
//
//       if (result.statusCode == 200) {
//         ListDataModel<DataViewModel>? data = ListDataModel.fromJson(result.data, DataViewModel());
//
//         return data;
//       } else {
//         _handleErrorStatusCode(result.statusCode);
//
//       }
//     } catch (e) {
//       if (e is DioError) {
//         _handleDioError(e);
//       }
//       return null;
//     }
//   }
//
//
// // 상태 코드에 따른 예외 처리 함수
//   void _handleErrorStatusCode(int? statusCode) {
//     switch (statusCode) {
//       case 400:
//         throw Exception("잘못된 요청입니다. (400)");
//       case 401:
//         throw Exception("인증 오류입니다. (401)");
//       case 403:
//         throw Exception("접근이 금지되었습니다. (403)");
//       case 404:
//         throw Exception("리소스를 찾을 수 없습니다. (404)");
//       case 500:
//         throw Exception("서버 내부 오류입니다. (500)");
//       default:
//         throw Exception("알 수 없는 오류가 발생했습니다. (상태 코드: $statusCode)");
//     }
//   }
//
// // 네트워크 오류 처리 함수
//   void _handleDioError(DioError error) {
//     if (error.type == DioErrorType.connectionTimeout) {
//       throw Exception("연결 시간 초과입니다.");
//     } else if (error.type == DioErrorType.receiveTimeout) {
//       throw Exception("서버 응답 시간 초과입니다.");
//     } else {
//       _handleErrorStatusCode(error.response?.statusCode);
//       throw Exception("네트워크 오류가 발생했습니다. ${error.message}");
//     }
//   }
//
//
//   @override
//   Future getAllSearch({
//     String? keyword,
//     int? speed,
//     int? beat,
//     int? electronic,
//     int? vocal,
//     act,
//     tendency,
//     religion,
//     int? instrument,
//     era,
//     int? play,
//     stype,
//     int? emotion,
//     int? pop,
//   }) async {
//     try {
//       Response result = await api.get(ConfigBaseDomain.instant.baseDomain, queryParameters: {
//         "_action": "album",
//         "_plugin": "keiser",
//         "_action_type": "search",
//         "_keyword": keyword,
//         "_speed": speed, // 속도 조회 시 (0 ~ 5 중 하나),
//         "_beat": beat, // 비트 조회 시 (0 ~ 5 중 하나),
//         "_electronic": electronic, // 전자 조회 시 (0 ~ 5 중 하나),
//         "_vocal": vocal, // 보컬 조회 시 (0 ~ 5 중 하나),
//         "_act": act, // 행위 조회 시 (노래, 랩, 혼합 중 하나),
//         "_tendency": tendency, // 성향 조회 시 (일반, 내향 중 하나),
//         "_religion": religion, // 종교 조회 시 (크리스천, 불교 중 하나),
//         "_instrument": instrument, // 악기 조회 시 (0 ~ 5 중 하나),
//         "_era": era, //시대 조회 시 (현대, 고전서양, 고전동양 중 하나),
//         "_play": play, // 연주 조회 시 (0 ~ 5 중 하나),
//         "_stype": stype, // 스타일 조회 시 (팝, 록, 재즈 중 하나),
//         "_emotion": emotion, // 명암 조회 시 (0 ~ 5 중 하나),
//         "_pop": pop, // 대중 조회 시 (0 ~ 5 중 하나),
//       });
//       return {
//         'code': result.data['code'],
//         'artist_list': result.data["artist_list"],
//         'album_list': result.data["album_list"],
//         'song_list': result.data["song_list"],
//       };
//     } catch (e) {
//       if (e is DioError) {
//         rethrow;
//       }
//       return null;
//     }
//   }
//
//   @override
//   Future getAllAlbumHome(int step) async {
//     try {
//       switch (step) {
//         case 1:
//           Response small = await api.get(ConfigBaseDomain.instant.baseDomain, queryParameters: {
//             "_action": "album",
//             "_plugin": "keiser",
//             "_action_type": "ep",
//           });
//           final listData = ListDataModel.fromJson(small.data, DataViewModel());
//           return listData;
//         case 2:
//           Response medium = await api.get(ConfigBaseDomain.instant.baseDomain, queryParameters: {
//             "_action": "album",
//             "_plugin": "keiser",
//             "_action_type": "single",
//           });
//           final listData = ListDataModel.fromJson(medium.data, DataViewModel());
//           return listData;
//         case 3:
//           Response biggest = await api.get(ConfigBaseDomain.instant.baseDomain, queryParameters: {
//             "_action": "album",
//             "_plugin": "keiser",
//             "_action_type": "full",
//           });
//           final listData = ListDataModel.fromJson(biggest.data, DataViewModel());
//           return listData;
//         default:
//           return null;
//       }
//     } catch (e, stackTrace) {
//       debugPrint("Error in getAllAlbumHome: $e");
//       debugPrint("$stackTrace");
//       rethrow;
//     }
//     // try {
//     //   // biggest, medium, small
//     //   Response small = await api.get(ConfigBaseDomain.instant.baseDomain, queryParameters: {
//     //     "_action": "album",
//     //     "_plugin": "keiser",
//     //     "_action_type": "ep",
//     //   });
//     //   Response medium = await api.get(ConfigBaseDomain.instant.baseDomain, queryParameters: {
//     //     "_action": "album",
//     //     "_plugin": "keiser",
//     //     "_action_type": "single",
//     //   });
//     //   Response biggest = await api.get(ConfigBaseDomain.instant.baseDomain, queryParameters: {
//     //     "_action": "album",
//     //     "_plugin": "keiser",
//     //     "_action_type": "full",
//     //   });
//     //   final listSmall = ListDataModel.fromJson(small.data, DataViewModel());
//     //   final listMedium = ListDataModel.fromJson(medium.data, DataViewModel());
//     //   final listBiggest = ListDataModel.fromJson(biggest.data, DataViewModel());
//
//     //   return {
//     //     'listSmall': listSmall,
//     //     'listMedium': listMedium,
//     //     'listBiggest': listBiggest,
//     //   };
//     // } catch (e) {
//     //   return null;
//     // }
//   }
//
//   ///api의 response[code]가 '000'이 아니면
//   ///
//   ///list = [], detailsData = null, songList = null으로 반환한다
//   @override
//   Future getDetailAlbum({required int idx}) async {
//     try {
//       Response response = await api.get(ConfigBaseDomain.instant.baseDomain, queryParameters: {
//         "_action": "album",
//         "_plugin": "keiser",
//         "_action_type": "details",
//         "_idx": idx,
//       });
//       List<DataViewModel> list = [];
//       DataViewModel? detailsData;
//       List<DataViewModel>? songList;
//       if (response.data['code'] == '000') {
//         list = List<DataViewModel>.from((response.data['list'] as List).map((e) => DataViewModel.fromJson(e)));
//         detailsData = DataViewModel.fromJson(response.data['details_data']);
//         songList = List<DataViewModel>.from((response.data['song_list'] as List).map((e) => DataViewModel.fromJson(e)));
//       }
//       return {
//         'list': list,
//         'details_data': detailsData,
//         'song_list': songList,
//       };
//     } catch (e) {
//       return null;
//     }
//   }
//
//   @override
//   Future<List<ReviewModel>> getListReview({required int idx}) async {
//     try {
//       Response response = await api.get(ConfigBaseDomain.instant.baseDomain, queryParameters: {
//         "_action": "ps",
//         "_plugin": "keiser",
//         "_action_type": "review_list",
//         "_idx": idx,
//       });
//       debugPrint("xxxx==> $response");
//       if (response.data['code'] == '000' && response.data['list'] is List) {
//         final listData = (response.data['list'] as List).map((e) => ReviewModel.fromJson(e)).toList();
//         return listData;
//       }
//       return [];
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   @override
//   Future writeReview({required String comment, required int score, required int idx}) async {
//     try {
//       Response response = await api.get(ConfigBaseDomain.instant.baseDomain, queryParameters: {
//         "_action": "ps",
//         "_plugin": "keiser",
//         "_action_type": "review",
//         "_access_code": ComponentCacheData.instant.accessCode,
//         "_score": score,
//         "_comment": comment,
//         "_idx": idx,
//       });
//       debugPrint("xxxx==> $response");
//
//       if (response.data['code'] == '000') {
//         return response.data['details_data'];
//       }
//       return null;
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   @override
//   Future addBookmark({required int idx}) async {
//     try {
//       Response response = await api.get(ConfigBaseDomain.instant.baseDomain, queryParameters: {
//         "_action": "ps",
//         "_plugin": "keiser",
//         "_action_type": "bookmark",
//         "_access_code": ComponentCacheData.instant.accessCode,
//         "_idx": idx,
//       });
//       debugPrint("xxxx==> $response");
//       if (response.data['code'] == '000') {
//         return true;
//       }
//       return false;
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   @override
//   Future deleteBookmark({required int idx}) async {
//     try {
//       Response response = await api.get(ConfigBaseDomain.instant.baseDomain, queryParameters: {
//         "_action": "ps",
//         "_plugin": "keiser",
//         "_action_type": "bookmark_delete",
//         "_access_code": ComponentCacheData.instant.accessCode,
//         "_idx": idx,
//       });
//       debugPrint("xxxx==> $response");
//       if (response.data['code'] == '000') {
//         return true;
//       }
//       return false;
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   @override
//   Future getPlaylist() async {
//     try {
//       Response response = await api.get(ConfigBaseDomain.instant.baseDomain, queryParameters: {
//         "_action": "ps",
//         "_plugin": "keiser",
//         "_action_type": "playlist",
//         "_access_code": ComponentCacheData.instant.accessCode,
//       });
//       // if (response.data['code'] == '000' && response.data['list'] is List) {
//       //   final listData = (response.data['list'] as List).map((e) => DataViewModel.fromJson(e)).toList();
//       //   return listData;
//       // }
//       return response.data;
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   @override
//   Future getPlaylistAirplane({required String playlistName}) async {
//     try {
//       DatabaseHelperPlaylist db = DatabaseHelperPlaylist.instance;
//       List<DataViewModel>? playlistItems = await db.getItems(playlistName);
//
//       return playlistItems;
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   @override
//   Future listBookmark() async {
//     try {
//       Response response = await api.get(ConfigBaseDomain.instant.baseDomain, queryParameters: {
//         "_action": "ps",
//         "_plugin": "keiser",
//         "_action_type": "bookmark_list",
//         "_access_code": ComponentCacheData.instant.accessCode,
//       });
//       debugPrint("xxxx==> $response");
//       if (response.data['code'] == '000' && response.data['list'] is List) {
//         final listData = (response.data['list'] as List).map((e) => DataViewModel.fromJson(e)).toList();
//         return listData;
//       }
//       return [];
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   @override
//   Future updatePlaylist({required playlist}) async {
//     try {
//       Response response = await api.get(ConfigBaseDomain.instant.baseDomain, queryParameters: {
//         "_action": "ps",
//         "_plugin": "keiser",
//         "_action_type": "playlist_update",
//         "_access_code": ComponentCacheData.instant.accessCode,
//         "_playlist": jsonEncode(playlist),
//       });
//       return response.data;
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   @override
//   Future<SongModel?> getSongById(int idx) async {
//     // 특정 ID의 노래를 가져오는 로직
//     try {
//       Response response = await api.get('${ConfigBaseDomain.instant.baseDomain}/?_action=song_details&_idx=$idx');
//       if (response.statusCode == 200 && response.data['song'] != null) {
//         return SongModel.fromJson(response.data['song']);
//       }
//     } catch (e) {
//       throw Exception('노래를 가져오는 중 오류 발생: $e');
//     }
//     return null;
//   }
// }
