import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_controller.dart';
import 'package:app_wsrb_jsr/app/ui/player/view/player_view.dart';
import 'package:app_wsrb_jsr/app/ui/shared/mixins/subscriptions.dart';

mixin PlayerScreenShotMixin
    on
        SubscriptionsByStateArgumentMixin<PlayerView, PlayerArgs>,
        PlayerControllerMixin {
  Future<List<int>?> videoScreenshotBase64() async {
    final capture = await player?.screenshot();
    // final capture = await screenshotController.capture(
    //   pixelRatio: 0.5,
    // );

    return capture;
  }

  // Future<List<int>> _pngToJpg(Uint8List pngBytes) async {
  //   final pngImage = img.decodePng(pngBytes);
  //   final pngImageResized = img.copyResize(
  //     pngImage!,
  //     width: 1000,
  //     height: 1000,
  //   );
  //   return img.encodeJpg(pngImageResized, quality: 90);
  // }
}
