
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:just_audio/just_audio.dart';

class StreamProgressive {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;

  StreamProgressive() {
    // 플레이어 상태 변경 리스너 설정
    _audioPlayer.playerStateStream.listen((state) {
      isPlaying = state.playing;
    });
  }

  Future<void> progressiveDownloadAndPlay(String url, String cachePath) async {
    final file = File(cachePath);
    IOSink? sink;

    try {
      sink = file.openWrite(mode: FileMode.writeOnlyAppend);
      int startByte = 0;
      const int chunkSize = 128 * 1024;
      bool isComplete = false;

      final response = await http.get(Uri.parse(url), headers: {'Range': 'bytes=0-15'});
      if (response.statusCode == 200 || response.statusCode == 206) {
        // 헤더 유효성 검사
        final header = response.bodyBytes;
        print('First 16 bytes of the header: ${header.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ')}');

        if (String.fromCharCodes(header.take(4)) != 'OggS') {
          throw Exception('Invalid Opus header: ${String.fromCharCodes(header.take(4))}');
        }
        print('Valid Opus header detected: OggS');
      }

      while (!isComplete) {
        final endByte = startByte + chunkSize - 1;
        final headers = {'Range': 'bytes=$startByte-$endByte'};
        final chunkResponse = await http.get(Uri.parse(url), headers: headers);

        if (chunkResponse.statusCode == 206 || chunkResponse.statusCode == 200) {
          sink.add(chunkResponse.bodyBytes);
          startByte += chunkResponse.bodyBytes.length;

          print('Downloaded chunk: bytes=$startByte-${startByte + chunkResponse.bodyBytes.length - 1}');
          if (chunkResponse.contentLength != null && startByte >= chunkResponse.contentLength!) {
            isComplete = true;
            print('Download complete.');
          }
        } else {
          throw Exception('Failed to download chunk: ${chunkResponse.statusCode}');
        }
      }

      await _decodeOpusToWav(cachePath);
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.file(cachePath)));
      await _audioPlayer.play();
    } catch (e) {
      print('Error during progressive download and play: $e');
    } finally {
      await sink?.close();
    }
  }

  Future<void> _decodeOpusToWav(String filePath) async {
    final outputPath = filePath.replaceAll('.opus', '.wav');
    print('Decoding Opus to WAV...');

    final command = '-y -i $filePath -acodec pcm_s16le -ar 44100 $outputPath';
    final session = await FFmpegKit.executeAsync(command);

    final returnCode = await session.getReturnCode();
    if (returnCode != null && ReturnCode.isSuccess(returnCode)) {
      print('Decoding complete: $outputPath');
    } else {
      print('FFmpeg decoding failed.');

      // FFmpeg 로그 추가
      final logs = await session.getAllLogs();
      print("FFmpeg Logs:");
      for (var log in logs) {
        print(log.getMessage());
      }

      // 오류 스택 추적
      final errorLogs = await session.getFailStackTrace();
      if (errorLogs != null) {
        print("Error stack trace: $errorLogs");
      }
    }
  }


  void _logOpusHeader(List<int> data) {
    // Opus 파일의 헤더는 "OggS"로 시작해야 함
    const opusHeaderSignature = 'OggS';
    final headerString = String.fromCharCodes(data.take(4));
    if (headerString == opusHeaderSignature) {
      print("Valid Opus header detected: $headerString");
    } else {
      print("Invalid Opus header detected: $headerString");
    }

    // 추가적인 헤더 디버깅 정보 출력
    print("First 16 bytes of the header: ${data.take(16).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}");
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
