// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// // import 'package:flutter_component/data/spref.dart';
// import 'package:jigpu_1/models/data_view_model.dart';
// import 'package:jigpu_1/models/history_search_model.dart';
// import 'package:jigpu_1/models/users/user_model.dart';
// import 'package:jigpu_1/utils/gen/export.gen.g.dart';
// // ignore: depend_on_referenced_packages
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:collection/collection.dart';
//
// class ComponentCacheData implements _CacheKey {
//   static final ComponentCacheData instant = ComponentCacheData._internal();
//
//   ComponentCacheData._internal();
//
//   late SharedPreferences pref;
//
//   Future<void> initCache() async {
//     // await SPref.instant.init();
//     // pref = SPref.instant.prefs;
//     // await ComponentIsarData.instant.init();
//   }
//
//   // #region deviceId
//   ///Lấy ra deviceId
//   String get deviceId => pref.getString(_CacheKey.deviceId) ?? '';
//
//   ///Lưu lại deviceId
//   Future<void> setDeviceId(String deviceId) => pref.setString(_CacheKey.deviceId, deviceId);
//
//   // #endregion
//
//   String get accessCode => pref.getString(_CacheKey.accessCode) ?? '';
//
//   Future<void> setAccessCode(String token) => pref.setString(_CacheKey.accessCode, token);
//
//   String get identificationCode => pref.getString(_CacheKey.identificationCode) ?? '';
//
//   Future<void> setIdentificationCode(String token) => pref.setString(_CacheKey.identificationCode, token);
//
//   // #endregion
//
//   // #region token refresh
//   ///Lấy ra token refresh
//   String get refreshToken => pref.getString(_CacheKey.refreshToken) ?? '';
//
//   ///Lưu lại token refresh
//   Future<void> setRefreshToken(String refreshToken) => pref.setString(_CacheKey.refreshToken, refreshToken);
//
//   // #endregion
//
//   // #region token firebase
//   ///Lấy ra token firebase
//   String get tokenFirebase => pref.getString(_CacheKey.tokenFirebase) ?? "";
//
//   ///Lưu lại token firebase
//   Future<bool>? setTokenFirebase(String tokenFirebase) => pref.setString(_CacheKey.tokenFirebase, tokenFirebase);
//
//   // #endregion
//
//   // #region idUser
//   ///Lấy ra idUser
//   int? get idUser => pref.getInt(_CacheKey.idUser);
//
//   ///Lưu lại idUser
//   Future<void>? setIdUser(int idUser) => pref.setInt(_CacheKey.idUser, idUser);
//
//   // #endregion
//
//   // #region avatar local
//   int get idAvatar => pref.getInt(_CacheKey.idAvatar) ?? 0;
//   Future<void>? setIdAvatar(int idAvatar) => pref.setInt(_CacheKey.idAvatar, idAvatar);
//   int get colorAvatar => pref.getInt(_CacheKey.colorAvatar) ?? ColorName.bgGrey.value;
//   Future<void>? setColorAvatar(int colorAvatar) => pref.setInt(_CacheKey.colorAvatar, colorAvatar);
//   // #endregion
//
//   String get nickname => pref.getString(_CacheKey.nickname) ?? '';
//   Future<bool> setNickname(String nickname) => pref.setString(_CacheKey.nickname, nickname);
//
//   UserModel? userModel() {
//     final valueString = pref.getString(_CacheKey.userModel);
//     if (valueString != null) {
//       final userData = UserModel.fromJson(jsonDecode(valueString));
//       return userData;
//     }
//     return null;
//   }
//
//   Future<void> setUserModel(UserModel userModel) async {
//     final valueString = jsonEncode(userModel.toJson());
//     await pref.setString(_CacheKey.userModel, valueString);
//   }
//
//   List<DataViewModel>? listDataView() {
//     final valueString = pref.getString(_CacheKey.listDataView);
//     if (valueString != null) {
//       final listValue = jsonDecode(valueString) as List;
//       final listData = listValue.map((e) => DataViewModel.fromJson(e)).toList();
//       return listData;
//     }
//     return null;
//   }
//
//   Future<void> setListDataView(List<DataViewModel>? listDataView) async {
//     final valueString = jsonEncode(listDataView?.map((e) => e.toJson()).toList() ?? []);
//     await pref.setString(_CacheKey.listDataView, valueString);
//   }
//
//   List<HistorySearchModel> historySearch() {
//     final valueString = pref.getString(_CacheKey.historySearch);
//     if (valueString != null) {
//       final listValue = jsonDecode(valueString) as List;
//       final listData = listValue.map((e) => HistorySearchModel.fromJson(e)).toList();
//       listData.sort(
//             (a, b) => b.count.compareTo(a.count),
//       );
//       return listData;
//     }
//     return [];
//   }
//
//   Future setHistorySearch(String value) async {
//     List<HistorySearchModel> valueList = historySearch();
//     final index = valueList.indexWhere((element) => element.text == value);
//
//     if (value.isEmpty) {
//       return;
//     }
//
//     if (index >= 0) {
//       valueList[index].count += 1;
//     } else {
//       valueList.add(HistorySearchModel(text: value));
//     }
//     valueList.sort(
//           (a, b) => b.count.compareTo(a.count),
//     );
//     final valueString = jsonEncode(valueList.map((e) => e.toJson()).toList());
//     await pref.setString(_CacheKey.historySearch, valueString);
//   }
//
//   Future<void> setPlaylist(List<Map<String, List<dynamic>>> playList) async {
//     final valueString = jsonEncode(playList);
//     await pref.setString(_CacheKey.playlist, valueString);
//   }
//
//   List<Map<String, List<DataViewModel>>> playList() {
//     final valueString = pref.getString(_CacheKey.playlist);
//     if (valueString != null) {
//       final list = jsonDecode(valueString) as List;
//       try {
//         List<Map<String, List<DataViewModel>>> listData = [];
//         for (var element in list) {
//           final mapData = (element as Map);
//           for (var eee in mapData.keys) {
//             List<DataViewModel> listTemp = List<DataViewModel>.from(mapData[eee].map((aa) => DataViewModel.fromJson(aa)));
//             listData.add({eee: listTemp});
//           }
//         }
//         return listData;
//       } catch (e) {
//         rethrow;
//       }
//     }
//     return [];
//   }
//
//   Future removeAllCache() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     await preferences.remove(_CacheKey.accessCode);
//     await preferences.remove(_CacheKey.refreshToken);
//     // await preferences.remove(_CacheKey.tokenFirebase);
//     await preferences.remove(_CacheKey.idAvatar);
//     await preferences.remove(_CacheKey.idUser);
//     await preferences.remove(_CacheKey.colorAvatar);
//     await preferences.remove(_CacheKey.userModel);
//     await preferences.remove(_CacheKey.playlist);
//   }
//
//   Future<void> removeHistorySearchCache() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     await preferences.remove(_CacheKey.historySearch);
//   }
// }
//
// abstract class _CacheKey extends AppKey {
//   _CacheKey._internal();
//
//   static const String accessCode = "accessCode";
//   // static const String refreshToken = AppKey.xTokenRefresh;
//   static const String tokenFirebase = "tokenFirebase";
//   static const String idUser = "idUser";
//   static const String deviceId = "deviceId";
//   static const String idAvatar = "idAvatar";
//   static const String colorAvatar = "colorAvatar";
//   static const String userModel = "userModel";
//   static const String listDataView = "listDataView";
//   static const String historySearch = "historySearch";
//   static const String playlist = "playlist";
//   static const String nickname = "nickname";
//   static const String identificationCode = "identificationCode";
// }