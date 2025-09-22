import 'package:flutter/material.dart';

extension MediaQueryExtensions on BuildContext {
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  double get topPadding => padding.top;
  double get bottomPadding => padding.bottom;
  Size get size => MediaQuery.sizeOf(this);
  double get width => size.width;
  double get height => size.height;
  TextScaler get textScaler => MediaQuery.textScalerOf(this);
  Orientation get orientation => MediaQuery.orientationOf(this);
}
