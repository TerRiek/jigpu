import 'dart:async';
import 'dart:convert';

import 'package:blur/blur.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_component/flutter_component.dart';
import 'package:hive/hive.dart';
// import 'package:jigpu_1/pages/albums/album_screen.dart';
import 'package:jigpu_1/pages/home/bloc/home_bloc.dart';
import 'package:jigpu_1/utils/csv/search_song.dart';
// import 'package:jigpu_1/pages/music_playlist/bloc/music_playlist_bloc.dart';
// import 'package:jigpu_1/pages/music_playlist/music_playlist_screen.dart';
// import 'package:jigpu_1/utils/extensions/extension_context.dart';
// import 'package:jigpu_1/utils/widgets/export.widget.dart';
// import 'package:jigpu_1/utils/widgets/musics/widget_item_song_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../../models/data_view_model.dart';
import '../../../models/song_model.dart';
import '../../../utils/components/audio_player/component_player.dart';
import '../../../utils/widgets/musics/chart/widget_item_chart_song.dart';
// import '../../music_playlist/views/music_view_more.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeBloc homeBloc;
  // HomeStateGetAllAlbumHome? homeStateGetAllAlbumHome;
  // late MusicPlaylistBloc musicPlaylistBloc;
  List<String> playList = [];
  List<DataViewModel>? listMusic;
  Map<String, List<DataViewModel>> allPlaylists = {};

  @override
  void initState() {
    super.initState();
    homeBloc = BlocProvider.of<HomeBloc>(context);
    // musicPlaylistBloc = BlocProvider.of<MusicPlaylistBloc>(context);
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   debugPrint("현재 위치 : HomeScreen initState");
    //   homeBloc.add(HomeEventGetAllAlbumHome());
    // });
  }

  @override
  Widget build(BuildContext context) {
    return
      BlocListener(
      bloc: homeBloc,
      listenWhen: (previous, current) =>
      current is HomeStateGetAllAlbumHome || current is HomeStateInit,
      listener: (context, state) {
        // if (state is HomeStateGetAllAlbumHome) {
        //   homeStateGetAllAlbumHome = state;
        //   homeBloc.add(HomeEventInitData());
        //   setState(() {});
        // }
        // if (state is HomeStateInit) {
        //   listNews = state.listDataNews ?? [];
        //   setState(() {});
        // }
      },
      child: Scaffold(
        // backgroundColor: ColorName.background,
        body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _buildTextTitle(ComponentLanguageCode.language.myPlaylist),
                  // const SizedBox(height: 10),
                  // _buildPlayListSection(),
                  // const SizedBox(height: 10),
                  // _buildLatestMusicSection(),
                  // const SizedBox(height: 10),
                  _buildPopularMusicChartsSection(),
                  //_buildLatestNewsSection(), // <= 현재 뉴스 섹션은 현재 사용하지 않습니다.
                ],
              ),
            ),),
      ),
      );
    // )
  }

  Widget _buildTextTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Text(
        title,
        // style: StyleFont.bold(19),
      ),
    );
  }

  // Widget _buildPlayListSection() {
  //   return BlocBuilder<MusicPlaylistBloc, MusicPlaylistState>(
  //     builder: (context, state) {
  //       if (state is StateGetAllPlaylist) {
  //         playList = state.playList.keys.toList();
  //         allPlaylists = state.playList;
  //       }
  //
  //       return SingleChildScrollView(
  //         scrollDirection: Axis.horizontal,
  //         padding: const EdgeInsets.only(left: 16, right: 4),
  //         child: Row(
  //           children: [
  //             ...List.generate(
  //               playList.length,
  //                   (index) => _buildPlayListItem(playList[index]),
  //             ),
  //             _buildAddPlaylistButton(),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget _buildPlayListItem(String playlistName) {
  //   return Padding(
  //     padding: const EdgeInsets.only(right: 12),
  //     child: WidgetAnimationClick(
  //       onTap: () {
  //         context.go(MusicPlaylistScreen.routeName, arguments: {
  //           "playlistName": playlistName,
  //           "bloc": musicPlaylistBloc
  //         });
  //       },
  //       child: Container(
  //         decoration: BoxDecoration(
  //             border:
  //             Border.all(color: ColorName.backgroundHinButton, width: 1),
  //             borderRadius: BorderRadius.circular(5)),
  //         constraints: BoxConstraints(minWidth: context.width * .35),
  //         padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
  //         child: Center(
  //           child: Text(
  //             playlistName,
  //             style: StyleFont.regular(14),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildAddPlaylistButton() {
  //   return Padding(
  //     padding: const EdgeInsets.only(left: 16),
  //     child: WidgetAnimationClick(
  //       onTap: () async {
  //         final textController = TextEditingController();
  //         final value = await WidgetDialog.confirm(
  //           title: context.language.new_playlist,
  //           childText: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(context.language.title, style: StyleFont.regular(14)),
  //               const SizedBox(height: 5),
  //               Container(
  //                 decoration: const BoxDecoration(
  //                     border: Border(bottom: BorderSide(color: Colors.white))),
  //                 child: WidgetTextField(
  //                   controller: textController,
  //                   style: StyleFont.medium(14),
  //                 ),
  //               )
  //             ],
  //           ),
  //           onTap: () {
  //             final newPlaylistName = textController.text.trim();
  //             if (newPlaylistName.isEmpty) {
  //               print("제목을 작성해주세요.");
  //               return;
  //             }
  //
  //             if (playList.contains(newPlaylistName)) {
  //               print("이미 존재하는 재생목록입니다.");
  //               return;
  //             }
  //
  //             context.pop(arguments: newPlaylistName);
  //           },
  //           textAccept: context.language.save,
  //         ).show(context: context);
  //
  //         if (value != null && value.isNotEmpty && !playList.contains(value)) {
  //           try {
  //             setState(() {
  //               playList.add(value);
  //             });
  //             musicPlaylistBloc
  //                 .add(MusicPlaylistEventAdd(data: {value: const []}));
  //           } catch (e) {
  //             rethrow;
  //           }
  //         }
  //       },
  //       child: Container(
  //         decoration: BoxDecoration(
  //             border:
  //             Border.all(color: ColorName.backgroundHinButton, width: 1),
  //             borderRadius: BorderRadius.circular(5)),
  //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //         child: const Icon(Icons.add, color: Colors.white),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildLatestMusicSection() {
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         _buildSectionHeader(context.language.latestMusic),
  //         SingleChildScrollView(
  //           scrollDirection: Axis.horizontal,
  //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 // NOTE: 지금 medium 과 small 데이터가 재대로 연결 되어있음. But, 이름이 헷갈리게 되어있음
  //                 children: homeStateGetAllAlbumHome == null ||
  //                     homeStateGetAllAlbumHome!.listMedium.isEmpty
  //                     ? List.generate(
  //                   9,
  //                       (index) => Padding(
  //                     padding: const EdgeInsets.only(right: 8, bottom: 8),
  //                     child: Container(
  //                       width: context.width * .15,
  //                       height: context.width * .15,
  //                       decoration: BoxDecoration(
  //                         color: Colors.grey[300],
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                     ),
  //                   ),
  //                 )
  //                     : List.generate(
  //                   homeStateGetAllAlbumHome!.listMedium.length,
  //                       (index) => _buildMusicItem(
  //                       homeStateGetAllAlbumHome!.listMedium[index], .15),
  //                 ),
  //               ),
  //               Row(
  //                 children: homeStateGetAllAlbumHome == null ||
  //                     homeStateGetAllAlbumHome!.listSmall.isEmpty
  //                     ? List.generate(
  //                   9,
  //                       (index) => Padding(
  //                     padding: const EdgeInsets.only(right: 8, bottom: 8),
  //                     child: Container(
  //                       width: context.width * .2,
  //                       height: context.width * .2,
  //                       decoration: BoxDecoration(
  //                         color: Colors.grey[300],
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                     ),
  //                   ),
  //                 )
  //                     : List.generate(
  //                   homeStateGetAllAlbumHome!.listSmall.length,
  //                       (index) => _buildMusicItem(
  //                       homeStateGetAllAlbumHome!.listSmall[index], .2),
  //                 ),
  //               ),
  //               Row(
  //                 children: homeStateGetAllAlbumHome == null ||
  //                     homeStateGetAllAlbumHome!.listBiggest.isEmpty
  //                     ? List.generate(
  //                   9,
  //                       (index) => Padding(
  //                     padding: const EdgeInsets.only(right: 8, bottom: 8),
  //                     child: Container(
  //                       width: context.width * .25,
  //                       height: context.width * .25,
  //                       decoration: BoxDecoration(
  //                         color: Colors.grey[300],
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                     ),
  //                   ),
  //                 )
  //                     : List.generate(
  //                   homeStateGetAllAlbumHome!.listBiggest.length,
  //                       (index) => _buildMusicItem(
  //                       homeStateGetAllAlbumHome!.listBiggest[index],
  //                       .25),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildMusicItem(DataViewModel data, double sizeFactor) {
  //   return Padding(
  //     padding: const EdgeInsets.only(right: 8, bottom: 8),
  //     child: WidgetItemSongImage(
  //       data: data,
  //       size: Size(context.width * sizeFactor, context.width * sizeFactor),
  //       onTap: () {
  //         context.go(AlbumScreen.routeName, arguments: data.idx);
  //       },
  //     ),
  //   );
  // }

  // NOTE: 추후 뉴스 섹션을 사용할 경우 주석 해제
  // Widget _buildLatestNewsSection() {
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         _buildSectionHeader(context.language.latestNews, seeMoreAction: () {
  //           context.go(ListNewsScreen.routeName, arguments: listNews);
  //         }),
  //         SingleChildScrollView(
  //           scrollDirection: Axis.horizontal,
  //           padding: const EdgeInsets.symmetric(horizontal: 16),
  //           child: Row(
  //             children: List.generate(
  //               listNews.length,
  //                   (index) => _buildNewsItem(listNews[index]),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildNewsItem(NewsModel news) {
  //   return WidgetAnimationClick(
  //     onTap: () {
  //       context.go(DetailNewsScreen.routeName, arguments: news.idx);
  //     },
  //     child: Padding(
  //       padding: const EdgeInsets.only(right: 12),
  //       child: ClipRRect(
  //         borderRadius: BorderRadius.circular(5),
  //         child: SizedBox(
  //           width: context.width * .48,
  //           height: context.width * .3,
  //           child: Stack(
  //             children: [
  //               WidgetImageNetwork(
  //                 url: news.image0,
  //                 width: context.width * .48,
  //                 height: context.width * .3,
  //                 fit: BoxFit.cover,
  //               ),
  //               Align(
  //                 alignment: Alignment.bottomCenter,
  //                 child: SizedBox(
  //                   width: context.width * .48,
  //                   child: Text(
  //                     news.title ?? '',
  //                     textAlign: TextAlign.center,
  //                     style: StyleFont.medium(12),
  //                   ).frosted(
  //                     blur: 2,
  //                     frostColor: Colors.black.withOpacity(.1),
  //                     padding: const EdgeInsets.all(8),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildSectionHeader(String title, {VoidCallback? seeMoreAction}) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       _buildTextTitle(title),
  //       if (seeMoreAction != null)
  //         Transform.translate(
  //           offset: const Offset(0, 10),
  //           child: WidgetAnimationClick(
  //             onTap: seeMoreAction,
  //             child: Padding(
  //               padding:
  //               const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
  //               child: Text(
  //                 context.language.seeMore,
  //                 style: StyleFont.regular(12)
  //                     .copyWith(color: ColorName.hinText, height: 1.0),
  //               ),
  //             ),
  //           ),
  //         ),
  //     ],
  //   );
  // }

  Widget _buildPopularMusicChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // _buildTextTitle(context.language.top_10_songs),
            // GestureDetector(
            //   behavior: HitTestBehavior.translucent,
            //   onTap: () {
            //     WidgetDialog.basic(
            //       childTitle: Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Assets.icons.help.svg(),
            //           Text(
            //             "  ${context.language.top_10_songs}",
            //             style: StyleFont.bold(19).copyWith(height: 1.0),
            //           ),
            //         ],
            //       ),
            //       textButton: context.language.close,
            //       childText: RichText(
            //         text: TextSpan(children: [
            //           TextSpan(
            //               text:
            //               "ㆍ 오늘을 기준으로, 지난 30일 동안 누적된 재생 시간을 기준으로 순위가 갱신됩니다.",
            //               style: StyleFont.regular(14)
            //                   .copyWith(color: ColorName.hinText, height: 1.5)),
            //           TextSpan(
            //               text: "\nㆍ 갱신 주기: 매일 00:00",
            //               style: StyleFont.regular(14)
            //                   .copyWith(color: ColorName.hinText, height: 1.5))
            //         ]),
            //       ),
            //       onTap: () {},
            //     ).show(context: context);
            //   },
            //   child: Padding(
            //     padding: const EdgeInsets.only(left: 0),
            //     child: Assets.icons.help.svg(height: 12), // 아이콘 크기 조절 가능
            //   ),
            // ),
          ],
        ),
        _buildChartSongList(),
      ],
    );
  }


  SearchSong searchSong = SearchSong();
  //// 노래 리스트를 빌드하는 함수
  Widget _buildChartSongList() {
    // if (homeStateGetAllAlbumHome == null) {
    //   // 데이터 로딩 중인 경우의 기본 레이아웃
    //   return Padding(
    //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    //     child: Column(
    //       children: List.generate(
    //         10,
    //             (index) => Padding(
    //           padding: const EdgeInsets.only(bottom: 16),
    //           child: Container(
    //             width: double.infinity,
    //             height: 60,
    //             decoration: BoxDecoration(
    //               color: Colors.black,
    //               borderRadius: BorderRadius.circular(4),
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //   );
    // }

    // 가상의 인기 순위 데이터 생성
    List<DataViewModel> dataViewList = [
      DataViewModel(
        idx: 5275,
        title: "Hey Summer Hey Samba",
        artist: "박혜나",
        image0:
        "https://jigpu.com/attachments/20221110/2022-11-10_09:06:17_agr2Sjw8Ly.jpeg",
        song: SongModel(
          // id: "https://jigpu.com/attachments/20211213/2021-12-13_11:38:25_J2za64AHst.ogg",
          id: "https://jigpu.com/attachments/20211213/2021-12-13_11:38:25_J2za64AHst.opus",
          songCode: "KEIS-0000-0107",
          title: "Hey Summer Hey Samba",
          artist: "박혜나",
          duration: const Duration(minutes: 3, seconds: 48),
          artUri: Uri.parse(
              "https://jigpu.com/attachments/20221110/2022-11-10_09:06:17_agr2Sjw8Ly.jpeg"),
          idx: 5275,
        ),
      ),
      DataViewModel(
        idx: 13,
        title: "침침해",
        artist: "강시온",
        image0:
        "https://jigpu.com/attachments/20211203/2021-12-03_13:20:06_AcRsmUEqtN.png",
        song: SongModel(
          id: "https://jigpu.com/attachments/20211209/2021-12-09_13:27:00_aBSC9Mm7Ps.opus",
          title: "침침해",
          songCode: "KEI-0016-04",
          artist: "강시온",
          duration: const Duration(minutes: 4, seconds: 13),
          artUri: Uri.parse(
              "https://jigpu.com/attachments/20211203/2021-12-03_13:20:06_AcRsmUEqtN.png"),
          idx: 13,
        ),
      ),
      DataViewModel( //
        idx: 37,
        title: "넌 내게 말했었지",
        artist: "그루빈",
        image0:
        "https://jigpu.com/attachments/20210702/2021-7-02_09:45:56_fNDa80iHpt.jpg",
        song: SongModel(
          id: "https://jigpu.com/attachments/20211213/2021-12-13_13:33:51_awAmXs086c.opus",
          title: "넌 내게 말했었지",
          songCode: "KEIS-0000-0087",
          artist: "그루빈",
          duration: const Duration(minutes: 4, seconds: 20),
          artUri: Uri.parse(
              "https://jigpu.com/attachments/20210702/2021-7-02_09:45:56_fNDa80iHpt.jpg"),
          idx: 37,
        ),
      ),
      DataViewModel(
        idx: 71,
        title: "말해버릴까",
        artist: "마리아 제이",
        image0:
        "https://jigpu.com/attachments/20210222/2021-2-22_19:34:50_FlUXQvGHbM.png",
        song: SongModel(
          id: "https://jigpu.com/attachments/20210217/2021-2-17_18:05:55_iHh7BmDW6T.opus",
          title: "말해버릴까",
          artist: "마리아 제이",
          songCode: "KEIS-0000-0039",
          duration: const Duration(minutes: 3, seconds: 13),
          artUri: Uri.parse(
              "https://jigpu.com/attachments/20210222/2021-2-22_19:34:50_FlUXQvGHbM.png"),
          idx: 71,
        ),
      ),
      DataViewModel(
        idx: 5187,
        title: "A Love That Remain",
        artist: "강혜인",
        image0:
        "https://jigpu.com/attachments/20210222/2021-2-22_19:43:14_FI4Lv60VaH.jpg",
        song: SongModel(
          id: "https://jigpu.com/attachments/20210217/2021-2-17_18:29:35_7UPqbDLkKs.opus",
          title: "A Love That Remain",
          songCode: "KEI-0011-07",
          artist: "강혜인",
          duration: const Duration(minutes: 5, seconds: 12),
          artUri: Uri.parse(
              "https://jigpu.com/attachments/20210222/2021-2-22_19:43:14_FI4Lv60VaH.jpg"),
          idx: 5187,
        ),
      ),
      DataViewModel(
        idx: 56,
        title: "아닌 것처럼",
        artist: "강시온",
        image0:
        "https://jigpu.com/attachments/20211203/2021-12-03_13:20:06_AcRsmUEqtN.png",
        song: SongModel(
          id: "https://jigpu.com/attachments/20210322/2021-3-22_17:07:04_1odM0Xgce_.opus",
          title: "아닌 것처럼",
          artist: "강시온",
          songCode: "KEIS-0000-0062",
          duration: const Duration(minutes: 4, seconds: 34),
          artUri: Uri.parse(
              "https://jigpu.com/attachments/20211203/2021-12-03_13:20:06_AcRsmUEqtN.png"),
          idx: 56,
        ),
      ),
      DataViewModel(
        idx: 5418,
        title: "OLIVET",
        artist: "곽윤찬",
        image0:
        "https://jigpu.com/attachments/20220103/2022-1-03_09:27:15_okZK_HlJ3g.jpg",
        song: SongModel(
          id: "https://jigpu.com/attachments/20221107/2022-11-07_14:45:09_aerkHmby5L.mp3",
          title: "OLIVET",
          artist: "곽윤찬",
          songCode: "KEI-0017-02",
          duration: const Duration(minutes: 4, seconds: 17),
          artUri: Uri.parse(
              "https://jigpu.com/attachments/20220103/2022-1-03_09:27:15_okZK_HlJ3g.jpg"),
          idx: 5418,
        ),
      ),
      DataViewModel(
        idx: 4251,
        title: "Somehow",
        artist: "박혜나",
        image0:
        "https://jigpu.com/attachments/20210914/2021-9-14_10:38:08_NH1LlVfMdD.jpg",
        song: SongModel(
          id: "https://jigpu.com/attachments/20211213/2021-12-13_11:16:49_9_b1qJ3SeF.opus",
          title: "Somehow",
          artist: "박혜나",
          songCode: "KEI-0013-01",
          duration: const Duration(minutes: 4, seconds: 11),
          artUri: Uri.parse(
              "https://jigpu.com/attachments/20210914/2021-9-14_10:38:08_NH1LlVfMdD.jpg"),
          idx: 4251,
        ),
      ),
      DataViewModel(
        idx: 3258,
        title: "Light Year",
        artist: "곽윤찬",
        image0:
        "https://jigpu.com/attachments/20220103/2022-1-03_09:27:15_okZK_HlJ3g.jpg",
        song: SongModel(
          id: "https://jigpu.com/attachments/20221107/2022-11-07_14:46:54_Mm9EGTO1wL.mp3",
          title: "Light Year",
          artist: "곽윤찬",
          songCode: "KEI-0017-01",
          duration: const Duration(minutes: 4, seconds: 14),
          artUri: Uri.parse(
              "https://jigpu.com/attachments/20220103/2022-1-03_09:27:15_okZK_HlJ3g.jpg"),
          idx: 3258,
        ),
      ),
      DataViewModel(
        idx: 3239,
        title: "I'm Running",
        artist: "강시온",
        image0:
        "https://jigpu.com/attachments/20211203/2021-12-03_13:20:06_AcRsmUEqtN.png",
        song: SongModel(
          id: "https://jigpu.com/attachments/20210322/2021-3-22_17:16:43_Pw6XxYHDV0.opus",
          title: "I'm Running",
          artist: "강시온",
          songCode: "KEIS-0000-0065",
          duration: const Duration(minutes: 5, seconds: 14),
          artUri: Uri.parse(
              "https://jigpu.com/attachments/20211203/2021-12-03_13:20:06_AcRsmUEqtN.png"),
          idx: 3239,
        ),
      ),
    ];
    // List.generate(10, (index) => DataViewModel(
    //   song: null,
    //   image0: 'https://via.placeholder.com/150',
    //   artist: 'Artist $index',
    //   title: 'Title $index',
    // ));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: dataViewList.asMap().entries.map((entry) {
          int index = entry.key;
          DataViewModel data = entry.value;
          debugPrint("data : $data");
          return WidgetItemChartSong(
              data: data,
              index: index + 1,
              onTap: () async {
                if (data.song != null) {
                  /// TODO: api 사용해서 음원 파일 가지고 오는 코드
                  String? opusUrl = await searchSong.getOpusUrl(data.song!.songCode);
                  if(opusUrl != null) {
                    print("current id: ${opusUrl}");
                    /// TODO: 재생의 시작 지점
                    await ComponentPlayer.instant.addSongToEndOfPlaylist(data.song!.copyWithId(opusUrl));
                  }else{
                    await ComponentPlayer.instant.addSongToEndOfPlaylist(data.song!);
                  }
                } else {
                  print("음원 데이터를 찾을 수 없습니다.");
                }
              },
              onMore: () {
                // shareContent(data);
              });
        }).toList(),
      ),
    );
  }

  // Widget _buildChartInfo() {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 16),
  //     child: GestureDetector(
  //       behavior: HitTestBehavior.translucent,
  //       onTap: () {
  //         WidgetDialog.basic(
  //           textButton: context.language.close,
  //           childText: RichText(
  //             text: TextSpan(children: [
  //               TextSpan(
  //                   text: "ㆍ 오늘을 기준으로, 지난 30일 동안 누적된 재생 시간을 기준으로 순위가 갱신됩니다.",
  //                   style: StyleFont.regular(14)
  //                       .copyWith(color: ColorName.hinText, height: 1.5)),
  //               TextSpan(
  //                   text: "ㆍ 갱신 주기: 매일 00:00",
  //                   style: StyleFont.regular(14)
  //                       .copyWith(color: ColorName.hinText, height: 1.5))
  //             ]),
  //           ),
  //           onTap: () {},
  //         ).show(context: context);
  //       },
  //     ),
  //   );
  // }

  // Future<void> shareContent(DataViewModel data) async {
  //   await MusicViewMore.show(
  //     context,
  //     onMore: (value) {
  //       if (value == context.language.share) {
  //         final songTitle = data.title ?? "알 수 없는 노래";
  //         Share.share("$songTitle");
  //         print("$songTitle 음원이 공유되었습니다.");
  //       }
  //     },
  //   );
  // }
}
