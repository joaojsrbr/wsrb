// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/content_information/widgets/content_persistent_header_delegate.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/build_contents.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/chip_content_controller.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/widgets/sinopse.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/shimmer.dart';
import 'package:app_wsrb_jsr/app/utils/app_snack_bar.dart';
import 'package:app_wsrb_jsr/app/utils/custom_states.dart';

class BookInformationView extends StatefulWidget {
  const BookInformationView({super.key});

  @override
  State<BookInformationView> createState() => _BookInformationStateView();
}

class _BookInformationStateView
    extends StateByArgument<BookInformationView, ContentInformationArgs> {
  late final Subscriptions _subscriptions;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey();

  /// [ContentRepository] instance
  late final ContentRepository _repository;

  /// variable that controls page loading
  bool _isLoading = true;

  /// variable that controls page loading
  bool _releasesIsLoading = false;

  /// list of [Releases] list
  final List<Releases> _releases = [];

  /// [Content] instance
  Content? _content;

  /// index relating to [_chapters]
  int _index = 0;

  @override
  void initState() {
    super.initState();

    _repository = context.read<ContentRepository>();
    _subscriptions = Subscriptions();
    Future.microtask(_onInit);
  }

  /// Function that controls the value of [_index]
  void _handleSetListIndex(int index) async {
    if (index == _index) return;
    // customLog(index);

    // _content?.releases.clear();

    setStateIfMounted(() => _index = index);

    final releases = _releases.elementAtOrNull(index);

    if (releases == null) {
      setStateIfMounted(() => _releasesIsLoading = true);
      await _getReleases(_content!.copyWith(releases: Releases()));
      setStateIfMounted(() => _releasesIsLoading = false);
    } else {
      setStateIfMounted(() {
        if (_releasesIsLoading) _releasesIsLoading = false;
        _content = _content!.copyWith(releases: releases);
      });
    }
    // customLog('${_releases.length} - $index');
  }

  void _onInit() async {
    final args = argument();
    final navigationState = Navigator.of(context);
    final content = args.content;

    final resultCotent = await _repository.getData(content);

    resultCotent.when(
      onError: navigationState.pop,
      onSucess: _onSucess,
    );
  }

  /// asynchronous function referring to [RefreshIndicator]
  Future<void> _onRefresh() async {
    final appSnackBar = context.appSnackBar;
    final resultBook = await _repository.getData(_content!);

    return await resultBook.when<Future>(
      onError: appSnackBar.onError,
      onSucess: (data) => _onSucess(data, true),
    );
  }

  Future<void> _getReleases(Content content, [bool onRefresh = false]) async {
    final releases = _releases.elementAtOrNull(_index);

    if (releases == null || onRefresh) {
      final result = await _repository.getReleases(
          content.copyWith(releases: Releases()), _index + 1);

      result.when(onSucess: (data) {
        final stringID = data.releases.first.stringID;
        final index = _releases.indexWhere((element) =>
            element.any((element) => element.stringID.contains(stringID)));
        if (index != -1) {
          _releases[index] = data.releases;
        } else {
          _releases.add(data.releases);
        }
        setStateIfMounted(() => _content = data);
      });
    } else {
      _releases[_index] = content.releases;
    }
  }

  Future<void> _onSucess(Content data, [bool onRefresh = false]) async {
    if (!mounted) return;
    final libraryController = context.read<LibraryController>();

    if (data.releases.isEmpty) {
      await _getReleases(data, onRefresh);
    } else {
      _releases.add(data.releases);
    }

    if (libraryController.contains(content: data)) {
      libraryController.add(
        contentEntity: data.toEntity(
          updatedAt: DateTime.now(),
          isFavorite: true,
        ),
      );
    }

    setStateIfMounted(() {
      _content = data;
      if (!onRefresh) {
        _releasesIsLoading = false;
        _isLoading = false;
      }
    });
  }

  ScrollPhysics get _physics {
    if (_isLoading) return const NeverScrollableScrollPhysics();
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  @override
  Widget buildByArgument(
    BuildContext context,
    ContentInformationArgs argument,
  ) {
    final themeData = Theme.of(context);

    final size = MediaQuery.sizeOf(context);

    final linearGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.centerRight,
      colors: <Color>[
        themeData.colorScheme.primary.withOpacity(0.12),
        themeData.colorScheme.primary.withOpacity(0.12),
        const Color(0xffE6E8EB),
        themeData.colorScheme.primary.withOpacity(0.12),
        themeData.colorScheme.primary.withOpacity(0.12),
      ],
      stops: const <double>[0.0, 0.3, 0.5, 0.65, 1.0],
    );

    return Shimmer(
      linearGradient: linearGradient,
      child: BookInformationScope(
        index: _index,
        releasesIsLoading: _releasesIsLoading,
        setListIndex: _handleSetListIndex,
        content: _content ?? argument.content,
        isLoading: _isLoading,
        child: Scaffold(
          body: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _onRefresh,
            child: CustomScrollView(
              physics: _physics,
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  floating: true,
                  delegate: ContentPersistentHeaderDelegate(
                    maxExtent: size.height * .55,
                    minExtent: 100,
                  ),
                ),
                // DecoratedSliver(
                //   decoration: BoxDecoration(
                //     color: Colors.blue,
                //     borderRadius:
                //         BorderRadius.vertical(top: Radius.circular(18)),
                //   ),
                //   sliver:
                // ),
                SinopseWidget(sinopse: _content?.sinopse ?? ''),
                const ChipContentController(),
                const BuildContents(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscriptions.dispose();
    super.dispose();
  }
}
