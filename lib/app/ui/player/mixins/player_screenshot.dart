import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_controller.dart';
import 'package:app_wsrb_jsr/app/ui/player/view/player_view.dart';
import 'package:app_wsrb_jsr/app/ui/shared/mixins/subscriptions.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

mixin PlayerScreenshotMixin
    on
        SubscriptionsByStateArgumentMixin<PlayerView, PlayerArgs>,
        PlayerControllerMixin {
  /// Captura a imagem do vídeo, redimensiona, comprime e retorna base64 compactado
  Future<String?> videoScreenshotBase64() async {
    final capture = await player?.screenshot(); // captura em Uint8List

    if (capture != null) {
      // decode with 'image' package
      final original = img.decodeImage(capture);
      if (original == null) return null;

      // resize image to 100x100 (ou outro tamanho desejado)
      final resized = img.copyResize(original, width: 500, height: 340);

      // compress to JPEG with quality (0-100)
      final compressed = img.encodeJpg(
        resized,
        quality: 35,
      ); // qualidade ajustável

      // convert to base64
      return base64Encode(compressed);
    }

    return null;
  }

  /// Alternativa para qualquer ImageProvider (útil se quiser reaproveitar com assets, etc.)
  Future<String> imageProviderToBase64(ImageProvider imageProvider) async {
    final Completer<ui.Image> completer = Completer<ui.Image>();

    final ImageStream stream = imageProvider.resolve(
      const ImageConfiguration(),
    );
    final listener = ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
    });

    stream.addListener(listener);
    final ui.Image image = await completer.future;
    stream.removeListener(listener);

    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    if (byteData == null) {
      throw Exception("Erro ao converter imagem para bytes.");
    }

    final Uint8List rawBytes = byteData.buffer.asUint8List();
    final img.Image converted = img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: rawBytes.buffer,
      order: img.ChannelOrder.rgba,
    );

    final resized = img.copyResize(converted, width: 100, height: 100);
    final compressed = img.encodeJpg(resized, quality: 35);

    return base64Encode(compressed);
  }
}
