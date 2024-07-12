import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/player/view/player_view.dart';
import 'package:app_wsrb_jsr/app/ui/shared/mixins/subscriptions.dart';
import 'package:simple_pip_mode/actions/pip_action.dart';
import 'package:simple_pip_mode/simple_pip.dart';

mixin PlayerSimplePipMixin
    on SubscriptionsByStateArgumentMixin<PlayerView, PlayerArgs> {
  late final SimplePip simplePip;

  bool isPipAvailable = false;
  bool isPipActivated = false;
  PipState pipState = PipState.none;
  bool isAutoPipAvailable = false;

  Future<void> pipStart() async {
    isPipAvailable = await SimplePip.isPipAvailable;
    isAutoPipAvailable = await SimplePip.isAutoPipAvailable;
    isPipActivated = await SimplePip.isPipActivated;
    if (isPipAvailable) {
      subscriptions.addAll(
        [
          simplePip.onPipAction.listen(onPipAction),
          simplePip.onPipChange.listen(onPipState),
        ],
      );
    }
  }

  @override
  void initState() {
    simplePip = SimplePip.instance;
    super.initState();
  }

  void onPipAction(PipAction pipAction);

  void onPipState(PipState pipState);
}
