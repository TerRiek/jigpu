import 'package:flutter/material.dart';
// import 'package:flutter_component/widgets/widget_animation_click.dart';
import 'package:jigpu_1/utils/extensions/extension_context.dart';
import 'package:jigpu_1/utils/gen/export.gen.g.dart';
import 'package:jigpu_1/utils/widgets/button/widget_animation_click_v2.dart';

class WidgetButtonBack extends StatelessWidget {
  const WidgetButtonBack({super.key, required this.enable, this.onBack, this.padding});
  final bool enable;
  final Function()? onBack;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return WidgetAnimationClickV2(
        onTap: enable == true
            ? onBack ??
                () {
              context.pop();
            }
            : null,
        child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
            child: Assets.icons.backs.backCircle.svg(
              width: 26,
            )));
  }
}
