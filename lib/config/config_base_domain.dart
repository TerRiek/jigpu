// import 'dart:convert';
//
// import 'package:flutter/services.dart';
// import 'package:jigpu_1/utils/gen/assets.gen.dart';
//
// enum AppType { dev, prod }
//
// class ConfigBaseDomain {
//   // #region properties
//   String baseDomain = "";
//   String baseMusic = "";
//   // #endregion
//
//   ConfigBaseDomain._();
//
//   static ConfigBaseDomain instant = ConfigBaseDomain._();
//
//   late AppType flavor;
//
//   //init data config flavor
//   Future init(AppType appType) async {
//     flavor = appType;
//     if (appType == AppType.dev) {
//       _initBase(await parseJsonFromAssets(Assets.env.dev));
//     } else {
//       _initBase(await parseJsonFromAssets(Assets.env.prod));
//     }
//   }
//
//   // #region method convert data init
//   _initBase(Map<String, dynamic> data) {
//     baseDomain = data['baseDomain'];
//     baseMusic = data['baseMusic'];
//     // baseServer = "https://$baseDomain/api/v1";
//     // baseImage = "https://$baseDomain/api/v1";
//     // baseFile = "https://$baseDomain/api/v1";
//   }
//
//   Future<Map<String, dynamic>> parseJsonFromAssets(String assetsPath) async {
//     //log('--- Parse json from: $assetsPath');
//     return rootBundle.loadString(assetsPath).then((jsonStr) => jsonDecode(jsonStr));
//   }
// // #endregion
// }
