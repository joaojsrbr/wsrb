import 'package:app_wsrb_jsr/app/ui/home/page/home_page.dart';
import 'package:flutter/widgets.dart';

mixin HomeUtils on State<HomePage> {
  bool _disableScroll = false;

  void disableScroll([bool? disable]) {
    if (!mounted) return;
    setState(() {
      _disableScroll = disable ?? !_disableScroll;
    });
  }

  ScrollPhysics get mainPhysics {
    if (_disableScroll) return const NeverScrollableScrollPhysics();
    return const AlwaysScrollableScrollPhysics();
  }

  ScrollPhysics get tabPhysics {
    if (_disableScroll) return const NeverScrollableScrollPhysics();
    return const PageScrollPhysics();
  }
}
