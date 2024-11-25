import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class StreamProgressive {
  final AudioPlayer _audioPlayer = AudioPlayer();
  static bool canFileOpen = false;

  Future<void> progressiveDownloadByChunck(String url, String cachePath) async {
    canFileOpen = false; // 플래그 초기화
    Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    int startByte = 0;
    const int chunkSize = 128 * 1024; // 128KB
    bool isFirstChunk = true; // 첫 번째 청크 여부

    try {
      while (true) {
        final endByte = startByte + chunkSize - 1;
        final headers = {
          'Range': 'bytes=$startByte-$endByte',
          'Connection': 'keep-alive',
        };

        print("Requesting bytes=$startByte-$endByte");

        final response = await http.get(Uri.parse(url), headers: headers);

        if (response.statusCode == 206 || response.statusCode == 200) {
          // 다운로드 받은 데이터를 파일로 저장
          final file = File(cachePath);
          await file.writeAsBytes(response.bodyBytes, mode: FileMode.writeOnlyAppend);
          print("File size after chunk: ${await file.length()} bytes");

          if (isFirstChunk) {
            // 첫 번째 청크가 다운로드된 경우 바로 재생 시작
            print('First chunk downloaded and starting playback.');
            canFileOpen = true; // 재생 준비 완료
            isFirstChunk = false; // 첫 번째 청크 완료 표시
          }

          // 다음 청크 요청을 위해 시작 위치 갱신
          startByte += response.bodyBytes.length;

          // 모든 청크 다운로드 완료
          if (response.headers['content-range'] == null ||
              !response.headers['content-range']!.contains('/')) {
            print("전체 파일을 다운로드했으면 종료 ${response.headers['content-range']}");
            break; // 전체 파일을 다운로드했으면 종료
          }

          final totalSize = int.parse(response.headers['content-range']!.split('/').last);
          if (startByte >= totalSize) {
            print("All chunks downloaded.");
            break; // 전체 파일을 다운로드했으면 종료
          }
        } else {
          print("Error downloading chunk: ${response.statusCode}");
          break; // 다운로드 실패 시 루프 종료
        }
      }
    } on Exception catch (e) {
      print("Error during progressive download: $e");
    } finally {
      stopwatch.stop();
      print("Download duration: ${stopwatch.elapsedMilliseconds} ms");
    }
  }

  Future<void> progressiveDownloadByFile(String url, String cachePath) async {
    canFileOpen = false; // 플래그 초기화
    Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    const int chunkSize = 128 * 1024; // 128KB
    bool isFirstChunk = true; // 첫 번째 청크 여부

    try {
      // HTTP GET 요청 수행
      final request = http.Request('GET', Uri.parse(url));
      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 206) {
        print("Response status: ${response.statusCode}");

        // 파일 스트림 생성
        final file = File(cachePath);
        final fileSink = file.openWrite(mode: FileMode.writeOnlyAppend);

        int downloadedBytes = 0;

        await response.stream.listen((chunk) async {
          downloadedBytes += chunk.length;
          fileSink.add(chunk);

          print("Chunk downloaded: ${chunk.length} bytes, Total: $downloadedBytes bytes");

          if (isFirstChunk) {
            // 첫 번째 청크가 다운로드된 경우 바로 재생 시작
            print('First chunk downloaded and starting playback.');
            canFileOpen = true; // 재생 준비 완료
            isFirstChunk = false;
          }
        }).asFuture();

        await fileSink.close(); // 파일 스트림 닫기
        print("All chunks downloaded. File size: ${await file.length()} bytes");
      } else {
        print("Failed to download file. Status code: ${response.statusCode}");
      }
    } on Exception catch (e) {
      print("Error during progressive download: $e");
    } finally {
      stopwatch.stop();
      print("Download duration: ${stopwatch.elapsedMilliseconds} ms");
    }
  }
}
