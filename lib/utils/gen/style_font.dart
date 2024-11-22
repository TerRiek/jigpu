import 'package:flutter/material.dart';
import 'package:jigpu_1/utils/gen/colors.gen.dart';
import 'package:jigpu_1/utils/gen/fonts.gen.dart';

class StyleFont {
  static const double _fontSizeScale = 0;
  static const double _fontSizeDefault = 16;

  static TextStyle bold([double fontSize = _fontSizeDefault]) {
    fontSize += _fontSizeScale;
    return TextStyle(fontFamily: FontFamily.bold, fontWeight: FontWeight.bold, fontSize: fontSize, color: ColorName.text);
  }

  static TextStyle medium([double fontSize = _fontSizeDefault]) {
    fontSize += _fontSizeScale;
    return TextStyle(fontFamily: FontFamily.regular, fontWeight: FontWeight.w500, fontSize: fontSize, color: ColorName.text);
  }

  static TextStyle regular([double fontSize = _fontSizeDefault]) {
    fontSize += _fontSizeScale;
    return TextStyle(fontFamily: FontFamily.regular, fontSize: fontSize, fontWeight: FontWeight.w400, color: ColorName.text);
  }
}
