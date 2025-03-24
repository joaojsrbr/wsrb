import 'package:another_flushbar/flushbar.dart';
import 'package:app_wsrb_jsr/app/utils/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> copyToClipboard(
  BuildContext context, {
  required String messageCopy,
  bool snackBar = true,
  String? messageSnackBar,
  Duration duration = const Duration(seconds: 2),
}) async {
  final ClipboardData data = ClipboardData(text: messageCopy);
  await Clipboard.setData(data).whenComplete(() {
    if (snackBar && context.mounted) {
      _snackBar(context, messageCopy, messageSnackBar, duration);
    }
  });
}

void _snackBar(
  context,
  String messageCopy,
  String? messageSnackBar,
  Duration duration,
) {
  final AppSnackBar snackBar = AppSnackBar(context);
  snackBar.show(
    Text(
      messageSnackBar ??
          '$messageCopy '
              'copiado para a área de transferência!',
    ),
    flushbarPosition: FlushbarPosition.TOP,
    duration: duration,
  );
  // ScaffoldMessenger.of(context)
  //   ..clearSnackBars()
  //   ..showSnackBar(
  //     SnackBar(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //       duration: const Duration(milliseconds: 1500),
  //       behavior: SnackBarBehavior.floating,
  //       content: Text(
  //         messageSnackBar ??
  //             '$messageCopy '
  //                 'copiado para a área de transferência!',
  //       ),
  //     ),
  //   );
}
