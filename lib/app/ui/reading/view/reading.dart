// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/state_extensions.dart';
import 'package:app_wsrb_jsr/app/utils/custom_log.dart';
import 'package:app_wsrb_jsr/app/models/book.dart';
import 'package:app_wsrb_jsr/app/models/content.dart';
import 'package:app_wsrb_jsr/app/repositories/book_repository.dart';
import 'package:app_wsrb_jsr/app/ui/reading/arguments/reading_args.dart';
import 'package:app_wsrb_jsr/app/ui/reading/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/utils/custom_states.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:app_wsrb_jsr/app/models/chapter.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

part '../mixins/reading_mixin.dart';

class ReadingView extends StatefulWidget {
  const ReadingView({super.key});

  static ReadingViewArgs args({
    required List<Chapter> chapters,
    required int currentIndex,
    required Book book,
    required Chapter chapter,
    required ThemeData bookThemeData,
  }) {
    return ReadingViewArgs(
      bookThemeData: bookThemeData,
      chapters: chapters,
      book: book,
      chapter: chapter,
      currentIndex: currentIndex,
    );
  }

  @override
  State<ReadingView> createState() => _ReadingViewState();
}

class _ReadingViewState extends StateByArgument<ReadingView, ReadingViewArgs>
    with _ReadingVars, _ReadingScroll {
  @override
  void initState() {
    super.initState();
    addPostFrameCallback((time) => _onInit());
  }

  void _onInit() async {
    // _snackBarLoading();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    // _enabledSystemUIMode = true;
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is! ReadingViewArgs) {
      Navigator.pop(context);
    } else {
      _chapters = args.book.chapters;
      _chapter = args.chapter;
      _book = args.book;
      final data = await _repository.getContent(_chapter!);
      data.when(onError: _onError, onSucess: _onSucess);
    }
  }

  void _onError(Object error) {
    ifMounted(() {
      Navigator.pop(context);
    });
  }

  void _onSucess(List<ChapterContent> data) async {
    await Future.delayed(const Duration(seconds: 2));
    setStateIfMounted(() {
      _data = data;
      _isLoading = false;
    });
  }

  double get _percent => _readerController.percent;

  void _handleDoubleTapDown(
    BuildContext context,
    TapDownDetails details,
  ) async {
    final height = MediaQuery.sizeOf(context).height;
    final position = details.globalPosition;
    // double maxScrollExtent = 0.0;
    final metrics = _readerController.position;
    if (position.dy < height ~/ 3) {
      if (_percent == 0) return;
      customLog('DoubleTapDown[up][$position]');
      // maxScrollExtent = metrics.maxScrollExtent;

      // if (_lastMaxScrollExtent != null) maxScrollExtent = maxScrollExtent - _lastMaxScrollExtent!;
      await _readerController.animateTo(
        metrics.maxScrollExtent * (_percent - 0.05),
        duration: const Duration(seconds: 2),
        curve: Curves.fastOutSlowIn,
      );

      // await bookReaderScope.itemScrollController.scrollTo(
      //   index: currentIndex - 1,
      //   duration: const Duration(seconds: 1),
      //   curve: Curves.fastOutSlowIn,
      //   alignment: 0.8,
      // );
    } else if (position.dy > height ~/ 3 * 2) {
      if (_percent == 1) return;
      customLog('DoubleTapDown[down][$position]');

      await _readerController.animateTo(
        metrics.maxScrollExtent * (_percent + 0.05),
        duration: const Duration(seconds: 2),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      customLog('DoubleTapDown[center][$position]');
      // setState(() => _overlay = !_overlay);
      // _handleOverlayInserted();
      // Future.delayed(const Duration(milliseconds: 300), () => _handleOverlayInserted.call(_visible));
      // Future.delayed(const Duration(milliseconds: 300), () => _handleOverlayInserted.call(_visible));
    }
  }

  @override
  Widget buildByArgument(
    BuildContext context,
    ReadingViewArgs argument,
  ) {
    return ReadingScope(
      showFooterWidget: _showFooterWidget,
      onNotification: _onNotification,
      onDoubleTapDown: _handleDoubleTapDown,
      controller: _readerController,
      data: _data,
      chapter: _chapter,
      book: _book,
      child: Theme(
        data: argument.bookThemeData,
        child: Scaffold(
          body: NotificationListener<ScrollNotification>(
            onNotification: _onNotification,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_isLoading)
                  const LoadContent()
                else ...[
                  const BuildContent(),
                  const FooterWidget(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}

class LoadContent extends StatelessWidget {
  const LoadContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator.adaptive(),
        const SizedBox(height: 12),
        Text(
          'Carregando...',
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
}

class BuildContent extends StatelessWidget {
  const BuildContent({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = ReadingScope.of(context);
    final readerController = scope.controller;
    final onDoubleTapDown = scope.onDoubleTapDown;
    final onNotification = scope.onNotification;
    final data = ReadingScope.dataOf(context);

    itemBuilder(BuildContext context, int index) {
      final content = data[index];

      switch (content) {
        case ImageChapterContent content:
          return ImageCacheWidget(imageURL: content.imageURL);
        // return CachedNetworkImage(
        //   fit: BoxFit.contain,
        //   imageUrl: content.imageURL,
        // );
        case TextChapterContent content:
          return Padding(
            padding: EdgeInsets.only(
              right: 8,
              left: 8,
              bottom: 8,
              top: index == 0 ? 60 : 8,
            ),
            child: Text(
              content.text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
      }
    }

    return NotificationListener<ScrollNotification>(
      onNotification: onNotification,
      child: Scrollbar(
        radius: const Radius.circular(8),
        trackVisibility: true,
        child: GestureDetector(
          onDoubleTapDown: (details) => onDoubleTapDown.call(context, details),
          child: SingleChildScrollView(
            controller: readerController,
            physics: const ClampingScrollPhysics(),
            child: Flex(
              direction: Axis.vertical,
              children: List.generate(
                data.length,
                (index) => itemBuilder(context, index),
              ),
            ),
          ),
          // child: AdaptativePageView.builder(
          //   controller: readerController,
          //   itemCount: data.length,
          //   physics: const FixedExtentScrollPhysics(),
          //   allowImplicitScrolling: true,
          //   scrollDirection: Axis.vertical,
          //   padEnds: false,
          //   cacheExtent: 35,
          //   itemBuilder: itemBuilder,
          // ),
        ),
      ),
    );
  }
}

class ImageCacheWidget extends StatelessWidget {
  const ImageCacheWidget({
    super.key,
    required this.imageURL,
  });

  final String imageURL;

  // @override
  // void didChangeDependencies() {
  //   precacheImage(NetworkImage(widget.imageURL), context);
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      fit: BoxFit.contain,
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
      imageUrl: imageURL,
    );
    // return Image.network(
    //   widget.imageURL,
    //   loadingBuilder: (context, child, loadingProgress) {
    //     if (loadingProgress == null) return child;
    //     return SizedBox(
    //       height: MediaQuery.sizeOf(context).height * .2,
    //     );
    //   },
    //   fit: BoxFit.contain,
    // );
  }
}

class FooterWidget extends StatefulWidget {
  const FooterWidget({super.key});

  @override
  State<FooterWidget> createState() => _FooterWidgetState();
}

class _FooterWidgetState extends State<FooterWidget> {
  double? percent;
  ReaderController? _readerController;

  @override
  void initState() {
    super.initState();
    addPostFrameCallback((data) => _onInit());
  }

  void _onInit() {
    _readerController = ReadingScope.of(context).controller;
    _readerController?.addListener(_listener);
  }

  void _listener() {
    percent = (_readerController!.percent * 100);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final showFooterWidget = ReadingScope.showFooterWidgetOf(context);

    const shrinkWidget = SizedBox.shrink();

    if (percent == null || _readerController == null || !showFooterWidget) {
      return shrinkWidget;
    }

    final textTheme = Theme.of(context).textTheme;
    final caption = textTheme.labelLarge?.copyWith(
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[350]
          : Colors.grey[200],
    );

    final locale = Localizations.localeOf(context);
    final date = DateFormat(DateFormat.HOUR24_MINUTE,
            '${locale.languageCode}_${locale.countryCode}')
        .format(DateTime.now());

    return DefaultTextStyle.merge(
      style: caption,
      maxLines: 1,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Builder(
          builder: (context) {
            String title;

            final metrics = _readerController!.position;

            title = percent!.toStringAsPrecision(3);

            if (!(metrics.hasContentDimensions && percent != -1)) {
              return shrinkWidget;
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(MdiIcons.clock, size: 16),
                    const SizedBox(width: 4),
                    Text(date),
                  ],
                ),
                const SizedBox(width: 20),
                Row(
                  children: [
                    Icon(MdiIcons.percent, size: 16),
                    const SizedBox(width: 4),
                    Text('$title%'),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _readerController?.removeListener(_listener);
    super.dispose();
  }
}
