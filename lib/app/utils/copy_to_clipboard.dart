import 'package:app_wsrb_jsr/app/ui/shared/widgets/global_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> copyToClipboard(
  BuildContext context, {
  required String messageCopy,
  bool snackBar = true,
  String? messageSnackBar,
  Duration duration = const Duration(seconds: 3),
}) async {
  final ClipboardData data = ClipboardData(text: messageCopy);
  await Clipboard.setData(data).whenComplete(() {
    if (snackBar && context.mounted) {
      context.showTopNotification(
        Text(
          messageSnackBar ??
              '$messageCopy '
                  'copiado para a área de transferência!',
          textAlign: TextAlign.start,
        ),
        duration: duration,
      );
    }
  });
}
