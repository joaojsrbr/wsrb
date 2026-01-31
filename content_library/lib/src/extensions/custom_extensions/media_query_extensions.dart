import 'package:flutter/material.dart';

extension MediaQueryExtensions on BuildContext {
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  double get topPadding => padding.top;
  double get bottomPadding => padding.bottom;
  Size get sizeOf => MediaQuery.sizeOf(this);
  double get width => sizeOf.width;
  double get height => sizeOf.height;
  TextScaler get textScaler => MediaQuery.textScalerOf(this);
  Orientation get orientation => MediaQuery.orientationOf(this);
}
