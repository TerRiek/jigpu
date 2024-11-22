import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jigpu_1/utils/components/component_language_code.dart';
import 'package:jigpu_1/utils/extensions/extension_context.dart';
import 'package:jigpu_1/utils/gen/export.gen.g.dart';
import 'package:jigpu_1/utils/widgets/export.widget.dart';
import 'package:jigpu_1/utils/widgets/widget_menu_music.dart';

ValueNotifier<int> indexBottomHome = ValueNotifier<int>(0);

class WidgetPageBasic extends StatefulWidget {
  const WidgetPageBasic({super.key, this.appBar, required this.child, this.onTapBackground, this.title, this.onBottomTab, this.isBottomTab = false, this.backgroundColor, this.titleColor});
  final Widget? appBar;
  final String? title;
  final Widget child;
  final Function()? onTapBackground;
  final Function(int index)? onBottomTab;
  final bool isBottomTab;
  final Color? backgroundColor;
  final Color? titleColor;

  @override
  State<WidgetPageBasic> createState() => _WidgetPageBasicState();
}

class _WidgetPageBasicState extends State<WidgetPageBasic> {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        context.unFocus();
        widget.onTapBackground?.call();
      },
      child: Scaffold(
        backgroundColor: widget.backgroundColor?? ColorName.background,
        body: SafeArea(
            child: Column(
              children: [
                if (widget.appBar != null) ...{
                  Padding(padding: const EdgeInsets.only(bottom: 16, top: 12), child: widget.appBar)
                } else ...{
                  if (widget.title != null) ...{
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16, top: 12),
                      child: Row(children: [
                        const WidgetButtonBack(enable: true),
                        Expanded(
                          child: Center(
                            child: Text(
                              widget.title!,
                              style: StyleFont.bold(20).copyWith(color: widget.titleColor),
                            ),
                          ),
                        ),
                        const Opacity(opacity: .0, child: WidgetButtonBack(enable: false)),
                      ]),
                    ),
                  } else ...{
                    const SizedBox(),
                  }
                },
                Expanded(child: widget.child),
                if (widget.isBottomTab == true)
                  WidgetMenuMusic(),
                if (widget.isBottomTab == true)
                  Container(
                    color: Colors.black,
                    child: Row(
                        children: List.generate(listBottomMenu.length, (index) {
                          // double fontSize = index == indexBottomHome.value ? 11 : 9;
                          // Color color = index == indexBottomHome.value ? Colors.white : ColorName.hinText;
                          double fontSize = 9;
                          Color color = ColorName.hinText;
                          return Expanded(
                            child: WidgetAnimationClickV2(
                              onTap: () {
                                if (widget.onBottomTab != null) {
                                  widget.onBottomTab!.call(index);
                                } else {
                                  context.pop();
                                  if (index != indexBottomHome.value) {
                                    indexBottomHome.value = index;
                                  }
                                }
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
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Text(
                                    listBottomMenu[index]['title'],
                                    style: StyleFont.regular(fontSize).copyWith(color: color),
                                  )
                                ],
                              ),
                            ),
                          );
                        })),
                  )
              ],
            )),
      ),
    );
  }
}
