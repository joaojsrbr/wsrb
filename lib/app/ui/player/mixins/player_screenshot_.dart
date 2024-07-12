import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_controller.dart';
import 'package:app_wsrb_jsr/app/ui/player/view/player_view.dart';
import 'package:app_wsrb_jsr/app/ui/shared/mixins/subscriptions.dart';
import 'dart:convert';

mixin PlayerScreenShotMixin
    on
        SubscriptionsByStateArgumentMixin<PlayerView, PlayerArgs>,
        PlayerControllerMixin {
  Future<String?> videoScreenshotBase64() async {
    final capture = await player!.screenshot();
    // final capture = await screenshotController.capture(
    //   pixelRatio: 0.5,
    // );
    if (capture != null) {
      return base64.encode(capture);
    }
    return null;
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
