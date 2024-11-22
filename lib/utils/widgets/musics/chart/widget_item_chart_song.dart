import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jigpu_1/models/data_view_model.dart';
import 'package:jigpu_1/models/song_model.dart';
import 'package:jigpu_1/utils/csv/search_song.dart';
import 'package:jigpu_1/utils/gen/export.gen.g.dart';
import 'package:jigpu_1/utils/widgets/export.widget.dart';
import '../../../../pages/songs/bloc/song_bloc.dart';
import '../../../components/audio_player/component_player.dart';
// import '../../toast/app_alert.dart';
// import '../../button/more_options_button.dart';

class WidgetItemChartSong extends StatefulWidget {
  const WidgetItemChartSong({
    super.key,
    required this.data,
    this.listDataView,
    this.menu,
    this.enable = true,
    this.onShowImage,
    this.onTap,
    this.index,
    this.onMore,
  });

  final DataViewModel data;
  final Function()? onTap;
  final List<DataViewModel>? listDataView;
  final Widget? menu;
  final bool enable;
  final Function()? onShowImage;
  final int? index;
  final Function()? onMore;

  @override
  _WidgetItemChartSongState createState() => _WidgetItemChartSongState();
}

class _WidgetItemChartSongState extends State<WidgetItemChartSong> {
  // late SongBloc bloc;
  SearchSong searchSong = SearchSong();
  @override
  void initState() {
    super.initState();
    // bloc = SongBloc();
    // bloc.add(SongEventGetSongRecommend(widget.data.song!));
  }

  @override
  void dispose() {
    // bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildSong(
      context: context,
      childMenu: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  // MoreOptionsButton(
                  //   songIndex: widget.data.song!.idx,
                  //   onSubmitRating: (rating) {
                  //     bloc.add(SongEventWriteReview(
                  //       comment: '',
                  //       score: rating,
                  //       idx: widget.data.song!.idx,
                  //     ));
                  //   },
                  //   onFavoriteChanged: (isFavorite) {
                  //     if (isFavorite) {
                  //       bloc.add(SongEventFavorite(
                  //         idx: widget.data.song!.idx,
                  //         type: TypeFavorite.add,
                  //       ));
                  //     } else {
                  //       bloc.add(SongEventFavorite(
                  //         idx: widget.data.song!.idx,
                  //         type: TypeFavorite.delete,
                  //       ));
                  //     }
                  //   },
                  //   songData: widget.data.song,
                  //   onMore: () {widget.onMore!();},
                  // ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSong({
    required BuildContext context,
    required Widget childMenu,
  }) {
    return WidgetAnimationClickV2(
      onTap: widget.enable == true
          ? widget.onTap ??
              () async {
            try {
              if (widget.data.song != null) {
                await ComponentPlayer.instant.addSongToEndOfPlaylist(widget.data.song!);
              } else {
                // AppAlert.showError("음원 데이터를 찾을 수 없습니다.");
              }
            } catch (e) {
              // AppAlert.showError("음원 추가 중 오류 발생: $e");
            }
          }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: widget.onShowImage != null ? widget.onShowImage : null,
                    child: Stack(
                      children: [
                        Image.network(
                          widget.data.image0!,
                          height: 45,
                          width: 45,
                        ),
                        // WidgetImageNetwork(
                        //   width: 45,
                        //   height: 45,
                        //   radius: 10,
                        //   url: widget.data.image0,
                        // ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: CustomPaint(
                            size: Size(50, 50),
                            painter: TrianglePainter(),
                            child: Container(
                              width: 50,
                              height: 50,
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                '${widget.index ?? 0}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data.artist ?? '업데이트하지 않음',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StyleFont.regular(12).copyWith(color: ColorName.hinText),
                        ),
                        Text(
                          widget.data.title ?? '',
                          style: StyleFont.medium(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            childMenu,
          ],
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.6, 0);
    path.lineTo(0, size.height * 0.6);
    path.close();

    var clipPath = Path.combine(
      PathOperation.intersect,
      path,
      Path()
        ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(10))),
    );

    canvas.drawPath(clipPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class PopularMusicChartsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<DataViewModel> dataViewModels = List.generate(
        10,
            (index) => DataViewModel(
            image0: 'https://via.placeholder.com/150',
            artist: 'Artist $index',
            title: 'Title $index',
            song: SongModel(
              id: 'song_id_$index',
              title: 'Title $index',
              artist: 'Artist $index',
              duration: const Duration(minutes: 3, seconds: 30),
              artUri: Uri.parse('https://via.placeholder.com/150'),
              idx: index,
            )));

    return Scaffold(
      appBar: AppBar(
        title: Text('Popular Music Charts'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: List.generate(
            10,
                (index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: WidgetItemChartSong(
                data: dataViewModels[index],
                index: index + 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
