import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mime/mime.dart';

class CustomStreamAudioSource extends StreamAudioSource {
  final String filePath;
  late final StreamController<List<int>> _streamController;
  late final File _file;
  late Timer _timer;
  int _lastFileSize = 0;
  late final String mimType;

  CustomStreamAudioSource(this.filePath) {
    _file = File(filePath);
    detectMimeType(_file);
    _streamController = StreamController<List<int>>.broadcast();
    // 초기 파일 읽기
    _readInitialFile();
    // 변경 사항 감지 시작
    _startPollingFileChanges();
  }

  // 초기 파일 데이터를 스트림에 추가
  Future<void> _readInitialFile() async {
    try {
      final fileStream = await _file.openRead();
      await for (var chunk in fileStream) {
        _streamController.add(chunk);
      }
      _lastFileSize = await _file.length();
    } catch (e) {
      print('Error reading initial file: $e');
    }
  }

  Future<String?> detectMimeType(File file) async {
    final bytes = await file.readAsBytes();
    print("current mimtype: ${lookupMimeType(file.path, headerBytes: bytes)}");
    mimType = lookupMimeType(file.path, headerBytes: bytes)!;
  }

  // 파일 변경 감시: 주기적으로 파일 크기를 확인
  void _startPollingFileChanges() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      try {
        final currentSize = await _file.length();
        if (currentSize > _lastFileSize) {
          // 새로 추가된 데이터 읽기
          final fileStream = _file.openRead(_lastFileSize, currentSize);
          await for (var chunk in fileStream) {
            _streamController.add(chunk);
          }
          _lastFileSize = currentSize;
        }
      } catch (e) {
        print('Error polling file changes: $e');
      }
    });
  }

  @override
  Stream<List<int>> get stream => _streamController.stream;

  @override
  Future<void> dispose() async {
    await _streamController.close();
    _timer.cancel();
  }

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    return StreamAudioResponse(
      sourceLength: null,
      contentLength: null,
      offset: null,
      stream: _streamController.stream,
      contentType: "audio/opus",
    );
  }
}
