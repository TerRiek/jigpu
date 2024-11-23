import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:jigpu_1/models/song_model.dart';
import 'package:jigpu_1/utils/csv/search_song.dart';
import 'package:jigpu_1/utils/db_helper/playback/playback_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rxdart/rxdart.dart';
import '../../csv/StreamProgressive.dart';
import '../../db_helper/favorite_songs/database_helper_favorite_song.dart';
import '../../db_helper/songs/songs_helper.dart';
// import '../../widgets/toast/app_alert.dart';
import '../cache/fifo_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path; // path 패키지 임포트

/// NOTE: 음원 플레이어 관리를 위한 ComponentPlayer 클래스 : 음원 플레이어의 동작을 제어하고 상태를 관리
class ComponentPlayer {
  static ComponentPlayer instant = ComponentPlayer
      ._(); // 음원 플레이어 관리를 위한 ComponentPlayer 클래스의 싱글톤 인스턴스. 여러 곳에서 동일한 인스턴스를 공유하여 관리
  final AudioPlayerHandler audioPlayerHandler = AudioPlayerHandler(); // 음원 재생과 관련된 상태 및 동작을 처리하는 AudioPlayerHandler의 인스턴스. 플레이어 기능을 제어하고 상태를 관리
  final FifoCacheManager fifoCacheManager = FifoCacheManager();
  final SongsHelper songsHelper = SongsHelper();
  final PlaybackHelper playbackHelper = PlaybackHelper();
  AudioHandler? audioHandler; // AudioService에서 제공하는 오디오 제어 기능을 사용하기 위한 AudioHandler 객체

  /// 현재 재생 중인 음원 정보
  Duration currentPosition = Duration.zero; // 현재 재생 위치
  Duration? duration;                       // 현재 재생 중인 음원의 길이

  /// 현재 재생 목록 관련 변수
  BehaviorSubject<List<MediaItem>> mediaItemList = BehaviorSubject<List<MediaItem>>.seeded([]);   // mediaItemList: 전체 재생 목록(여러 곡)을 관리
  ValueNotifier<SongModel?> mediaCurrent = ValueNotifier(null);                                   // mediaCurrent:  현재 재생 중인 단일 곡을 관리

  /// 플레이어의 동작 상태 관련 변수
  final Lock _lock = Lock(reentrant: true);                                                   // 동시성 문제를 방지하기 위한 Lock 객체. 재생, 일시 정지 등 중요한 작업이 동시에 실행되지 않도록 보장
  final BehaviorSubject<bool> _isPlayRequested = BehaviorSubject.seeded(false);               // 재생 중 여부를 나타내는 스트림 (true: 재생 요청 시작, false: 재생 완료)
  final BehaviorSubject<bool> _isPauseRequested = BehaviorSubject.seeded(false);              // 일시 정지 여부를 나타내는 스트림 (true: 일시 정지 요청 시작, false: 일시 정지 완료)
  final BehaviorSubject<bool> _isStopRequested = BehaviorSubject.seeded(false);               // 정지 여부를 나타내는 스트림 (true: 정지 요청 시작, false: 정지 완료)
  final BehaviorSubject<bool> _isNextTrackRequested = BehaviorSubject.seeded(false);          // 다음 곡 재생 여부를 나타내는 스트림 (true: 다음 곡 재생 요청 시작, false: 다음 곡 재생 완료)
  final BehaviorSubject<bool> _isPreviousTrackRequested = BehaviorSubject.seeded(false);      // 이전 곡 재생 여부를 나타내는 스트림 (true: 이전 곡 재생 요청 시작, false: 이전 곡 재생 완료)
  final BehaviorSubject<bool> _isAddToPlaylistRequested = BehaviorSubject.seeded(false);      // 현재 재생목록에 여러 음원을 추가 요청 여부를 나타내는 스트림 (true: 업데이트 요청 시작, false: 업데이트 완료)
  final BehaviorSubject<bool> _isAddSingleTrackRequested = BehaviorSubject.seeded(false);     // 현재 재생목록에 단일 음원 추가 요청 여부를 나타내는 스트림 (true: 추가 요청 시작, false: 추가 완료)
  final BehaviorSubject<bool> _isRemoveFromPlaylistRequested = BehaviorSubject.seeded(false); // 현재 재생목록에서 음원 삭제 요청 여부를 나타내는 스트림 (true: 삭제 요청 시작, false: 삭제 완료)
  final BehaviorSubject<bool> _isSpeedChangeRequested = BehaviorSubject.seeded(false);        // 재생 속도 변경 요청 여부를 나타내는 스트림 (true: 변경 요청 시작, false: 변경 완료)
  //BehaviorSubject<bool> _isRepeatModeRequested = BehaviorSubject.seeded(false);                 // 반복 재생 모드 처리 시도 여부를 나타내는 스트림 (true: 처리 시도 중, false: 처리 완료)
  //BehaviorSubject<bool> _isShuffleModeRequested = BehaviorSubject.seeded(false);                // 셔플 모드 전환 시도 여부를 나타내는 스트림 (true: 처리 시도 중, false: 처리 완료)

  /// [Getter] 플레이어의 동작 상태를 확인
  bool get isPlayRequested => _isPlayRequested.value;
  bool get isPauseRequested => _isPauseRequested.value;
  bool get isStopRequested => _isStopRequested.value;
  bool get isNextTrackRequested => _isNextTrackRequested.value;
  bool get isPreviousTrackRequested => _isPreviousTrackRequested.value;
  bool get isAddToPlaylistRequested => _isAddToPlaylistRequested.value;
  bool get isAddSingleTrackRequested => _isAddSingleTrackRequested.value;
  bool get isRemoveFromPlaylistRequested => _isRemoveFromPlaylistRequested.value;
  bool get isSpeedChangeRequested => _isSpeedChangeRequested.value;

  /// 구간 반복 재생 설정 관련 변수
  Duration? startPosition; // 시작점 위치
  Duration? endPosition; // 끝점 위치
  bool _isLooping = false; // 구간 반복 활성화 여부를 나타내는 플래그

  /// N번 반복 재생 관련 변수
  int remainingRepeats = 0;                             // 남은 반복 횟수
  ValueNotifier<int> repeatNotifier = ValueNotifier(0); // 반복 횟수를 감지하는 ValueNotifier
  bool isRepeatModeOn = false;                          // 반복 재생 기능을 켜거나 끄는 변수

  /// 이벤트 처리를 위한 Connectivity 객체
  final Connectivity connectivity = Connectivity();     // Connectivity 객체 (헤드셋 연결 상태 모니터링용)

  SearchSong searchSong = SearchSong();

  /// ComponentPlayer 클래스의 생성자
  ComponentPlayer._();
  ComponentPlayer() {
    _handleCurrentIndexChanges();
    _updateMediaCurrentIfNeeded();
    _monitorHeadsetConnection();
    WidgetsBinding.instance.addObserver(this as WidgetsBindingObserver);
    decodedFilePath = [];
  }

  /// 오디오 서비스(AudioService) 초기화 메서드
  initAudiService() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    audioHandler = await AudioService.init(
      builder: () => audioPlayerHandler,
      config: AudioServiceConfig(
        androidNotificationChannelId: packageInfo.packageName,
        androidNotificationChannelName: packageInfo.appName,
        androidNotificationOngoing: true,
      ),
    );
    await fifoCacheManager.manageCache(); // 초기 캐시 관리 작업
  }

  /// currentIndexStream을 통해 인덱스 변화를 감지하고, mediaCurrent 업데이트
  void _handleCurrentIndexChanges() {
    ComponentPlayer.instant.audioPlayerHandler.player.currentIndexStream
        .listen((currentIndex) {
      if (currentIndex != null &&
          currentIndex < ComponentPlayer.instant.mediaItemList.value.length) {
        final newSong = ComponentPlayer.instant.mediaItemList
            .value[currentIndex].toSongModel();

        // 기존 재생 중인 곡과 새로운 곡이 일치하지 않으면 업데이트
        if (ComponentPlayer.instant.mediaCurrent.value?.title !=
            newSong.title) {
          ComponentPlayer.instant.mediaCurrent.value = newSong;
          debugPrint("mediaCurrent가 재생 중인 곡 업데이트: ${newSong.title}");
        }
      }
    });
  }

  /// 재생 목록이 설정되거나 변경된 후, mediaCurrent가 설정되지 않았을 때 곡을 설정.
  void _updateMediaCurrentIfNeeded() {
    mediaItemList.listen((list) {
      if (list.isNotEmpty && mediaCurrent.value == null) {
        mediaCurrent.value = list.first.toSongModel();
        debugPrint("mediaCurrent가 설정되었습니다: ${list.first.title}");
      }
    });
  }

  /// 헤드셋 연결 상태를 모니터링하는 메서드
  void _monitorHeadsetConnection() {
    // connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
    //   if (result == ConnectivityResult.bluetooth) {
    //     if (mediaCurrent.value != null) {
    //       //play();
    //     }
    //   } else {
    //     //pause();
    //   }
    // });
  }

  /// 재생 요청을 동기화하여 처리하는 헬퍼 메서드
  Future<void> _handleActionWithLock(BehaviorSubject<bool> requestSubject,
      Future<void> Function() action, String? actionName,) async {
    //await _lock.synchronized(() async {
    requestSubject.add(true);
    debugPrint("--------------- $actionName 실행 ----------------");
    try {
      await action();
      await Future.delayed(
          Duration(milliseconds: 800)); // 호출 간격을 두어 이벤트 중복 방지
    } catch (e) {
      print("오류 발생: $e"); // 오류 발생 시 사용자에게 알림
    } finally {
      requestSubject.add(false);
    }
    //});
  }

  /// 현재 재생 중인 음원 정보를 가져오는 메서드
  Future<Duration?> getSongDuration({required SongModel mediaItem}) async {
    try {
      return mediaItem.duration;
    } catch (e) {
      debugPrint("ERROR===> $e");
      return Duration.zero;
    }
  }

  /// 현재 재생 목록의 길이를 반환하는 메서드.
  int getMediaItemListLength() {
    return mediaItemList.value.length; // 빈 리스트일 경우 0 반환
  }

  /// 재생 메서드
  Future<void> play() async {
    debugPrint("--------------- 재생 실행 ----------------");
    await _handleActionWithLock(_isPlayRequested, () async {
      try {
        if (mediaCurrent.value == null) {
          return;
        }
        SongModel song = mediaCurrent.value!;
        try {
          await playbackHelper.addPlaybackHistorySession(song.idx);
        } catch (e) {
          debugPrint("재생 기록 및 세션 추가 중 오류 발생: $e");
        }
        debugPrint("--------------- 재생 진행 ----------------");
        if (audioPlayerHandler.player.processingState == ProcessingState.ready) {
          await audioPlayerHandler.player.seek(currentPosition);
          await audioPlayerHandler.play();
          debugPrint("--------------- 재생 종료 ----------------");
        } else {
          debugPrint("오디오 소스 로드가 완료되지 않았습니다.");
        }
      } catch (e) {
        debugPrint("재생 명령이 시간 초과되었습니다: $e");
      }
    }, "play");
  }

  /// 일시정지 메서드
  Future<void> pause() async {
    debugPrint("--------------- 일시정지 실행 ----------------");
    await _handleActionWithLock(_isPauseRequested, () async {
      try {
        debugPrint("--------------- 일시정지 진행 ----------------");
        await audioPlayerHandler.pause();
        currentPosition = audioPlayerHandler.player.position;
        if (mediaCurrent.value != null) {
          try {
            SongModel song = mediaCurrent.value!;
            int sessionId = await getCurrentSessionId(song.idx);
            await playbackHelper.updatePlaybackHistorySession(
                sessionId, currentPosition.inSeconds, 1,
                currentPosition.inSeconds);
          } catch (e) {
            debugPrint("재생 기록 및 세션 업데이트 중 오류 발생: $e");
          }
        }
        debugPrint("현재 일시정지 위치: ${currentPosition.inSeconds}초");
        debugPrint("--------------- 일시정지 종료 ----------------");
      } catch (e) {
        debugPrint("일시정지 중 오류 발생: $e");
      }
    }, "pause");
  }

  /// 정지 메서드
  Future<void> stop() async {
    await _handleActionWithLock(_isStopRequested, () async {
      try {
        debugPrint("--------------- 재생 정지 ----------------");
        currentPosition = Duration.zero;
        duration = null;
        await audioPlayerHandler.stop();
        if (mediaCurrent.value != null) {
          SongModel song = mediaCurrent.value!;
          final sessionId = await getCurrentSessionId(song.idx); // 세션 ID 조회
          // 세션 종료
          try {
            await playbackHelper.endPlaybackSession(
                sessionId, currentPosition.inSeconds);
          } catch (e) {
            debugPrint("세션 종료 중 오류 발생: $e");
          }
        }
      } catch (e) {
        debugPrint("재생 정지 중 오류 발생: $e");
      }
    }, "stop");
  }

  /// 다음 곡 재생 메서드
  Future<void> next() async {
    await _handleActionWithLock(_isNextTrackRequested, () async {
      try {
        debugPrint("--------------- 다음 곡 재생 ----------------");
        currentPosition = Duration.zero;
        // 현재 재생 위치 및 속도 초기화
        await resetPositions();
        await resetPlaybackSpeed(false);

        await Future(() async {
          await audioPlayerHandler.player.seek(Duration.zero, index: null);

          // 셔플 모드가 활성화된 경우, 무작위로 다음 곡을 선택
          if (await audioPlayerHandler.player.shuffleModeEnabled) {
            int? currentIndex = audioPlayerHandler.player.currentIndex;
            List<int>? shuffleIndices = await audioPlayerHandler.player
                .shuffleIndices;
            if (shuffleIndices != null && shuffleIndices.isNotEmpty) {
              // 이미 재생된 인덱스를 제외하고 다음 인덱스를 찾음
              int? nextIndex = shuffleIndices.firstWhere(
                    (index) => index != currentIndex,
                orElse: () => shuffleIndices.first,
              );
              if (nextIndex != -1) {
                await audioPlayerHandler.player.seek(
                    Duration.zero, index: nextIndex);
              }
            }
          } else {
            await audioPlayerHandler.skipToNext();
          }
        }).timeout(Duration(seconds: 1), onTimeout: () {
          debugPrint("재생 명령이 시간 초과되었습니다."); // 1초 타임아웃 설정
        });
      } catch (e) {
        debugPrint("다음 곡 재생 중 오류 발생: $e");
      }
    }, "next");
  }

  /// 이전 곡 재생 메서드
  Future<void> previous() async {
    await _handleActionWithLock(_isPreviousTrackRequested, () async {
      try {
        print("--------------- 이전 곡 재생 ----------------");
        currentPosition = Duration.zero;
        await Future(() async {
          if (await audioPlayerHandler.player.shuffleModeEnabled) {
            // FIXME: 교차 재생 시, 이전 곡 무작위 변경되어야 함.
            await audioPlayerHandler.player.seek(
                Duration.zero, index: null); // 현재 인덱스를 무시하고 곡을 랜덤으로 변경
          }
          await audioPlayerHandler.skipToPrevious();
          await resetPositions();
          await resetPlaybackSpeed(false);

          audioPlayerHandler.player.currentIndexStream.listen((index) {
            if (index != null && index < mediaItemList.value.length) {
              mediaCurrent.value = mediaItemList.value[index].toSongModel();
            }
          });
          mediaCurrent.value = audioPlayerHandler.getCurrentMediaItem()?.toSongModel();
          duration = mediaCurrent.value?.duration;
          if (mediaCurrent.value != null) {
            SongModel song = mediaCurrent.value!;
            final sessionId = await getCurrentSessionId(song.idx); // 세션 ID 조회
            try {
              await playbackHelper.endPlaybackSession(
                  sessionId, currentPosition.inSeconds);
            } catch (e) {
              debugPrint("세션 종료 중 오류 발생: $e");
            }
          }
        }).timeout(Duration(seconds: 1), onTimeout: () {
          debugPrint("이전 곡 재생 명령이 시간 초과되었습니다.");
        });
      } catch (e) {
        debugPrint("이전 곡 재생 중 오류 발생: $e");
      }
    }, "previous");
  }

  /// 음원의 재생 위치를 이동하는 메서드
  Future seek(Duration position) async {
    try {
      await Future(() async {
        await audioPlayerHandler.seek(position);
      });
    } catch (e) {
      debugPrint("ERROR===> $e");
    }
  }

  /// 무작위 재생 모드를 켜거나 끄는 함수 추가
  Future<void> toggleShuffleMode() async {
    await _handleActionWithLock(_isAddToPlaylistRequested, () async {
      try {
        final newShuffleMode = !audioPlayerHandler.player.shuffleModeEnabled;
        await audioPlayerHandler.player.setShuffleModeEnabled(newShuffleMode);
        debugPrint("셔플 모드 ${newShuffleMode ? '활성화됨' : '비활성화됨'}");

        // 셔플 모드가 활성화되면 플레이리스트를 셔플 ON
        if (newShuffleMode) {
          await audioPlayerHandler.player.shuffle();
        }
      } catch (e) {
        debugPrint("셔플 모드 전환 중 오류 발생: $e");
      }
    }, "toggleShuffleMode");
  }

  /// N번 반복 재생 기능을 처리하는 메서드
  Future<void> handleRepeat(int repeatCount) async {
    remainingRepeats = repeatCount;
    repeatNotifier.value = repeatCount;

    if (remainingRepeats == -1) {
      audioPlayerHandler.player.setLoopMode(LoopMode.one);
      isRepeatModeOn = true;
    }
    else if (remainingRepeats == 0) {
      audioPlayerHandler.player.setLoopMode(LoopMode.off);
      isRepeatModeOn = false; // 반복 재생을 끔
    }
  }

  // TODO: N번 반복 재생 기능을 구현함. 현재 동작하지 않음.
  /* audioPlayerHandler.player.processingStateStream.listen((processingState) async {
      if (processingState == ProcessingState.completed) {

        if (remainingRepeats == -1) {
          audioPlayerHandler.player.setLoopMode(LoopMode.one);
          isRepeatModeOn = true; // 반복 재생을 켬
          print("무한 반복 재생 중: ${ComponentPlayer.instant.mediaCurrent.value
              ?.title}");
        }
        else if(remainingRepeats == 0) {
          audioPlayerHandler.player.setLoopMode(LoopMode.off);
          isRepeatModeOn = false; // 반복 재생을 끔
          print("반복 재생이 0입니다. 한번 더 재생 후 반복 재생을 끕니다.");
        }
          // 무한 반복 재생: 재생 위치를 초기화하고 재생을 반복
          if (!audioPlayerHandler.player.playing) {
            print("현재 재생 중인 음원: ${ComponentPlayer.instant.mediaCurrent.value?.title}");
            print("반복 재생을 위해 위치를 초기화합니다.");
            //await audioPlayerHandler.player.seek(Duration.zero);
            //await audioPlayerHandler.player.play();

            _isSeeking = false;
            return;
          }
        } else if (remainingRepeats > 1) {
          // 유한 반복 재생 부분은 현재 동작하지 않도록 주석 처리
          isRepeatModeOn = true; // 반복 재생을 켬
          remainingRepeats--;
          repeatNotifier.value = remainingRepeats;
          print("반복 재생 중: ${ComponentPlayer.instant.mediaCurrent.value?.title}, 남은 반복 횟수: $remainingRepeats");

          // 반복 재생 전, 이전 seek 이벤트가 완료되었는지 확인
          if (!audioPlayerHandler.player.playing) {
            print("현재 재생 중인 음원: ${ComponentPlayer.instant.mediaCurrent.value?.title}");
            print("반복 재생을 위해 위치를 초기화합니다.");
            await audioPlayerHandler.player.seek(Duration.zero);
            await audioPlayerHandler.player.play();

          _isSeeking = false;
          return;
          }
        } else if (remainingRepeats == 0 && isRepeatModeOn) {
          print("반복 재생이 0입니다. 한번 더 재생 후 반복 재생을 끕니다.");
          if (!audioPlayerHandler.player.playing) {
            await audioPlayerHandler.player.seek(Duration.zero);
            await audioPlayerHandler.player.play();
          }
          isRepeatModeOn = false; // 반복 재생을 끔
          _isSeeking = false;
          return;
        }
      }
      }
    });
  }*/

  /// 구간 반복 재생 - 시작점 설정 메서드
  Future<void> setStartPosition() async {
    try {
      startPosition = audioPlayerHandler.player.position;
    } catch (e) {
      debugPrint("시작점 설정 중 오류 발생: $e");
    } finally {
      debugPrint("잠금이 해제되었습니다.");
    }
  }

  /// 구간 반복 재생 - 끝점 설정 메서드
  Future<void> setEndPosition() async {
    try {
      endPosition = audioPlayerHandler.player.position;
      if (startPosition == null) {
        startPosition = Duration.zero;
        debugPrint("시작점이 설정되지 않아 0초로 자동 설정되었습니다.");
      }
    } catch (e) {
      debugPrint("끝점 설정 중 오류 발생: $e");
    }
  }

  /// 구간 반복의 시작점 및 끝점 초기화 메서드
  Future<void> resetPositions() async {
    try {
      startPosition = null;
      endPosition = null;
      debugPrint("시작점과 끝점이 초기화되었습니다.");
    } catch (e) {
      debugPrint("시작점과 끝점 초기화 중 오류 발생: $e");
    }
  }

  /// 구간 반복을 설정하는 메서드
  void enableLoop() {
    audioPlayerHandler.player.positionStream.listen((position) async {
      if (_isLooping && startPosition != null && endPosition != null) {
        if (position >= endPosition!) {
          await audioPlayerHandler.player.seek(startPosition!);
          debugPrint("구간 반복: ${startPosition!.inSeconds}초에서 ${endPosition!
              .inSeconds}초까지");
        }
      }
    });
  }

  /// 구간 반복을 해제하는 메서드
  void disableLoop() {
    _isLooping = false;
    debugPrint("구간 반복이 비활성화되었습니다.");
  }

  /// -0.5 배속 메서드
  Future<void> decreasePlaybackSpeed() async {
    await _handleActionWithLock(_isSpeedChangeRequested, () async {
      try {
        double currentSpeed = audioPlayerHandler.player.speed;
        double newSpeed = currentSpeed - 0.5;

        if (newSpeed < 0.5) {
          newSpeed = 0.5; // 최소 속도 제한
        }

        await audioPlayerHandler.player.setSpeed(newSpeed);
        print("현재 속도: $newSpeed 배속");
      } catch (e) {
        print("재생 속도 감소 중 오류 발생: $e");
        debugPrint("재생 속도 감소 중 오류 발생: $e");
      }
    }, "decreasePlaybackSpeed");
  }

  /// +0.5 배속 메서드
  Future<void> increasePlaybackSpeed() async {
    await _handleActionWithLock(_isSpeedChangeRequested, () async {
      try {
        double currentSpeed = audioPlayerHandler.player.speed;
        double newSpeed = currentSpeed + 0.5;

        if (newSpeed > 2.0) {
          newSpeed = 2.0; // 최대 속도 제한
        }

        await audioPlayerHandler.player.setSpeed(newSpeed);
        print("현재 속도: $newSpeed 배속");
      } catch (e) {
        print("재생 속도 증가 중 오류 발생: $e");
        debugPrint("재생 속도 증가 중 오류 발생: $e");
      }
    }, "increasePlaybackSpeed");
  }

  /// 속도 초기화 메서드
  Future<void> resetPlaybackSpeed(bool isAlert) async {
    await _handleActionWithLock(_isSpeedChangeRequested, () async {
      try {
        await audioPlayerHandler.player.setSpeed(1.0);
        if (isAlert) {
          print("현재 속도: ${audioPlayerHandler.player.speed} 배속");
        }
      } catch (e) {
        debugPrint("재생 속도 초기화 중 오류 발생: $e");
      }
    }, "resetPlaybackSpeed");
  }

  /// 재생 목록 추가 및 재생
  Future<void> updatePlaylistAndPlay(
      {required SongModel mediaItem, List<SongModel>? listMedia}) async {
    await _handleActionWithLock(_isAddToPlaylistRequested, () async {
      try {
        await audioPlayerHandler.player.pause(); // 현재 재생 중인 곡 멈춤

        // 새로운 재생 목록 생성
        List<MediaItem> newPlayingList = [];
        if (listMedia != null) {
          for (var song in listMedia) {
            FileInfo? fileInfo = await fifoCacheManager.cacheManager
                .getFileFromCache(song.id);

            if (fileInfo == null) {
              fileInfo =
              await fifoCacheManager.cacheManager.downloadFile(song.id);
            }

            if (fileInfo != null) {
              newPlayingList.add(MediaItem(
                idx: song.idx,
                id: fileInfo.file.path,
                // 캐시된 파일 경로 사용
                album: song.playlistName ?? 'Unknown Album',
                title: song.title,
                artist: song.artist,
                duration: song.duration,
                artUri: song.artUri,
              ));
            } else {
              // 캐시에 없으면 네트워크 URL 사용
              newPlayingList.add(MediaItem(
                idx: song.idx,
                id: song.id,
                // 네트워크 URL 사용
                album: song.playlistName ?? 'Unknown Album',
                title: song.title,
                artist: song.artist,
                duration: song.duration,
                artUri: song.artUri,
              ));
            }
          }
        }

        // 기존 재생 목록에서 중복된 항목 제거 후 새로운 목록 추가
        List<MediaItem> updatedMediaList = mediaItemList.value
            .where((item) =>
        !newPlayingList.any((newItem) =>
        newItem.idx == item.idx))
            .toList();
        updatedMediaList.addAll(newPlayingList);

        // BehaviorSubject에 값 추가하기 전에 중복 방지 로직
        if (!mediaItemList.isClosed && mediaItemList.hasValue &&
            mediaItemList.value != updatedMediaList) {
          try {
            mediaItemList.add(updatedMediaList); // 전체 재생 목록 업데이트
          } catch (e) {
            debugPrint("이미 이벤트가 발행 중입니다: $e");
          }
        }

        // 재생 목록을 업데이트하고 플레이어에 설정
        await audioPlayerHandler.updatePlaylist(updatedMediaList);

        // 새로 추가된 곡의 인덱스를 찾기
        int newTrackIndex = updatedMediaList.length - 1; // 마지막 인덱스로 설정

        // 새로 추가된 곡을 바로 재생하도록 설정
        await audioPlayerHandler.player.setAudioSource(
            audioPlayerHandler.playlist, initialIndex: newTrackIndex);
        await audioPlayerHandler.player.seek(
            Duration.zero); // 곡의 재생 시작점을 0초로 이동
        await play(); // 재생 시작
        await resetPositions();
        await resetPlaybackSpeed(false);

        // 현재 재생할 곡 정보 설정
        mediaCurrent.value = mediaItem.toSongModel();
        duration = mediaItem.duration;

        print("재생 목록이 업데이트되었습니다.");
      } catch (e) {
        debugPrint("ERROR===> $e");
      }
    }, "updatePlaylistAndPlay");
  }

  //저장된 파일 경로를 저장
  List<String?> decodedFilePath = [];

  /// 음원 한 곡 추가
  Future<void> addSongToEndOfPlaylist(SongModel songModel) async {
    await _handleActionWithLock(_isAddSingleTrackRequested, () async {
      try {
        debugPrint("--------------- 재생 목록에 음원 추가 ----------------");
        // AppAlert.showSuccess("해당 음원이 재생됩니다. 잠시만 기다려주세요.");
        audioPlayerHandler.processingState = ProcessingState.loading;

        // if(Platform.isAndroid) {
        //   final databaseHelper = DatabaseHelperFavoriteSong();
        //   final filePathData = await databaseHelper.getFilePathBySongIdx(songModel.idx);
        //
        //   print("current filePathData : ${filePathData?["filePath"]}");
        //   /// 이 부분은 나중에 제거하고 재생 50% 이상 되었을때 다운로드 로직 추가
        //   //     FileInfo? fileInfo = await fifoCacheManager.cacheManager
        //   //     .getFileFromCache(songModel.id);
        //   // FileInfo? fileInfoIOS;
        //   // /// 캐시에 없으면 다운로드 시작
        //   // Future<FileInfo?>? downloadFuture;
        //   // if (fileInfo == null && Platform.isAndroid) {
        //   //   debugPrint("캐시된 파일이 없습니다. 다운로드를 시작합니다.");
        //   //   downloadFuture =
        //   //       fifoCacheManager.cacheManager.downloadFile(songModel.id);
        //   // } else {
        //   //   debugPrint("캐시된 파일이 있습니다: ${fileInfo?.file.path}");
        //   // }
        //
        //   // 추가하려는 음원의 정보 생성
        //   MediaItem mediaItemToAdd;
        //   if (filePathData != null && Platform.isAndroid) {
        //     mediaItemToAdd = MediaItem(
        //       idx: songModel.idx,
        //       id: filePathData["filePath"],
        //       // 캐시된 파일 경로 사용
        //       album: songModel.playlistName ?? 'Unknown Album',
        //       title: songModel.title,
        //       artist: songModel.artist,
        //       duration: songModel.duration,
        //       artUri: songModel.artUri,
        //     );
        //   } else {
        //     mediaItemToAdd = MediaItem(
        //       idx: songModel.idx,
        //       id: songModel.id,
        //       // 네트워크 URL 사용
        //       album: songModel.playlistName ?? 'Unknown Album',
        //       title: songModel.title,
        //       artist: songModel.artist,
        //       duration: songModel.duration,
        //       artUri: songModel.artUri,
        //     );
        //   }
        //
        //   // 현재 재생 중인 곡의 인덱스
        //   final int? currentPlayingIndex = audioPlayerHandler.player.currentIndex;
        //   print("currentPlayingIndex : ${currentPlayingIndex}");
        //   // 동일한 곡이면 초를 0초로 수정하고 종료
        //   if (currentPlayingIndex != null &&
        //       currentPlayingIndex < mediaItemList.value.length &&
        //       mediaItemList.value[currentPlayingIndex].idx ==
        //           mediaItemToAdd.idx) {
        //     debugPrint("동일한 곡 재생 요청");
        //     await audioPlayerHandler.player.seek(
        //         Duration.zero, index: currentPlayingIndex);
        //     await play();
        //     debugPrint("현재 재생 중인 곡과 동일하므로 새로 추가하지 않고 초를 0초로 수정합니다.");
        //   }
        //   else {
        //     // 기존 재생 목록을 업데이트하여 중복된 항목을 제거하고 새 항목을 추가
        //     List<MediaItem> updatedMediaList = List.from(mediaItemList.value);
        //     // updatedMediaList.removeWhere((item) =>
        //     // item.idx == mediaItemToAdd.idx);
        //
        //     updatedMediaList.insert(0, mediaItemToAdd); // 새로 추가할 음악을 첫 번째 인덱스에 추가
        //     // updatedMediaList.add(mediaItemToAdd);
        //
        //     /// 재생목록을 100곡으로 제한 - 100곡이 넘으면 오래된 곡부터 제거
        //     if(updatedMediaList.length > 100) {
        //       updatedMediaList.removeLast();
        //     }
        //
        //     // 재생 목록을 업데이트
        //     mediaItemList.value = updatedMediaList;
        //     await audioPlayerHandler.updatePlaylist(updatedMediaList);
        //     debugPrint("재생목록 업데이트 완료: $updatedMediaList");
        //
        //     // 새 목록을 플레이어에 설정
        //     int newTrackIndex = 0;
        //     debugPrint("새 트랙 인덱스: $newTrackIndex");
        //
        //     await audioPlayerHandler.player.setAudioSource(
        //         audioPlayerHandler.playlist, initialIndex: newTrackIndex);
        //     debugPrint("AudioSource 설정 완료");
        //     await audioPlayerHandler.player.seek(
        //         Duration.zero, index: newTrackIndex);
        //     debugPrint("Seek 완료");
        //     debugPrint("추가하려는 음원: ${songModel.title}");
        //     mediaCurrent.value = mediaItemToAdd.toSongModel();
        //     await audioPlayerHandler.play();
        //     debugPrint("mediaCurrent 설정 완료");
        //   }
        // }
        // else
        if(Platform.isIOS || Platform.isAndroid) {
          /// url 형태의 음원 파일을 wav로 디코딩
          // String? cachePath = await searchSong.decodeOpusToWav(songModel.id);
          // searchSong.progressiveDownload(songModel.id);
          final cacheDir = await fifoCacheManager.getCacheDirectoryPath();
          final cachePath = "${cacheDir}/${songModel.id.replaceAll("/", "_").replaceAll(":", "-").replaceAll(".opus", "")}.wav";
          /// TODO: api 주소 로컬로 수정 필요
          /// TODO: progressive download api 호출 하는 함수
          StreamProgressive().progressiveDownload("https://api.jigpu.com:2126/stream_opus_audio_full", cachePath);

          // 추가하려는 음원의 정보 생성
          MediaItem mediaItemToAdd = MediaItem(
            idx: songModel.idx,
            id: cachePath,
            // 캐시된 파일 경로 사용
            album: songModel.playlistName ?? 'Unknown Album',
            title: songModel.title,
            artist: songModel.artist,
            duration: songModel.duration,
            artUri: songModel.artUri,
          );

          // 현재 재생 중인 곡의 인덱스
          final int? currentPlayingIndex = audioPlayerHandler.player.currentIndex;
          print("currentPlayingIndex : ${currentPlayingIndex}");
          // 동일한 곡이면 초를 0초로 수정하고 종료1
          if (currentPlayingIndex != null &&
              currentPlayingIndex < mediaItemList.value.length &&
              mediaItemList.value[currentPlayingIndex].idx ==
                  mediaItemToAdd.idx) {
            debugPrint("동일한 곡 재생 요청");
            await audioPlayerHandler.player.seek(
                Duration.zero, index: currentPlayingIndex);
            await play();
            debugPrint("현재 재생 중인 곡과 동일하므로 새로 추가하지 않고 초를 0초로 수정합니다.");
          } else {
            while(!StreamProgressive.canFileOpen) {
              await Future.delayed(const Duration(milliseconds: 300));
            }

            // 기존 재생 목록을 업데이트하여 중복된 항목을 제거하고 새 항목을 추가
            List<MediaItem> updatedMediaList = List.from(mediaItemList.value);
            // updatedMediaList.removeWhere((item) =>
            // item.idx == mediaItemToAdd.idx);

            updatedMediaList.insert(0, mediaItemToAdd); // 새로 추가할 음악을 첫 번째 인덱스에 추가
            // updatedMediaList.add(mediaItemToAdd);

            /// 재생목록을 100곡으로 제한 - 100곡이 넘으면 오래된 곡부터 제거
            if(updatedMediaList.length > 100) {
              updatedMediaList.removeLast();
            }

            // 재생 목록을 업데이트
            mediaItemList.value = updatedMediaList;
            await audioPlayerHandler.updatePlaylist(updatedMediaList);

            debugPrint("재생목록 업데이트 완료: $updatedMediaList");

            // 새 목록을 플레이어에 설정
            int newTrackIndex = 0;
            debugPrint("새 트랙 인덱스: $newTrackIndex");

            await audioPlayerHandler.player.setAudioSource(
                audioPlayerHandler.playlist, initialIndex: newTrackIndex);
            debugPrint("AudioSource 설정 완료");
            await audioPlayerHandler.player.seek(
                Duration.zero, index: newTrackIndex);
            debugPrint("Seek 완료");
            debugPrint("추가하려는 음원: ${songModel.title}");
            mediaCurrent.value = mediaItemToAdd.toSongModel();

            // await streamProgressive.play(downloadedFilePath);
            await audioPlayerHandler.play();
            debugPrint("mediaCurrent 설정 완료");
          }
          return;
        }

      } catch (e) {
        debugPrint("ERROR===> $e");
      }
    }, "addSongToEndOfPlaylist");
  }

  /// 현재 재생 목록에서 음원 삭제
  Future<void> removeSongFromPlaylistAndPlayNext(SongModel songModel) async {
    await _handleActionWithLock(_isRemoveFromPlaylistRequested, () async {
      try {
        debugPrint("--------------- 재생 목록에서 음원 삭제 ----------------");
        _isRemoveFromPlaylistRequested.add(true);
        debugPrint("삭제하려는 음원: ${songModel.title}");

        MediaItem mediaItemToRemove = MediaItem(
          idx: songModel.idx,
          id: songModel.id,
          album: songModel.playlistName ?? 'Unknown Album',
          title: songModel.title,
          artist: songModel.artist,
          duration: songModel.duration,
          artUri: songModel.artUri,
        );

        MediaItem? currentPlayingItem = audioPlayerHandler
            .getCurrentMediaItem();
        bool isCurrentlyPlaying = currentPlayingItem?.id ==
            mediaItemToRemove.id;

        await audioPlayerHandler.removeSongFromPlaylist(mediaItemToRemove);
        mediaCurrent = ValueNotifier(null);
        if (!mediaItemList.isClosed) {
          mediaItemList.add(audioPlayerHandler.getPlaylist() ?? []);
        }


        if (isCurrentlyPlaying) {
          if (mediaItemList.value.isNotEmpty) {
            await next();
          } else {
            await stop();
          }
        }

        MediaItem? finalPlayingItem = audioPlayerHandler.getCurrentMediaItem();
        if (finalPlayingItem != null) {
          debugPrint("현재 재생 중인 음원: ${finalPlayingItem.title}");
        } else {
          debugPrint("현재 재생 중인 음원이 없습니다.");
        }
      } catch (e) {
        debugPrint("ERROR===> $e");
      }
    }, "removeSongFromPlaylistAndPlayNext");
  }

  /// 세션 ID 조회 메서드
  Future<int> getCurrentSessionId(int songIdx) async {
    final db = await playbackHelper.database;
    List<Map<String, dynamic>> result = await db.query(
      'playback',
      where: 'songIdx = ? AND sessionEndTime IS NULL',
      whereArgs: [songIdx],
    );
    if (result.isNotEmpty) {
      return result.first['sessionId'];
    }
    return -1;
  }

  Future<String?> decodeOpusToWav(String opusUrl) async {
    // URL에서 파일 이름 추출
    print("opusurl : ${opusUrl}");
    final fileName = opusUrl.replaceAll(":", "").replaceAll("/", "_").split(".opus").first; // 파일 이름을 URL에서 가져오기
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
}

extension MediaItemExtension on MediaItem {
  SongModel toSongModel() {
    return SongModel(
      idx: idx,
      id: id,
      playlistName: album,
      title: title,
      artist: artist,
      duration: duration,
      artUri: artUri,
    );
  }
}


/** [음원 재생 상태를 BehaviorSubject로 상태 관리]
 * idle: 오디오 소스 미로드 상태
 * loading: 오디오 소스 로드 중
 * buffering: 버퍼링 중, 재생 불가
 * ready: 버퍼링 완료, 재생 가능
 * completed: 재생 완료, 끝에 도달
 **/

// NOTE: AudioPlayerHandler 클래스 : 오디오 플레이어의 상태를 관리하는 클래스
class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  /// 오디오 플레이어 관련 객체
  final AudioPlayer player = AudioPlayer();                     // 오디오 재생을 담당하는 싱글톤 플레이어 객체
  final FifoCacheManager fifoCacheManager = FifoCacheManager(); // FIFO 캐시 매니저 사용

  List<MediaItem>? listMedias;                                  // 재생 목록(플레이리스트)에 포함된 미디어 아이템의 리스트
  StreamSubscription<int?>? _currentIndexSubscription;          // 현재 재생 중인 곡의 인덱스 변화를 추적하는 스트림 구독 객체
  late CacheManager cacheManager = DefaultCacheManager();       // 기본 캐시 매니저 사용

  /// 오디오 플레이어의 상태를 설정하는 변수
  final Lock _lock = Lock();
  final BehaviorSubject<ProcessingState> _processingStateSubject = BehaviorSubject.seeded(ProcessingState.idle);
  final BehaviorSubject<bool> _isPlayerProcessing = BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> _isPlayProcessing = BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> _isPauseProcessing = BehaviorSubject.seeded(false);

  /// [Getter] 현재 재생 상태를 구독할 수 있는 스트림을 반환
  Stream<ProcessingState> get processingStateStream => _processingStateSubject.stream;
  Stream<bool> get isPlayerProcessingStream => _isPlayerProcessing.stream;

  /// [Setter] 새로운 재생 상태를 설정
  set processingState(ProcessingState newState) { _processingStateSubject.add(newState); }

  /// 음원 재생된 시간이 총 재생길이의 50% 이상이면 다운로드하는 변수
  Timer? _timer;
  int _seconds = 0;
  bool isPaused = false;

  /// 여러 개의 오디오 소스를 하나의 재생 목록으로 결합하여 관리하는 클래스 (just_audio 패키지)
  final ConcatenatingAudioSource playlist = ConcatenatingAudioSource(
    useLazyPreparation: false,                                  // 재생목록의 음원들을 백그라운드에서 미리 준비하여 로드함. -> 로딩 시간 단축
    shuffleOrder: DefaultShuffleOrder(),                        // 기본 순서
    children: [],                                               // 음원 목록 (음원이 추가될 때마다 이 목록에 추가되는 방식)
  );

  /// 재생 목록에 음원을 추가하는 메서드
  void setMediaItem(MediaItem newMediaItem) {
    if (mediaItem.isClosed) return;
    try {
      mediaItem.add(newMediaItem);
    } catch (e) {
      debugPrint("mediaItem 업데이트 중 오류 발생: $e");
    }
  }

  /// 오디오 플레이어 상태를 설정하는 메서드
  void setPlaybackState(PlaybackState newState) {
    if (playbackState.isClosed) return;
    try {
      playbackState.add(newState);
    } catch (e) {
      debugPrint("playbackState 업데이트 중 오류 발생: $e");
    }
  }

  /// 오디오 플레이어 상태를 관리하고, 실시간으로 감지 밎 이벤트를 처리하는 생성자
  AudioPlayerHandler() {
    _listenToPlaybackEventStream();
    _listenToCurrentIndexStream();
    _listenToPlayingStream();
    _handlePlayerStateChanges();
    _setupCurrentIndexStreamListener();
    _initializeCache();
    initPlayerListener();
  }

  Timer? _playbackTimer;
  int totalPlayTimeSeconds = 0; // 총 재생 시간 (초)

  void initPlayerListener() {
    player.playerStateStream.listen((playerState) {
      if (playerState.playing) {
        // 재생 중일 때 타이머 시작 (1초마다 1초를 더함)
        _startTimer();
      } else if (playerState.processingState == ProcessingState.completed) {
        // 완전히 정지 상태가 되었을 때 타이머를 멈춤
        _stopTimer();
        print("총 재생 시간: $totalPlayTimeSeconds 초");
      } else {
        // 일시정지일 때 타이머 일시 정지
        _pauseTimer();
      }
    });
  }

// 타이머 시작 (재생 중일 때만 실행)
  void _startTimer() {
    if (_playbackTimer == null || !_playbackTimer!.isActive) {
      _playbackTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        totalPlayTimeSeconds += 1;
      });
    }
  }

// 타이머 일시정지
  void _pauseTimer() {
    _playbackTimer?.cancel();
  }

// 타이머 완전히 멈추기
  void _stopTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }

  /// 플레이어 상태를 업데이트하는 메서드
  void _listenToPlaybackEventStream() {
    player.playbackEventStream.listen((event) {
      final newState = _transformEvent(event);
      setPlaybackState(newState);
    });
  }

  /// 현재 재생 중인 곡을 처리하는 메서드
  void _listenToCurrentIndexStream() {
    player.currentIndexStream.listen((currentIndex) {
      if (currentIndex != null && currentIndex < (listMedias?.length ?? 0)) {
        final newMediaItem = listMedias![currentIndex];
        setMediaItem(newMediaItem);
      }
    });
  }

  /// 재생 상태 변화를 구독하고 playbackState를 업데이트하는 메서드
  void _listenToPlayingStream() {
    player.playingStream.listen((isPlaying) {
      playbackState.add(playbackState.value.copyWith(
        playing: isPlaying,
      ));
    });
  }

  /// 재생/일시정지/정지 등의 액션을 처리하기 위한 헬퍼 메서드
  Future<void> _handleActionWithLock({
    required BehaviorSubject<bool> processingFlag,
    required Future<void> Function() action,
    String? actionName,
  }) async {
    //await _lock.synchronized(() async {
    processingFlag.add(true);
    try {
      debugPrint("$actionName 실행 시작.");
      await action();
      debugPrint("$actionName 실행 완료.");
    } catch (e) {
      debugPrint("$actionName 실행 중 오류 발생: $e");
      print("오류 발생: $e");
    } finally {
      processingFlag.add(false);
      debugPrint("$actionName 실행 잠금 해제.");
    }
    //});
  }

  /// 현재 인덱스 변경 시 처리
  void _setupCurrentIndexStreamListener() {
    _currentIndexSubscription?.cancel();
    _currentIndexSubscription = player.currentIndexStream.distinct().listen((index) {
      if (index != null && index < (listMedias?.length ?? 0)) {
        if (_isPlayerProcessing.value == ProcessingState.ready
            && listMedias![index].id != ComponentPlayer.instant.mediaCurrent.value?.id) {
          debugPrint("--------------- 현재 재생 중인 음원 재조정 ----------------");
          ComponentPlayer.instant.mediaCurrent.value = listMedias![index].toSongModel();
          debugPrint("재조정 완료 - 현재 재생 중인 음원: ${listMedias![index].title}");
          debugPrint("재조정 완료 - 화면에 표시되는 음원: ${ComponentPlayer.instant.mediaCurrent.value?.title}");
        }
      }
    });
  }

  /// 캐시 초기화 설정 메서드
  Future<void> _initializeCache() async {
    await fifoCacheManager.manageCache();
  }

  /// 1. 오디오 플레이어의 상태 변화에 따라 재생 동작을 제어합니다.
  void _handlePlayerStateChanges() {
    player.playerStateStream.listen((state) async {
      switch (state.processingState) {
        case ProcessingState.completed:
          _processingStateSubject.add(ProcessingState.completed);
          if (ComponentPlayer.instant.isRepeatModeOn) {
            try {
              if (!player.positionStream.isBroadcast && !player.processingStateStream.isBroadcast) {
                await player.seek(Duration.zero);
              }
            } catch (e) {
              debugPrint("반복 재생 중 에러 발생: $e");
            }
          } else {
            try {
              // 재생목록이 비어있으면 skipToNext를 호출하지 않도록 방어 로직 추가
              if (listMedias != null && listMedias!.isNotEmpty) {
                await skipToNext();

                // 현재 재생 곡의 인덱스가 재생 목록의 범위를 벗어났을 경우 첫 번째 곡으로 이동
                if (!(player.currentIndex != null && player.currentIndex! < listMedias!.length)) {
                  await player.seek(Duration.zero, index: 0);
                  ComponentPlayer.instant.mediaCurrent.value = listMedias![0].toSongModel();
                  debugPrint("첫 번째 곡으로 이동: ${ComponentPlayer.instant.mediaCurrent.value?.title}");
                }
              } else {
                // 재생 목록이 비어 있을 때 처리
                debugPrint("재생 목록이 비어 있습니다. 다음 곡으로 건너뛸 수 없습니다.");
                await ComponentPlayer.instant.stop();  // 재생 중지
              }
            } catch (e) {
              debugPrint("다음 곡으로 넘어가는 중 에러 발생: $e");

              if (player.currentIndex == null || player.currentIndex! >= (listMedias?.length ?? 0)) {
                if (listMedias != null && listMedias!.isNotEmpty) {
                  await player.seek(Duration.zero, index: 0);
                  ComponentPlayer.instant.mediaCurrent.value = listMedias![0].toSongModel();
                } else {
                  debugPrint("재생 목록이 비어 있습니다. 첫 번째 곡으로 이동할 수 없습니다.");
                }
              }
              debugPrint("다음 곡 재생 완료: ${ComponentPlayer.instant.mediaCurrent.value?.title}");
              ComponentPlayer.instant.play();
            }
          }
          break;
        case ProcessingState.ready:
          Duration(milliseconds: 800); // 호출 간격을 두어 이벤트 중복 방지
          _processingStateSubject.add(ProcessingState.ready);
          break;
        case ProcessingState.buffering:
          _processingStateSubject.add(ProcessingState.buffering);
          break;
        case ProcessingState.loading:
          _processingStateSubject.add(ProcessingState.loading);
          break;

        case ProcessingState.idle:
          _processingStateSubject.add(ProcessingState.idle);
          break;

        default:
          _processingStateSubject.add(ProcessingState.idle);
          break;
      }
      debugPrint("--------------- 음원 상태: ${state.processingState} ----------------");
    }, onError: (error) {
      debugPrint("플레이어 상태 스트림 오류: $error");
    });

    /// 2. 음원 재생 시간을 처리하는 메서드
    player.positionDiscontinuityStream.listen((discontinuity) async {
      if (!player.positionStream.isBroadcast && !player.processingStateStream.isBroadcast) {
        // (1) 오디오 플레이어의 재생 위치가 자동으로 변경된 경우 (= 오디오 플레이어의 재생되는 곡이 끝까지 재생된 경우)
        if (discontinuity.reason == PositionDiscontinuityReason.autoAdvance) {
          int index = player.currentIndex ?? 0;

          // -1- 반복 재생 모드인 경우
          if (ComponentPlayer.instant.isRepeatModeOn) {
            debugPrint("반복 재생 중: ${ComponentPlayer.instant.mediaCurrent.value?.title}");
          }

          // -2- 반복 재생 모드가 아닌 경우
          else {
            // 다음 곡 전환 시, 다음 곡이 있다면 다음 곡으로 이동
            if (index < listMedias!.length) {
              ComponentPlayer.instant.mediaCurrent.value = listMedias![index + 1].toSongModel();
            }

            // 다음 곡이 없다면 첫 번째 곡으로 이동
            else {
              await player.seek(Duration.zero, index: 0);
              ComponentPlayer.instant.mediaCurrent.value = listMedias![0].toSongModel();
            }
          }
        }

        // (2) 오디오 플레이어의 재생 위치가 수동으로 변경된 경우
        else if (discontinuity.reason.name == "seek") {
          await player.seek(discontinuity.event.updatePosition);
          ComponentPlayer.instant.mediaCurrent.value = getCurrentMediaItem()?.toSongModel();
          debugPrint("${discontinuity.event.updatePosition.inSeconds}초로 이동");

        }
      }
    }, onError: (error) {
      debugPrint("위치 불연속 스트림 오류: $error");
    });
  }

  /// 3. 재생 목록(플레이리스트)을 초기화하고, 플레이어에 설정합니다.
  Future initializePlayerWithPlaylist(MediaItem item, {List<MediaItem>? items}) async {
    try {
      // (1) 재생 목록 초기화하고, 첫 번째 곡부터 재생하도록 설정
      await playlist.clear();
      listMedias = [ ...items ?? []];

      // 캐시된 AudioSource 생성
      List<AudioSource> audioSources = [];
      for (var media in listMedias!) {
        try {
          // 캐시된 파일의 경로 가져오기
          FileInfo? fileInfo = await fifoCacheManager.cacheManager.getFileFromCache(media.id);

          // 캐시에 없으면 다운로드 후 캐시에 저장
          if (fileInfo == null) {
            fileInfo = await fifoCacheManager.cacheManager.downloadFile(media.id);
          }

          // 캐시된 파일이 있으면 로컬 파일 경로 사용
          if (fileInfo != null) {
            audioSources.add(AudioSource.uri(Uri.file(fileInfo.file.path)));
            debugPrint("캐시된 파일 사용: ${media.title}");
          }
          // 다운로드 실패 시 네트워크 URL 사용
          else {
            audioSources.add(AudioSource.uri(Uri.parse(media.id)));
            debugPrint("네트워크 URL 사용: ${media.title}");
          }
        } catch (e) {
          // 캐시 처리 중 오류 발생 시 네트워크 URL 사용
          audioSources.add(AudioSource.uri(Uri.parse(media.id)));
          debugPrint("캐시 처리 중 오류 발생, 네트워크 URL 사용: ${media.title}, 오류: $e");
        }
      }
      await playlist.addAll(audioSources);

      // 선택한 곡의 인덱스를 계산하여 초기 인덱스로 설정
      int initialIndex = listMedias!.indexOf(item);
      await player.setAudioSource(playlist, initialIndex: initialIndex, preload: false);
      ComponentPlayer.instant.mediaCurrent.value = listMedias![initialIndex].toSongModel();

      // (2) 재생 음원 위치 변경 이벤트 처리
      player.positionDiscontinuityStream.listen((discontinuity) {
        // - 재생 음원 위치가 자동으로 변경된 경우
        if (discontinuity.reason == PositionDiscontinuityReason.autoAdvance) {
          int index = player.currentIndex ?? 0;

          if(!ComponentPlayer.instant.isRepeatModeOn) {
            index = (player.currentIndex ?? 0) + 1;

            // 다음 음원 전환 시, 목록의 마지막 음원이 아니라면 다음 음원으로 이동
            if (index < listMedias!.length) {
              player.seek(Duration.zero, index: index);
              mediaItem.add(listMedias![index]);
              ComponentPlayer.instant.mediaCurrent.value = listMedias![index].toSongModel();
            } else {
              // 목록의 끝에 도달하면 다시 첫 번째 음원으로 이동
              player.seek(Duration.zero, index: 0);
              mediaItem.add(listMedias![0]);
              ComponentPlayer.instant.mediaCurrent.value = listMedias![0].toSongModel();
            }
          }
        }

        // - 재생 음원의 위치가 수동으로 변경된 경우
        else {
          if (discontinuity.reason.name == "seek") {
            player.seek(discontinuity.event.updatePosition);
          }
        }
      });
    } catch (e) {
      debugPrint("오디오 플레이어 초기화 중 오류 발생: $e");
    }
  }

  /// 재생 메서드
  @override
  Future<void> play() async {
    try {
      await _handleActionWithLock(
        processingFlag: _isPlayProcessing,
        action: () async {
          debugPrint("AudioPlayerHandler: play() 호출");
          await player.play();
          /// 일시정지 상태면 resume,
          // if(!isPaused) {
          //   await startTimer();
          // }else {
          //   await resumeTimer();
          // }
          debugPrint("AudioPlayerHandler: play() 완료");
        },
        actionName: "play",
      );
    } catch (e) {
      debugPrint("Error while playing: $e");
    }

  }

  /// 일시정지 메서드
  @override
  Future<void> pause() async {
    debugPrint("AudioPlayerHandler: 현재 일시정지 실행 상태: ${_isPauseProcessing.value}");
    await _handleActionWithLock(
      processingFlag: _isPauseProcessing,
      action: () async {
        debugPrint("AudioPlayerHandler: pause() 호출");
        await player.pause();
        // await pauseTimer();
        debugPrint("AudioPlayerHandler: pause() 완료");
      },
      actionName: "pause",
    );
  }

  /// 재생 위치 이동 메서드 (Seek)
  @override
  Future<void> seek(Duration position) async {
    try {
      await player.seek(position);
      debugPrint("AudioPlayerHandler: Seek 완료 - 위치: ${position.inSeconds}초");
    } catch (e) {
      debugPrint("AudioPlayerHandler: Error while seeking: $e");
      print("오류 발생: $e");
    }
  }

  /// 정지 메서드
  @override
  Future<void> stop() async {
    await _handleActionWithLock(
      processingFlag: _isPlayProcessing, // stop은 play 상태에 영향을 미칠 수 있으므로 play processing flag 사용
      action: () async {
        if (player.playing) {
          debugPrint("AudioPlayerHandler: stop() 호출");
          // await stopTimer();
          await player.stop();
          debugPrint("AudioPlayerHandler: stop() 완료");
        }
      },
      actionName: "stop",
    );
  }


  /// 다음 곡으로 이동
  @override
  Future<void> skipToNext() async {
    await _handleActionWithLock(
      processingFlag: _isPlayProcessing, // skipToNext는 play 상태에 영향을 미칠 수 있으므로 play processing flag 사용
      action: () async {
        debugPrint("AudioPlayerHandler: skipToNext() 호출");
        if (listMedias == null || listMedias!.isEmpty) {
          debugPrint("AudioPlayerHandler: 재생 목록이 비어 있습니다.");
          return;
        }
        final indexCurrent = listMedias!.indexWhere((element) => element.id.toString() == ComponentPlayer.instant.mediaCurrent.value?.id.toString());
        int index = indexCurrent + 1;

        if (index < listMedias!.length) {
          await player.seek(Duration.zero, index: index);
          setMediaItem(listMedias![index]);
          ComponentPlayer.instant.mediaCurrent.value = listMedias![index].toSongModel();
        } else {
          await player.seek(Duration.zero, index: 0);
          mediaItem.add(listMedias![0]);
          ComponentPlayer.instant.mediaCurrent.value = listMedias![0].toSongModel();
        }
      },
      actionName: "skipToNext",
    );

    // await stopTimer();
    // TODO: super.skipToNext()가 반드시 필요한지 확인
    return super.skipToNext();
  }

  /// 이전 곡으로 이동
  @override
  Future<void> skipToPrevious() async {
    await _handleActionWithLock(
      processingFlag: _isPlayProcessing, // skipToPrevious는 play 상태에 영향을 미칠 수 있으므로 play processing flag 사용
      action: () async {
        debugPrint("AudioPlayerHandler: skipToPrevious() 호출");
        if (listMedias == null || listMedias!.isEmpty) {
          debugPrint("AudioPlayerHandler: 재생 목록이 비어 있습니다.");
          return;
        }
        final currentMedia = ComponentPlayer.instant.mediaCurrent.value;
        final currentIndex = listMedias!.indexWhere(
              (element) => element.id.toString() == currentMedia?.id.toString(),
        );
        int previousIndex = (currentIndex > 0) ? currentIndex - 1 : listMedias!.length - 1;

        await player.seek(Duration.zero, index: previousIndex);
        mediaItem.add(listMedias![previousIndex]);
        ComponentPlayer.instant.mediaCurrent.value = listMedias![previousIndex].toSongModel();
        debugPrint("AudioPlayerHandler: 이전 곡으로 이동 - ${listMedias![previousIndex].title}");
      },
      actionName: "skipToPrevious",
    );

    // await stopTimer();
    // TODO: super.skipToPrevious()가 반드시 필요한지 확인
    return super.skipToPrevious();
  }

  /// PlaybackState 변환 메서드
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.pause,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [ 0, 1, 3 ],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState]!,
      playing: player.playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
      queueIndex: event.currentIndex,
      updateTime: DateTime.now(),
    );
  }

  /// 현재 재생 목록 가져오기
  List<MediaItem>? getPlaylist() {
    return listMedias;
  }

  /// 재생 목록에 음원 uri 추가
  Future<void> addSongToPlaylist(MediaItem mediaItem) async {
    try {
      // 캐시된 파일의 경로 가져오기
      FileInfo? fileInfo = await fifoCacheManager.cacheManager.getFileFromCache(mediaItem.id);

      if (fileInfo == null) {
        // 캐시에 없으면 다운로드 후 캐시에 저장
        fileInfo = await fifoCacheManager.cacheManager.downloadFile(mediaItem.id);
      }

      AudioSource source;
      if (fileInfo != null) {
        // 캐시된 파일이 있으면 로컬 파일 경로 사용
        source = AudioSource.uri(Uri.file(fileInfo.file.path));
        debugPrint("캐시된 파일 사용하여 추가: ${mediaItem.title}");
      } else {
        // 다운로드 실패 시 네트워크 URL 사용
        source = AudioSource.uri(Uri.parse(mediaItem.id));
        debugPrint("네트워크 URL 사용하여 추가: ${mediaItem.title}");
      }

      // 플레이리스트에 AudioSource 추가
      listMedias?.add(mediaItem);
      await playlist.add(AudioSource.uri(Uri.parse(mediaItem.id)));
      debugPrint("추가된 음원: ${mediaItem.title}");
      debugPrint("현재 재생목록: ${listMedias?.map((item) => item.title).toList()}");
    } catch (e) {
      debugPrint("음원 추가 실패: ${mediaItem.title}");
      throw Exception("음원을 재생목록에 추가할 수 없습니다: ${e.toString()}");
    }
  }

  /// 재생 목록에서 음원 제거
  Future<void> removeSongFromPlaylist(MediaItem mediaItem) async {
    try {
      int index = listMedias?.indexOf(mediaItem) ?? -1;
      if (index != -1) {
        listMedias?.removeAt(index);
        await playlist.removeAt(index);
        debugPrint("삭제된 음원: ${mediaItem.title}");
        debugPrint("현재 재생목록: ${listMedias?.map((item) => item.title).toList()}");
      }
    } catch (e) {
      debugPrint("음원 삭제 실패: ${mediaItem.title}");
      throw Exception("음원을 재생목록에서 삭제할 수 없습니다: ${e.toString()}");
    }
  }

  /// 재생 목록 업데이트
  Future<void> updatePlaylist(List<MediaItem> newPlaylist) async {
    debugPrint("in updatePlaylist, ${newPlaylist.length} : $newPlaylist");
    try {
      listMedias = newPlaylist;
      updateQueue(newPlaylist);
      await playlist.clear();
      for (var item in newPlaylist) {
        if(item.id.contains("MusicCacheKey")) {

          final file = File(item.id);
          /// stream 이 반환된다. 디코딩이 끝날때까지 읽는다.
          final sink = await file.openRead();

          /// 파일이 생성될 때까지 기다리기
          while (!await file.exists()) {
            await Future.delayed(Duration(milliseconds: 1000)); // 1000ms마다 파일 존재 여부 확인
          }
          if(await file.existsSync()) {
            /// 이 안에서 할거
            // 파일 경로로 AudioSource를 추가하여 플레이리스트에 추가
            await playlist.add(AudioSource.uri(Uri.file(item.id)));
          }else {
            print("파일 생기기 이전");
          }
        }else if(item.id.contains("https://")) {
          print("current wich uri");
          await playlist.add(AudioSource.uri(Uri.parse(item.id)));
        }
      }

      debugPrint("playlist data : ${playlist.length}, ${playlist.runtimeType}, $playlist");
      await player.setAudioSource(playlist);
      debugPrint("재생목록 업데이트 완료: ${listMedias?.map((item) => item.title).toList()}");
    } catch (e) {
      debugPrint("재생목록 업데이트 실패: $e");
      throw Exception("재생목록을 업데이트할 수 없습니다: ${e.toString()}");
    }
  }

  /// 현재 재생 중인 음원 가져오기
  MediaItem? getCurrentMediaItem() {
    if (player.audioSource is ConcatenatingAudioSource) {
      ConcatenatingAudioSource concatenatingSource = player.audioSource as ConcatenatingAudioSource;
      int currentIndex = player.currentIndex ?? 0;
      if (currentIndex < concatenatingSource.children.length) {
        return listMedias?[currentIndex];
      }
    }
    return null;
  }
}
