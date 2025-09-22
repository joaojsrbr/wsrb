import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';

class CustomCachedNetworkImage extends StatelessWidget {
  const CustomCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.base64,
    this.alignment,
    this.placeholder,
    this.imageBuilder,
    this.memCacheHeight,
    this.memCacheWidth,
    this.fit,
    this.errorWidget,
    this.httpHeaders,
    this.borderRadius,
    this.width,
    this.onTap,
    this.onLongPress,
    this.height,
    this.fadeOutDuration = const Duration(milliseconds: 1000),
    this.fadeInDuration = const Duration(milliseconds: 500),
    this.progressIndicatorBuilder,
    this.blendMode = BlendMode.srcOver,
    this.shaderCallback,
  });

  final String? imageUrl;
  final String? base64;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, Object)? errorWidget;
  final Widget Function(BuildContext, ImageProvider<Object>)? imageBuilder;
  final Widget Function(BuildContext, String, DownloadProgress)? progressIndicatorBuilder;
  final int? memCacheHeight;
  final Map<String, String>? httpHeaders;
  final int? memCacheWidth;
  final BoxFit? fit;
  final Alignment? alignment;
  final BorderRadius? borderRadius;
  final Duration fadeOutDuration;
  final Duration fadeInDuration;
  final Shader Function(Rect)? shaderCallback;
  final BlendMode blendMode;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    Widget container = const SizedBox.shrink();
    if (imageUrl != null) {
      container = CachedNetworkImage(
        cacheManager: App.APP_IMAGE_CACHE,
        imageUrl: imageUrl!,
        imageBuilder: imageBuilder,
        progressIndicatorBuilder: progressIndicatorBuilder,
        placeholder: placeholder ?? _CardPlaceholder.new,
        errorListener: customLog,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        fit: fit ?? BoxFit.cover,
        alignment: alignment ?? FractionalOffset.center,
        errorWidget: errorWidget ?? _CardPlaceholder.new,
        httpHeaders: httpHeaders,
      );
    } else if (base64 != null) {
      final decode = base64Decode(base64!);
      final image = ResizeImage(
        MemoryImage(decode),
        width: memCacheWidth,
        height: memCacheHeight,
      );
      final placeholder = ResizeImage(
        App.IMAGE_BLACK,
        width: memCacheWidth,
        height: memCacheHeight,
      );
      container = FadeInImage(
        image: image,
        placeholder: placeholder,
        fit: fit ?? BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 150),
        fadeOutDuration: const Duration(milliseconds: 150),
        placeholderFit: fit ?? BoxFit.cover,
      );
    }

    if (borderRadius != null) {
      container = ClipRRect(borderRadius: borderRadius!, child: container);
    }

    if (shaderCallback != null) {
      container = ShaderMask(
        blendMode: blendMode,
        shaderCallback: shaderCallback!,
        child: container,
      );
    }

    if (onTap != null) {
      container = Stack(
        fit: StackFit.expand,
        children: [
          container,
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              onLongPress: onLongPress,
            ),
          ),
        ],
      );
    }

    if (height != null || width != null) {
      container = SizedBox(height: height, width: width, child: container);
    }

    return container;
  }
}

class _CardPlaceholder extends StatelessWidget {
  const _CardPlaceholder(BuildContext _, this.url, [this.error]);

  final String url;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final clipRRectWidget = context.findAncestorWidgetOfExactType<ClipRRect>();
    return Card.filled(
      margin: EdgeInsets.zero,
      color: themeData.colorScheme.primary.withAlpha(10),
      shape: clipRRectWidget?.borderRadius != null
          ? RoundedRectangleBorder(borderRadius: clipRRectWidget!.borderRadius)
          : const RoundedRectangleBorder(),
    );
  }
}
