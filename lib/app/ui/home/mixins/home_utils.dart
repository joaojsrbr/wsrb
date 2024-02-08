import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/state_extensions.dart';
import 'package:app_wsrb_jsr/app/ui/home/view/home_view.dart';
import 'package:flutter/widgets.dart';

mixin HomeUtilsMixin on State<HomeView> {
  bool _disableScroll = false;

  void disableScroll([bool? disable]) {
    setStateIfMounted(() {
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
