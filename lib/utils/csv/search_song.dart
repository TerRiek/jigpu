import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csv/csv.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/data_view_model.dart';
import '../components/cache/fifo_cache_manager.dart';
import '../db_helper/albums/database_helper_album.dart';
import 'package:http/http.dart' as http;

import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';

// import 'package:opus_caf_converter_dart/opus_caf_converter_dart.dart';

class SearchSong {
  List<dynamic> csvTable = [];
  final FifoCacheManager fifoCacheManager = FifoCacheManager();

  ///음반명, 아티스트명으로 데이터베이스에서 해당하는 List<DataViewModel?> 반환
  Future<List<DataViewModel?>> searchSong(String? albumKo, String? artist, String? artistEn) async {
    final dbHelper = DatabaseHelperAlbum.instance;

    var epResult = await dbHelper.getAlbumsFromDatabase("ep_albums");
    var singleResult = await dbHelper.getAlbumsFromDatabase("single_albums");
    var fullResult = await dbHelper.getAlbumsFromDatabase("full_albums");
    List<DataViewModel?> dataViewModelList = [];
    if (epResult != null) {
      var datas = epResult.list;
      for(var data in datas!) {
        if((data.artist == artistEn || data.artist == artist) && data.title == albumKo) {      //data.title이 음반 제목
          dataViewModelList.add(data);
        }
      }
    }
    if (singleResult != null) {
      var datas = singleResult.list;
      for(var data in datas!) {
        if((data.artist == artistEn || data.artist == artist) && data.title == albumKo) {
          dataViewModelList.add(data);
        }
      }
    }
    if (fullResult != null) {
      var datas = fullResult.list;
      for(var data in datas!) {
        if((data.artist == artistEn || data.artist == artist) && data.title == albumKo) {
          dataViewModelList.add(data);
        }
      }
    }
    print("end of searchSong : ${dataViewModelList.length}");
    return dataViewModelList;
  }

  ///input : [음반명(ko), 음반명(en), 아티스트명(ko), 아티스트명(en)]
  Future<List<DataViewModel?>> searchSongIntl(List<String?> input) async {
    if(input.isEmpty) {
      return [];
    }
    final dbHelper = DatabaseHelperAlbum.instance;

    var epResult = await dbHelper.getAlbumsFromDatabase("ep_albums");
    var singleResult = await dbHelper.getAlbumsFromDatabase("single_albums");
    var fullResult = await dbHelper.getAlbumsFromDatabase("full_albums");
    List<DataViewModel?> dataViewModelList = [];
    //data.title은 음반 제목
    //음원 제목은 사용하지 않음
    if (epResult != null) {
      var datas = epResult.list;
      //print("ep : ${datas?.length}"); //19
      for(var data in datas!) {
        if((data.artist == input[2] || data.artist == input[3]) && (data.title == input[0] || data.title == input[1])) {
          dataViewModelList.add(data);
        }
      }
    }
    if (singleResult != null) {
      var datas = singleResult.list;
      //print("single : ${datas?.length}"); //147
      for(var data in datas!) {
        if((data.artist == input[2] || data.artist == input[3]) && (data.title == input[0] || data.title == input[1])) {
          dataViewModelList.add(data);
        }
      }
    }
    if (fullResult != null) {
      var datas = fullResult.list;
      //print("full : ${datas?.length}"); //29
      for(var data in datas!) {
        if((data.artist == input[2] || data.artist == input[3]) && (data.title == input[0] || data.title == input[1])) {
          dataViewModelList.add(data);
        }
      }
    }
    print("end of searchSong : ${dataViewModelList.length}");
    return dataViewModelList;
  }

  ///아티스트명과 음원명을 입력받아 csv에서 albumCode를 반환하는 메소드
  ///
  ///(데이터 없으면 "" 반환)
  ///
  ///기본 albumCode를 반환, song만 true면 songCode를 반환, 둘 다 true면 albumCode_songCode를 반환
  Future<String> getAlbumCodeFromCSV(String artist, String songTitle, {bool album = true, bool song = false}) async {
    print("in getAlbumCodeFromCSV : $artist, $songTitle");

    String albumCode = "";
    String songCode = "";
    if(csvTable.isEmpty) {
      final String csvData = await rootBundle.loadString('assets/csv/db_release.csv');
      csvTable = const CsvToListConverter().convert(csvData).sublist(1);
    }

    for(int i = 0 ; i < csvTable.length ; i++) {
      if(artist.compareTo(csvTable[i][1]) == 0 && songTitle.compareTo(csvTable[i][10]) == 0) {
        albumCode = csvTable[i][46];
        songCode = csvTable[i][47];
        break;
      }
    }

    if(album && song) {
      return "${albumCode}_$songCode";
    }
    else if(!album && song) {
      return songCode;
    }
    return albumCode;
  }

  Future<String?> fetchMusicUrlByTitle(int? idx, String? title) async {
    final String apiUrl = 'https://jigpu.com/app?_action=album&_plugin=keiser&_action_type=details&_idx=$idx';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // 리스트에서 주어진 제목과 일치하는 곡 찾기
        final songList = jsonResponse['song_list'] as List<dynamic>;

        final songData = songList.firstWhere(
              (song) => song['title'].split("(")[0].trim() == title?.trim().replaceAll("'", "’"),
          orElse: () => null,
        );

        if (songData != null) {
          // music0 값을 리턴
          return songData['music0'] as String;
        } else {
          // print('No song found with title "$title"');
          return null; // 제목이 일치하는 곡이 없는 경우
        }
      } else {
        // print('Failed to load song data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // print('Error: $e');
      return null;
    }
  }

  // 케이저 음원 코드를 매개변수로 넘겨주고 ogg 확장자로 된 음원 url 을 가지고 온다
  Future<String?> getOpusUrl(String? songCode) async {
    final String apiUrl = 'https://jigpu.com/app/?_action=song_url&_plugin=keiser&_keiser_id=$songCode';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // 리스트에서 주어진 제목과 일치하는 곡 찾기
        final songData = jsonResponse as dynamic;

        if (songData != null) {
          debugPrint("songData['opus_url'] : ${songData['opus_url']}");
          return songData['opus_url'] as String;
        } else {
          // print('No song found with title "$title"');
          return null; // 제목이 일치하는 곡이 없는 경우
        }
      } else {
        // print('Failed to load song data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // print('Error: $e');
      return null;
    }
  }

  // 음원 제목 음원 영어 제목 아티스트명을 가지고 csvTable과 비교해서 음원 케이저 코드를 가지고 온다.
  Future<String?> getSongCode(String? title, String? titleEn, String? artist) async {
    try {
      final String csvData = await rootBundle.loadString('assets/csv/db_release.csv');
      final csvTable = const CsvToListConverter().convert(csvData).sublist(1);

      for (var csv in csvTable) {
        final csvTitle = csv[10].toString().trim();
        final csvTitleEn = csv[13].toString().trim();
        final csvArtist = csv[1].toString().trim();

        final trimmedTitle = title?.toString().trim();
        final trimmedTitleEn = titleEn?.toString().trim();
        final trimmedArtist = artist?.toString().trim();

        // 제목 또는 영어 제목, 그리고 아티스트가 일치하는지 비교
        if ((csv[10] != null && csv[13] != null && csv[1] != null) && ((csvTitle == trimmedTitle || csvTitleEn == trimmedTitleEn) && csvArtist == trimmedArtist)) {
          if (csv[47] != null) {
            return csv[47].toString(); // 47번째 열에서 코드 반환
          }
        }
      }
      return null;
    } catch (e) {
      print('CSV 파일 로드 중 오류 발생: $e');
      return null;
    }
  }

  // 케이저 음원 코드를 매개변수로 넘겨주고 음원 idx 을 가지고 온다
  Future<Map<String, dynamic>?> getSongidxAndImage(String? songCode) async {
    final String apiUrl = 'https://jigpu.com/app/?_action=song_url&_plugin=keiser&_keiser_id=$songCode';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // 리스트에서 주어진 제목과 일치하는 곡 찾기
        final songData = jsonResponse as dynamic;

        if (songData != null) {
          return {
            "idx" : songData['idx'] as int,
            "imageUrl" :songData['image_url'] as String,
          };
        } else {
          // print('No song found with title "$title"');
          return null; // 제목이 일치하는 곡이 없는 경우
        }
      } else {
        // print('Failed to load song data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // print('Error: $e');
      return null;
    }
  }


  ///음반 이미지를 다운로드 받아 hive에 저장
  Future<void> loadHiveImage(String albumCode, String songCode, {String? title}) async {
    print("start loadHiveImage in SearchSong");

    //hive에 저장 되었는 지 확인 (오프라인)
    await Hive.initFlutter();
    var hive = await Hive.openBox('albumImages');

    //이미지가 있으면 통과
    if(hive.get("webp_$albumCode") != null) {
      print("webp_$albumCode is exist");
    }
    //없으면 인터넷 연결 상태 확인 후 다운로드
    else {
      print("webp_$albumCode is not exist");
      if(title == null) {
        return;
      }

      // 해당 음반의 idx 검색
      List<String?> albumTitlesFromCsv = await getArtistAlbum(title);
      print("before dataForIdx :  $albumTitlesFromCsv");

      List<DataViewModel?> dataForIdx = await searchSongIntl(albumTitlesFromCsv);
      print("after dataForIdx : $dataForIdx");
      print("data length : ${dataForIdx.length}, ${dataForIdx[0]?.idx}");

      // 현재 인터넷 상태 확인
      if(dataForIdx.isNotEmpty) {
        print("before connectivityResult");
        var connectivityResult = await (Connectivity().checkConnectivity());
        print("connectivityResult : $connectivityResult, data length : ${dataForIdx.length}, idx : ${dataForIdx[0]?.idx}");
        if(connectivityResult != ConnectivityResult.none && dataForIdx[0]?.idx != null) {
          final url = 'https://jigpu.com/app/?_action=album&_plugin=keiser&_action_type=details&_idx=${dataForIdx[0]!.idx}';
          try {
            print("before get");
            final response = await http.get(Uri.parse(url));
            print("after get : ${response.statusCode}");  //현재 200이 2개 나옴
            if (response.statusCode == 200) {
              final songData = (json.decode(response.body))["list"];
              print("response before process : $songData");
              if(songData[0]["image0"] != null && songData[0]["image0"] != "") {
                print("call downloadImage : ${songData[0]["image0"]}");
                await downloadImage(songData[0]["image0"], albumCode);
              }
            }
            else {
              print('Failed to load data: ${response.statusCode}');
            }
          }
          catch (e) {
            print('Error: $e');
          }
        }
        else{
          //저장된 이미지가 없고, 다운로드 불가능한 상태
          print("show Error Image");
        }
      }
      else {
        print("data is empty");
      }
    }

    //인터넷 연결 여부 관계 없음
    //위젯 트리에 사용할 이미지를 여기서 등록
    String? imagePath;
    try {
      print("call try : webp_$albumCode");
      imagePath = await hive.get("webp_$albumCode");
    }
    catch(e) {
      print("exception of hive.get : $e");
    }
    finally {
      print("get albumPath : webp_$albumCode => imagePath : $imagePath");
      if(imagePath != null) {
        File file = File(imagePath);
        final bytes = await file.readAsBytes();

        Uint8List? imageData = bytes;
        Widget? albumImage = Image.memory(imageData);
        print("set completeTask = 2-1");
      }
      print("set completeTask = 2-2");
    }
  }

  Future<Image> getImageFromHive(String albumCode) async {
    //이미지 찾지 못한 경우 기본 이미지 출력
    Image image = Image.asset(
        'assets/csv/album/KEI-0001/webp'
    );
    await Hive.initFlutter();
    var hive = await Hive.openBox('albumImages');

    if(hive.get("webp_$albumCode") != null) {
      print("webp_$albumCode is exist");

      String? imagePath;
      try {
        print("call try : webp_$albumCode");
        imagePath = await hive.get("webp_$albumCode");

        if(imagePath != null) {
          File file = File(imagePath);
          final bytes = await file.readAsBytes();
          Uint8List? imageData = bytes;
          image = Image.memory(imageData);
          //print("set albumImage : $albumImage, ${albumImage.runtimeType} :: code : ${widget.data.albumCode}");
          //print("in build data : ${widget.data.albumCode != null}, ${albumImage != null}");
          print("get albumPath : webp_$albumCode => imagePath : $imagePath");
          print("set completeTask = 2");
        }
      }
      catch(e) {
        print("exception of hive.get : $e");
      }
      finally {
        print("set completeTask = 3");
      }
    }

    return image;
  }

  ///csv를 이용해서 음원명으로 [음반명(ko), 음반명(en), 아티스트명(ko), 아티스트명(en)]을 리턴
  Future<List<String?>> getArtistAlbum(String title) async {
    List<dynamic> csvTable = [];
    if(csvTable.isEmpty) {
      final String csvData = await rootBundle.loadString('assets/csv/db_release.csv');
      csvTable = const CsvToListConverter().convert(csvData).sublist(1);
    }

    for(int i = 0 ; i < csvTable.length ; i++) {
      if(csvTable[i][10].toString().compareTo(title) == 0) {
        return [csvTable[i][5].toString(), csvTable[i][6].toString(), csvTable[i][1].toString(), csvTable[i][3].toString()];
      }
    }
    return [];
  }

  /// 이미지 다운로드 및 저장
  Future<void> downloadImage(String url, String filename) async {
    try {
      final response = await http.get(Uri.parse(url));
      print("response in downloadImage : ${response.statusCode}");

      if (response.statusCode == 200) {
        final path = (await getApplicationDocumentsDirectory()).path;
        final file = File('$path/webp_$filename');
        await saveImagePathToHive(file.path, "webp_$filename");
        await file.writeAsBytes(response.bodyBytes); // 이미지 파일을 실제로 저장하는 부분
      }
      else {
        throw Exception('Failed to download image');
      }
    }
    catch(e) {
      debugPrint("Exception in downloadImage $e");
    }
  }

  /// Hive에 파일 경로 저장
  Future<void> saveImagePathToHive(String imagePath, String code) async {
    var box = await Hive.openBox('albumImages');
    await box.put(code, imagePath); // 경로 저장
    print("getBox : $code => ${box.get(code)} || $imagePath");
  }

  Future<String?> progressiveDownload(String opusUrl) async {
    /// 파일 경로 설정
    final cacheDir = await fifoCacheManager.getCacheDirectoryPath();
    final opusPath = "${cacheDir}/${opusUrl.replaceAll("/", "_").replaceAll(":", "-")}";
    final wavPath = "${cacheDir}/${opusUrl.replaceAll("/", "_").replaceAll(":", "-").replaceFirst(".opus", "")}.wav";
    final opusFile = File(opusPath);
    final wavFile = File(wavPath);

    /// wav 파일이 이미 있다면 디코딩이 이전에 끝난것이므로 리턴
    if(wavFile.existsSync()) {
      return wavFile.path;
    }
    /// opus 를 청크 단위로 전체 다운로드
    await progressivseDownloadOpus(opusFile, wavFile, opusUrl);
    return wavFile.path;
  }

  Future<void> progressivseDownloadOpus(File opusFile, File wavFile, String opusUrl) async {
    /// opus가 이미 존재하면 리턴
    if (opusFile.existsSync()) {
      return;
    }

    /// 변수 설정
    final response = await http.head(Uri.parse(opusUrl));  /// 파일 크기 확인을 위한 HEAD 요청
    final contentLength = int.parse(response.headers['content-length'] ?? '0'); /// 파일의 전체 크기
    int chunkSize = 100000;  /// 청크 크기 100KB (필요에 맞게 조절)
    int startByte = 0;
    int endByte = chunkSize - 1;
    bool tf = true;

    /// 빈 opus 파일을 생성
    final opusSink = opusFile.openWrite(mode: FileMode.append);
    final wavSink = wavFile.openWrite(mode: FileMode.append);

    /// opus 파일의 데이터를 청크 단위로 다운로드
    while (startByte < contentLength) {
      /// 각 청크의 Range 헤더 설정 (몇 바이트씩 받을지 설정)
      final request = http.Request("GET", Uri.parse(opusUrl))
        ..headers.addAll({"Range": "bytes=$startByte-$endByte"});

      final response = await request.send();

      /// 상태 코드가 206 (청크 다운로드 성공)일 경우
      if (response.statusCode == 206) {
        final chunkData = await response.stream.toBytes();
        print("Received chunk length: ${chunkData.length} bytes");

        /// 다운로드한 chunk 데이터를 opus 파일에 추가
        opusSink.add(chunkData);
        await FFmpegKit.executeAsync('-i ${opusFile.path} -ar 48000 -ac 2 -y ${wavFile.path}');

      } else {
        print("Failed to download chunk.");
        break;
      }

      /// 청크가 끝나면 다음 범위로 설정
      startByte += chunkSize;
      endByte = (endByte + chunkSize < contentLength) ? endByte + chunkSize : contentLength - 1;
      // tf = false;
    }
    /// opus 파일의 다운로드가 끝나면
    opusSink.close();
  }


  Future<String?> decodeOpusToWav1(String opusUrl) async {
    // URL에서 파일 이름 추출
    print("opusurl : ${opusUrl}");
    final fileName = opusUrl.replaceAll(":", "").replaceAll("/", "_").split(".opus").first.split(".mp3").first.split(".flac").first; // 파일 이름을 URL에서 가져오기
    print("fileName : ${fileName}");
    final cacheDir = await fifoCacheManager.getCacheDirectoryPath();

    final cachedWavPath = '${cacheDir}/$fileName.wav'; // WAV 파일 경로 설정

    // 캐시된 WAV 파일이 이미 존재하는지 확인
    final cachedFile = File(cachedWavPath);
    if (await cachedFile.exists()) {
      print("캐시된 WAV 파일이 이미 존재합니다: $cachedWavPath");
      return cachedWavPath; // 캐시된 파일 경로 반환
    }

    // Opus 파일을 WAV로 변환하는 FFmpeg 명령어 실행
    final session = await FFmpegKit.execute('-i "$opusUrl" -f wav "$cachedWavPath"');
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print("WAV 파일로 변환 완료: $cachedWavPath");
      return cachedWavPath; // 변환된 WAV 파일 경로 반환
    } else {
      print("디코딩 중 오류가 발생했습니다.");
      final output = await session.getOutput();
      print("FFmpeg 출력: $output");
      return null;
    }
  }

  Future<String?> decodeOpusToWav2(String opusUrl) async {
    String? cacheDir = await fifoCacheManager.getCacheDirectoryPath();
    String? cachePath = "${cacheDir}/${opusUrl.replaceAll(".opus", "").replaceAll(":", "-").replaceAll("/", "_")}.wav";

    final file = File(cachePath);
    if(await file.existsSync()) {
      return cachePath;
    }

    Duration duration = await getAudioDuration(opusUrl);

    print("현재 duration dms : ${duration}");

    // Stopwatch를 시작하여 시간을 측정
    Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    // FFmpegKit을 비동기로 실행하여 파일을 실시간 디코딩
    final secondSession = FFmpegKit.executeAsync(
      '-i $opusUrl -f wav $cachePath',
          (secondSession) async {
        final returnCode = await secondSession.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          print("FFmpeg 디코딩 완료");
        } else {
          print("FFmpeg 에러 발생");
        }
      },
    );
    return cachePath;
  }

  Future<Duration> getAudioDuration(String opusUrl) async {
    // FFmpeg 명령어를 사용하여 파일의 duration을 추출합니다.
    final session = await FFmpegKit.execute(
        '-i $opusUrl -show_entries format=duration -v quiet -of csv="p=0"'
    );
    final returnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      // FFmpeg 실행 결과에서 출력된 duration 값 추출
      final duration = await session.getDuration();
      print("thie is : ${duration}");
      return Duration(seconds: duration);
    } else {
      // 오류 발생 시 0초 반환 (또는 예외를 던질 수 있음)
      print("FFmpeg 에러 발생: ${await session.getFailStackTrace()}");
      return Duration.zero;
    }
  }
}