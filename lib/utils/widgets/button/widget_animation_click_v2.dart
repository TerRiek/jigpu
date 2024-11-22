import 'dart:async';

import 'package:flutter/material.dart';

class WidgetAnimationClickV2 extends StatefulWidget {
  const WidgetAnimationClickV2({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.borderRadius,
    this.radius,
    this.border,
    this.onTapLong,
    this.boxShadow,
  });
  final Widget child;
  final Function()? onTap;
  final Function()? onTapLong;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final BorderRadius? borderRadius;
  final double? radius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  @override
  State<WidgetAnimationClickV2> createState() => _WidgetAnimationClickV2State();
}

class _WidgetAnimationClickV2State extends State<WidgetAnimationClickV2> with SingleTickerProviderStateMixin {
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.grey.withOpacity(.3),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(0),
          onLongPress: () {
            widget.onTapLong?.call();
          },
          onTap: () {
            timer?.cancel();
            timer = Timer(const Duration(milliseconds: 300), () {
              widget.onTap?.call();
            });
          },
          child: Ink(
              padding: widget.padding,
              decoration: widget.border != null || widget.color != null || widget.boxShadow != null
                  ? BoxDecoration(borderRadius: widget.borderRadius, color: widget.color, border: widget.border, boxShadow: widget.boxShadow)
                  : null,
              child: widget.child),
        ),
      ),
    );
  }
}
