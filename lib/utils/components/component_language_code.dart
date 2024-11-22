// // import 'dart:io';
//
// import 'dart:io';
//
// import 'package:flutter/material.dart';
//
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:jigpu_1/config/config_base_domain.dart';
// // import 'package:jigpu_1/config/config_base_domain.dart';
//
// import 'cache/component_cache_data.dart';
//
// class ComponentLanguageCode {
//   ComponentLanguageCode._();
//
//   static ComponentLanguageCode instant = ComponentLanguageCode._();
//
//   Future init() async {
//     await ComponentLanguageCode.instant.setLanguageCode("ko");
//     // await ComponentLanguageCode.instant.setLanguageCode("en");
//     // if (languageCode == null) {
//     //   await ComponentLanguageCode.instant.setLanguageCode("ko");
//     //   try {
//     //     final String defaultLocale = Platform.localeName;
//     //     String localCode = defaultLocale.split("_").first;
//     //     if (AppLocalizations.delegate.isSupported(Locale(localCode)) == false) {
//     //       localCode = 'en';
//     //     } else {
//     //       if (defaultLocale.toLowerCase().contains('zh')) {
//     //         if (defaultLocale.toLowerCase().contains('tw')) {
//     //           localCode = 'tw';
//     //         } else {
//     //           localCode = 'zh';
//     //         }
//     //       }
//     //     }
//     //     // if (ConfigBaseDomain.instant.flavor == AppType.prod) {
//     //     await ComponentLanguageCode.instant.setLanguageCode(localCode);
//     //     // } else {
//     //     //   await ComponentLanguageCode.instant.setLanguageCode('ko');
//     //     // }
//     //   } catch (e) {
//     //     await ComponentLanguageCode.instant.setLanguageCode('ko');
//     //   }
//     // }
//   }
//
//   static AppLocalizations get language => lookupAppLocalizations(Locale(ComponentLanguageCode.instant.languageCode!));
//   // #region local language
//   ///Lấy ra local language
//   String? get languageCode => ComponentCacheData.instant.pref.getString("languageCode");
//
//   ///Lưu lại local language
//   Future<void>? setLanguageCode(String languageCode) => ComponentCacheData.instant.pref.setString("languageCode", languageCode);
//
// // #endregion
// }
