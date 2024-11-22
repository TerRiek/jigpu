import 'dart:async';
import 'dart:io';
import 'package:just_audio/just_audio.dart';

class CustomStreamAudioSource extends StreamAudioSource {
  final String id;

  CustomStreamAudioSource(this.id);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final file = File(id);
    print("current id: ${id}");
    while(!file.existsSync()) {
      await Future.delayed(Duration(milliseconds: 200)); // 200ms마다 파일 존재 여부 확인
    }
    final stream = file.openRead().asBroadcastStream();

    return StreamAudioResponse(
      sourceLength: null,
      contentLength: null,
      offset: null,
      stream: stream,
      contentType: 'audio/wav',
    );
  }
}