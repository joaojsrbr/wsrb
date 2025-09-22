import 'package:android_pip/actions/pip_action.dart';
import 'package:android_pip/android_pip.dart';
import '../view/player_view.dart';
import '../../shared/mixins/subscriptions.dart';

mixin PlayerPipMixin on SubscriptionsByStateArgumentMixin<PlayerView> {
  // late final AndroidPIP androidPIP;

  bool isPipAvailable = false;
  bool isPipActivated = false;
  bool isAutoPipAvailable = false;

  // late final DraggableScrollableController draggableScrollableController;

  Future<void> pipStart() async {
    isPipAvailable = await AndroidPIP.isPipAvailable;
    isAutoPipAvailable = await AndroidPIP.isAutoPipAvailable;
    // isPipActivated = await AndroidPIP.isPipActivated;
    // if (isPipAvailable) {

    // }
  }

  // @override
  // void initState() {
  // draggableScrollableController = DraggableScrollableController();
  //   super.initState();
  // }

  // @override
  // void initState() {
  //   simplePip = SimplePip.instance;
  //   super.initState();
  // }

  void onPipAction(PipAction pipAction);

  void onPipChange();

  // @override
  // void dispose() {
  //   draggableScrollableController.dispose();
  //   super.dispose();
  // }
}
