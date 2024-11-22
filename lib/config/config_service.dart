// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_component/data/dio_config_network.dart';
// import 'package:intl/intl.dart';
//
// // import 'config_base_domain.dart';
//
// class ConfigService {
//   ConfigService._();
//   static ConfigService instant = ConfigService._();
//
//   bool loggingInterceptorEnabled = true;
//
//   Dio init() {
//     DioConfigNetwork.instant.init(baseUrl: "");
//     DioConfigNetwork.instant.dio.interceptors.addAll([
//       LoggingInterceptor(),
//     ]);
//     return DioConfigNetwork.instant.dio;
//   }
// }
//
// Map<String, ErrorInterceptorHandler> cacheHandler = {};
//
// class LoggingInterceptor extends Interceptor {
//   @override
//   Future<dynamic> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
//     if (ConfigService.instant.loggingInterceptorEnabled) {
//       debugPrint('--------------- Request (${_format(DateTime.now(), 'mm:ss')}) ---------------');
//       debugPrint('${options.method} - ${options.baseUrl}${options.path}');
//       debugPrint('Headers ${options.headers}');
//       if (options.data is FormData) {
//         debugPrint('- file ${(options.data as FormData).files.toString()}');
//       } else {
//         debugPrint('- ${options.data}');
//         options.data ??= <String, dynamic>{};
//       }
//       debugPrint('Query parameters ${options.queryParameters}');
//       debugPrint('---------------------------------------');
//     }
//     return handler.next(options);
//   }
//
//   @override
//   Future<dynamic> onResponse(Response response, ResponseInterceptorHandler handler) async {
//     if (ConfigService.instant.loggingInterceptorEnabled) {
//       debugPrint('--------------- Response (${_format(DateTime.now(), 'mm:ss')}) ---------------');
//       printWrapped('Status code: ${response.statusCode}\nStatus Message: ${response.statusMessage}');
//       debugPrint('---------------------------------------');
//     }
//     return handler.next(response);
//   }
//
//   @override
//   Future<dynamic> onError(DioException err, ErrorInterceptorHandler handler) async {
//     if (ConfigService.instant.loggingInterceptorEnabled) {
//       debugPrint('--------------- Error (${_format(DateTime.now(), 'mm:ss')}) ---------------');
//       debugPrint('path: ${err.response?.requestOptions.path}');
//       debugPrint('type: ${err.type}');
//       debugPrint('error: ${err.error}');
//       debugPrint('response: ${err.response}');
//       debugPrint('---------------------------------------');
//     }
//     return handler.next(err);
//   }
//
//   static String _format(DateTime dateTime, String formatPattern) {
//     DateFormat dateFormat = DateFormat(formatPattern);
//     return dateFormat.format(dateTime);
//   }
//
//   void printWrapped(String text) {
//     final pattern = RegExp('.{1,800}');
//     pattern.allMatches(text).forEach((match) => debugPrint(match.group(0)));
//   }
// }
