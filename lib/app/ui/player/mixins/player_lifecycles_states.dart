import '../view/player_view.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';

mixin PlayerLifecyclesStates on State<PlayerView>, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    customLog('[$runtimeType][didChangeAppLifecycleState()][$state]');

    switch (state) {
      case AppLifecycleState.hidden:
        didHidden();
      case AppLifecycleState.paused:
        didPaused();
      case AppLifecycleState.inactive:
        didInactive();
      case AppLifecycleState.resumed:
        didResumed();
      case AppLifecycleState.detached:
        didDetached();
    }

    super.didChangeAppLifecycleState(state);
  }

  void didHidden() {}
  void didPaused() {}
  void didInactive() {}
  void didResumed() {}
  void didDetached() {}

  @override
  void setState(VoidCallback fn) {
    ifMounted(() => super.setState(fn));
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
