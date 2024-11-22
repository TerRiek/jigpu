import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_component/widgets/widget_animation_click.dart';
import 'package:just_audio/just_audio.dart';
import 'package:jigpu_1/models/data_view_model.dart';
import 'package:jigpu_1/pages/home/bloc/home_bloc.dart';
// import 'package:jigpu_1/pages/songs/song_detail_screen.dart';
import 'package:jigpu_1/utils/components/audio_player/component_player.dart';
import 'package:jigpu_1/utils/db_helper/albums/database_helper_album.dart';
// import 'package:jigpu_1/utils/extensions/extension_context.dart';
import 'package:jigpu_1/utils/gen/export.gen.g.dart';
import 'package:jigpu_1/utils/widgets/button/widget_animation_click_v2.dart';
// import 'package:jigpu_1/utils/widgets/widget_page_basic.dart';

import '../../models/song_model.dart';
// import '../../pages/home/home_bottom_menu.dart';
// import 'text/widget_text_scroll.dart';

class WidgetMenuMusic extends StatefulWidget {
  const WidgetMenuMusic({super.key});

  @override
  State<WidgetMenuMusic> createState() => _WidgetMenuMusicState();
}

class _WidgetMenuMusicState extends State<WidgetMenuMusic> {
  SongModel? previousSong; // 이전 곡 정보를 저장할 변수
  SongModel? currentSong; // 현재 곡 정보를 저장할 변수
  bool isPlaying = true; // 현재 재생 상태
  int currentIndex = 0; // 현재 재생 중인 곡의 인덱스F
  AudioProcessingState processingState = AudioProcessingState.loading; // 오디오 처리 상태
  int mediaListLength = -1; // mediaItemList의 길이
  bool isLoading = false;

  // late HomeBloc bloc;
  late StreamSubscription<PlaybackState> _playbackStateSubscription;
  Map<String, dynamic> songDetailParams = {};
  DataViewModel? searchResult;

  @override
  void initState() {
    super.initState();

    final player = ComponentPlayer.instant.audioPlayerHandler.player;

    isPlaying = player.playing;
    ComponentPlayer.instant.mediaItemList.listen((list) {
      if(mounted) {
        setState(() {
          mediaListLength = list.isEmpty ? -1 : list.length;
          debugPrint("mediaItemList 업데이트됨. 현재 길이: $mediaListLength");
        });
      }
    });

    _playbackStateSubscription = ComponentPlayer.instant.audioPlayerHandler.playbackState.listen((event) {
      debugPrint("PlaybackState 업데이트: playing=${event.playing}, processingState=${event.processingState}");
      if(event.processingState == AudioProcessingState.ready) {
        debugPrint("현재 재생 중인 곡: ${ComponentPlayer.instant.mediaCurrent.value?.title}");
        currentSong = ComponentPlayer.instant.mediaCurrent.value;
      }
      if (currentSong != null) {
        searchForSong(currentSong!.title, currentSong!.artist!);

        currentSong?.setIdx(2);
        currentSong?.setImageLocal('assets/csv/album/KEI-0010.webp');
      }

      if(mounted) {
        setState(() {
          isPlaying = event.playing;
          processingState = event.processingState == AudioProcessingState.ready
              ? AudioProcessingState.ready
              : AudioProcessingState.loading;
        });
      }
    });
  }

  Future<void> searchForSong(String title, String artist) async {
    // searchSong()을 호출하고 결과를 저장
    searchResult = await searchSong(title, artist);
    //print("in searchForSong : ${searchResult?.idx}, ${searchResult?.title}, ${searchResult?.artist}");
    if(mounted) {
      setState(() {}); // 상태를 업데이트하여 build 재호출
    }
  }


  @override
  void dispose() {
    _playbackStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(currentSong == null || mediaListLength == -1) {
      debugPrint("현재 재생 중인 곡이 없습니다.");
      return const SizedBox();
    } else {
      //print("currentSong data : ${currentSong?.idx}, ${currentSong?.title}, ${currentSong?.artist}");
      return WidgetAnimationClickV2(
        onTap: () {
          // context.go(
          //     SongDetailScreen.routeName,
          //     arguments: {
          //       'data' : currentSong,
          //     }
          // );
        },
        padding: const EdgeInsets.only(left: 16),
        color: ColorName.backgroundHinButton,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentSong!.artist ?? 'Unknown Artist',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleFont.medium(12),
                  ),
                  const SizedBox(height: 3),
                  // WidgetTextScroll(
                  //   currentSong!.title,
                  //   delayBefore: const Duration(seconds: 2),
                  //   style: StyleFont.medium(14),
                  // ),
                ],
              ),
            ),
            WidgetAnimationClickV2(
              onTap: () async {
                await ComponentPlayer.instant.previous();
                await Future.delayed(const Duration(milliseconds: 500)); // 호출 간격을 두어 이벤트 중복 방지
              },
              child: Container(
                height: 70.0,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.transparent,
                ),
                child: Assets.icons.buttonMusic.back.svg(
                  height: 20, // 아이콘 크기는 그대로 유지R
                ),
              ),
            ),
            StreamBuilder<ProcessingState>(
              stream: ComponentPlayer.instant.audioPlayerHandler.processingStateStream, // 재생 상태를 가져오는 스트림
              builder: (context, snapshot) {
                ProcessingState? state = snapshot.data;

                // 로딩 중이거나 버퍼링 중일 때 CircularProgressIndicator 표시
                bool isLoadingOrBuffering = state == ProcessingState.loading || state == ProcessingState.buffering;

                return WidgetAnimationClickV2(
                  onTap: () async {
                    if (isLoadingOrBuffering) return; // 로딩 중이거나 버퍼링 중일 때는 아무 작업도 하지 않음

                    try {
                      debugPrint("Play/Pause 버튼 눌림");
                      if (isPlaying) {
                        debugPrint("일시정지 요청");
                        await ComponentPlayer.instant.pause();
                      } else {
                        debugPrint("재생 요청");
                        await ComponentPlayer.instant.play();
                      }
                    } finally {
                      await Future.delayed(const Duration(milliseconds: 500)); // 호출 간격을 두어 이벤트 중복 방지
                    }
                  },
                  child: Container(
                    height: 70.0,
                    width: 42,
                    padding: const EdgeInsets.all(13),
                    decoration: const BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.transparent,
                    ),
                    child: isPlaying
                        ? Assets.icons.buttonMusic.pause.svg(height: 22)
                        : Assets.icons.buttonMusic.play.svg(height: 22),
                  ),
                );
              },
            ),

            WidgetAnimationClickV2(
              onTap: () async {
                await ComponentPlayer.instant.next();
                await Future.delayed(const Duration(milliseconds: 500)); // 호출 간격을 두어 이벤트 중복 방지
              },
              child: Container(
                height: 70.0,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.transparent,
                ),
                child: Assets.icons.buttonMusic.next.svg(height: 20),
              ),
            ),
            // WidgetAnimationClick(
            //   onTap: () {
            //     indexBottomHome.value = 2;
            //     Navigator.popUntil(context,
            //         ModalRoute.withName(HomeBottomMenu.routeName));
            //   },
            //   child: Container(
            //     height: 70.0,
            //     padding: const EdgeInsets.only(top: 10, bottom: 10, right: 17, left: 10), // 클릭 영역을 넓히기 위한 패딩
            //     decoration: const BoxDecoration(
            //       shape: BoxShape.rectangle,
            //       color: Colors.transparent,
            //     ),
            //     child: Transform.translate(
            //       offset: const Offset(0, -4),
            //       child: Assets.icons.buttonMusic.list.svg(height: 26),
            //     ),
            //   ),
            // ),
          ],
        ),
      );
    }
  }

  Future<DataViewModel?> searchSong(String title, String artist) async {
    final dbHelper = DatabaseHelperAlbum.instance;

    var epResult = await dbHelper.getAlbumsFromDatabase("ep_albums");
    var singleResult = await dbHelper.getAlbumsFromDatabase("single_albums");
    var fullResult = await dbHelper.getAlbumsFromDatabase("full_albums");
    if (epResult != null) {
      var datas = epResult.list;
      for(var data in datas!) {
        if(data.artist == artist && data.title == title) {
          return data;
        }
      }
    }
    if (singleResult != null) {
      var datas = singleResult.list;
      for(var data in datas!) {
        if(data.artist == artist && data.title == title) {
          return data;
        }
      }
    }
    if (fullResult != null) {
      var datas = fullResult.list;
      for(var data in datas!) {
        if(data.artist == artist && data.title == title) {
          return data;
        }
      }
    }
    return null;
  }
}
