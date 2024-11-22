import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jigpu_1/pages/home/screens/home_screen.dart';
// import 'package:jigpu_1/pages/home/screens/library_v2_screen.dart';
// import 'package:jigpu_1/pages/music_playlist/bloc/music_playlist_bloc.dart';
// import 'package:jigpu_1/pages/searchs/search_screen.dart';
// import 'package:jigpu_1/pages/users/my/my_user_screen.dart';
import 'package:jigpu_1/utils/components/component_language_code.dart';
import 'package:jigpu_1/utils/components/audio_player/component_player.dart';
import 'package:jigpu_1/utils/gen/export.gen.g.dart';
import 'package:jigpu_1/utils/widgets/button/widget_animation_click_v2.dart';
import 'package:jigpu_1/utils/widgets/widget_menu_music.dart';
import 'package:jigpu_1/utils/widgets/widget_page_basic.dart';

import 'bloc/home_bloc.dart';

// ignore: must_be_immutable
class HomeBottomMenu extends StatefulWidget {
  const HomeBottomMenu({super.key});
  static String routeName = "/HomeScreen";

  @override
  State<HomeBottomMenu> createState() => _HomeBottomMenuState();
}

class _HomeBottomMenuState extends State<HomeBottomMenu> {
  List<Map<String, dynamic>> listBottomMenu = [
    // {'title': ComponentLanguageCode.language.home, 'icon': Assets.icons.bottomMenu.icon1.path},
    // {'title': ComponentLanguageCode.language.search, 'icon': Assets.icons.bottomMenu.icon2.path},
    // {'title': ComponentLanguageCode.language.locker, 'icon': Assets.icons.bottomMenu.icon3.path},
    // {'title': ComponentLanguageCode.language.myPage, 'icon': Assets.icons.bottomMenu.icon4.path},
    {'title': '홈', 'icon': Assets.icons.bottomMenu.icon1.path},
    // {'title': ComponentLanguageCode.language.search, 'icon': Assets.icons.bottomMenu.icon2.path},
    // {'title': ComponentLanguageCode.language.locker, 'icon': Assets.icons.bottomMenu.icon3.path},
    // {'title': ComponentLanguageCode.language.myPage, 'icon': Assets.icons.bottomMenu.icon4.path},
  ];

  List<Widget> listChildren = [];

  // MusicPlaylistBloc musicPlaylistBloc = MusicPlaylistBloc();

  HomeBloc homeBloc = HomeBloc();

  final int libraryScreenIndex = 2;

  // LibraryV2Screen libraryV2Screen = const LibraryV2Screen();

  @override
  void initState() {
    listChildren = [
      const HomeScreen(),
      // const SearchScreen(),
      // libraryV2Screen,
      // const MyUserScreen(),
    ];
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   musicPlaylistBloc.add(EventGetAllPlaylist());
    // });
  }

  @override
  void dispose() {
    super.dispose();
    ComponentPlayer.instant.stop();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => homeBloc),
        // BlocProvider(create: (context) => musicPlaylistBloc),
      ],
      child: BlocListener<HomeBloc, HomeState>(
        listenWhen: (previous, current) => current is HomeStateChangeIndexState,
        listener: (context, state) {
          if (state is HomeStateChangeIndexState) {
            indexBottomHome.value = state.indexCurrent;
          }
        },
        child: ValueListenableBuilder<int>(
          valueListenable: indexBottomHome,
          builder: (context, value, child) => Scaffold(
            backgroundColor: ColorName.background,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: IndexedStack(
                      index: indexBottomHome.value,
                      children: listChildren,
                    ),
                  ),
                  WidgetMenuMusic(),
                  Container(
                    color: Colors.black,
                    child: Row(
                      children: List.generate(listBottomMenu.length, (index) {
                        double fontSize = 9;
                        Color color = ColorName.hinText;
                        return Expanded(
                          child: WidgetAnimationClickV2(
                            onTap: () {
                              indexBottomHome.value = index;
                            },
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              children: [
                                SvgPicture.asset(
                                  listBottomMenu[index]['icon'],
                                  width: 20,
                                  height: 26,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  listBottomMenu[index]['title'],
                                  style: StyleFont.regular(fontSize).copyWith(color: color),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
