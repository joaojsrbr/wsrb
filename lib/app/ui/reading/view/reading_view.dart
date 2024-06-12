// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:content_library/content_library.dart';

import 'package:app_wsrb_jsr/app/ui/reading/arguments/reading_args.dart';
import 'package:app_wsrb_jsr/app/ui/reading/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/utils/custom_states.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:positioned_scroll_observer/positioned_scroll_observer.dart';
import 'package:provider/provider.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

part '../mixins/reading_mixin.dart';

class ReadingView extends StatefulWidget {
  const ReadingView({super.key});

  @override
  State<ReadingView> createState() => _ReadingViewState();
}

class _ReadingViewState extends StateByArgument<ReadingView, ReadingViewArgs>
    with _ReadingVars, _ReadingScroll {
  late final BoxScrollObserver<RenderObject> _observer;

  @override
  void initState() {
    super.initState();
    _observer = ScrollObserver.boxMulti(axis: Axis.vertical);
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
      _releases.addAll(args.book.releases);
      _chapter = args.chapter;
      _book = args.book;
      final data = await _repository.getContent(_chapter!);
      data.fold(onError: _onError, onSucess: _onSucess);
    }
  }

  void _onError(Object error) {
    ifMounted(() {
      Navigator.pop(context);
    });
  }

  void _onSucess(List<Data> data) async {
    // await Future.delayed(const Duration(seconds: 1));
    setStateIfMounted(() => _isLoading = false);

    // final GlobalKey _key = GlobalKey();
    if (!mounted) return;
    final DateTime now = DateTime.now();

    data.forEachIndexed((index, data) async {
      Widget widget;
      switch (data) {
        case ImageData content:
          widget = CachedNetworkImage(
            fit: BoxFit.contain,
            // memCacheHeight: 1080,
            maxWidthDiskCache: 1080,
            fadeInDuration: const Duration(milliseconds: 300),
            fadeOutDuration: const Duration(milliseconds: 300),
            imageUrl: content.imageURL,
          );
        case TextData content:
          widget = Padding(
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
        case _:
          widget = const SizedBox.shrink();
      }

      setStateIfMounted(() {
        _contents.add(widget);
      });
    });

    _observer.itemCount = _contents.length;

    customLog("duration: ${DateTime.now().difference(now)}");
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

      // final items = _observer.getVisibleItems(
      //   scrollExtent: _readerController.scrollExtent,
      // );

      // int index;

      // if (items.length > 1) {
      //   index = items.last;
      // } else {
      //   index = items.single;
      // }

      // await _observer.animateToIndex(
      //   index + 1,
      //   position: _readerController.position,
      //   duration: const Duration(milliseconds: 200),
      //   curve: Curves.fastLinearToSlowEaseIn,
      // );

      // final test = _observer.getVisibleItems(
      //   scrollExtent: ScrollExtent.fromPosition(_readerController.position),
      // );

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
      observer: _observer,
      showFooterWidget: _showFooterWidget,
      onNotification: _onNotification,
      onDoubleTapDown: _handleDoubleTapDown,
      readerController: _readerController,
      contents: _contents,
      chapter: _chapter,
      book: _book,
      child: Scaffold(
        body: NotificationListener<ScrollNotification>(
          onNotification: _onNotification,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_isLoading)
                const _LoadContent()
              else ...[
                const _BuildContent(),
                const _FooterWidget(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadContent extends StatelessWidget {
  const _LoadContent();

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

class _BuildContent extends StatelessWidget {
  const _BuildContent();

  @override
  Widget build(BuildContext context) {
    final scope = ReadingScope.of(context);
    final readerController = scope.readerController;
    final onDoubleTapDown = scope.onDoubleTapDown;
    final onNotification = scope.onNotification;
    final contents = ReadingScope.contentsOf(context);

    Widget itemBuilder(BuildContext context, int index) {
      return contents[index];
      // return ObserverProxy(
      //   observer: scope.observer,
      //   child: widget,
      // );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: onNotification,
      child: Scrollbar(
        radius: const Radius.circular(8),
        trackVisibility: true,
        child: GestureDetector(
          onDoubleTapDown: (details) => onDoubleTapDown.call(context, details),
          child: SuperListView.builder(
            itemCount: contents.length,
            padding: EdgeInsets.zero,
            controller: readerController,
            primary: false,
            cacheExtent: double.infinity,
            physics: const ClampingScrollPhysics(),
            itemBuilder: itemBuilder,
          ),
          // child: SingleChildScrollView(
          //   controller: readerController,
          //   physics: const PositionRetainedScrollPhysics(
          //     parent: ClampingScrollPhysics(),
          //   ),
          //   child: Flex(
          //     direction: Axis.vertical,
          //     clipBehavior: Clip.hardEdge,
          //     children: List.generate(
          //       contents.length,
          //       (index) => itemBuilder(context, index),
          //     ),
          //   ),
          // ),

          // child: AdaptativePageView.builder(
          //   controller: readerController,
          //   physics: const ClampingScrollPhysics(),
          //   cacheExtentStyle: CacheExtentStyle.viewport,
          //   itemCount: contents.length,
          //   // physics: const FixedExtentScrollPhysics(),
          //   allowImplicitScrolling: true,
          //   scrollDirection: Axis.vertical,
          //   padEnds: false,
          //   cacheExtent: 1000,
          //   itemBuilder: itemBuilder,
          // ),
        ),
      ),
    );
  }
}

class _FooterWidget extends StatefulWidget {
  const _FooterWidget();

  @override
  State<_FooterWidget> createState() => _FooterWidgetState();
}

class _FooterWidgetState extends State<_FooterWidget> {
  double? percent;
  ReaderController? _readerController;

  @override
  void initState() {
    super.initState();
    Future.microtask(_onInit);
  }

  void _onInit() {
    _readerController = ReadingScope.of(context).readerController;
    _readerController?.addListener(_listener);
  }

  void _listener() {
    setState(() {
      percent = (_readerController!.percent * 100);
    });
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
