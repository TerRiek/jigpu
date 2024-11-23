import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class StreamProgressive {
  final AudioPlayer _audioPlayer = AudioPlayer();
  static bool canFileOpen = false;
  bool isPlaying = false;

  StreamProgressive() {
    // 플레이어 상태 변경에 대한 리스너 설정
    _audioPlayer.playerStateStream.listen((state) {
      isPlaying = state.playing;
    });
  }

  Future<void> progressiveDownload(String url, String cachePath) async {
    canFileOpen = false;
    Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    try {
      /// TODO: Range 헤더 설정
      /// TODO: Range 필요 없을시 headers 제거
      final headers = {
        'Range': 'bytes=0-99999',  // 정확히 100KB
        'Connection': 'keep-alive',
      };
      /// TODO: Range 필요 없을시 headers 제거
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 206) {  // 범위 요청이 성공적으로 처리된 경우
        // 다운로드 받은 데이터를 파일로 저장
        final file = File(cachePath);
        await file.writeAsBytes(response.bodyBytes, mode: FileMode.writeOnlyAppend);

        print('Downloaded chunk from 0 to 99999');
        final duration = stopwatch.elapsed;
        stopwatch.stop();
        print("current duration: ${duration.inSeconds} s");
        print("current duration: ${duration.inMilliseconds} ms");
        canFileOpen = true;
      } else if (response.statusCode == 200) {
        // 전체 파일 요청이므로 바로 저장
        final file = File(cachePath);
        await file.writeAsBytes(response.bodyBytes);
        print('Downloaded entire file');
        final duration = stopwatch.elapsed;
        stopwatch.stop();
        print("current duration: ${duration.inSeconds} s");
        print("current duration: ${duration.inMilliseconds} ms");
        canFileOpen = true;
      } else {
        print('Failed to download file. Status code: ${response.statusCode}');
      }
    } on PlatformException catch (e) {
      // PlatformException 발생 시 처리
      throw PlayerException(int.parse(e.code), e.message,
          (e.details as Map<dynamic, dynamic>?)?.cast<String, dynamic>());
    } catch (e) {
      // 기타 예외 처리
      throw Exception('Failed to load audio: $e');
    }
  }

  Future<void> play() async {
    await _audioPlayer.play(); // 재생 시작
  }

  Future<void> pause() async {
    await _audioPlayer.pause(); // 일시 정지
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position); // 특정 위치로 이동
  }

  Duration get duration => _audioPlayer.duration ?? Duration.zero; // 전체 길이
  Duration get position => _audioPlayer.position; // 현재 위치

  void dispose() {
    _audioPlayer.dispose(); // 리소스 해제
  }
}