import 'package:another_flushbar/flushbar.dart';
import 'package:app_wsrb_jsr/app/utils/app_snack_bar.dart';
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
      context.showAppSnackBar(
        Text(
          messageSnackBar ??
              '$messageCopy '
                  'copiado para a área de transferência!',
        ),
        flushbarPosition: FlushbarPosition.TOP,
        duration: duration,
      );
    }
  });
}
