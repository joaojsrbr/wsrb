// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/content_information/widgets/content_persistent_header_delegate.dart';
import 'package:app_wsrb_jsr/app/ui/shared/mixins/subscriptions.dart';
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
    extends StateByArgument<BookInformationView, ContentInformationArgs>
    with SubscriptionsMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey();

  late final ContentRepository _repository;
  late final DownloadService _downloadService;
  bool _isLoading = true;
  bool _releasesIsLoading = false;
  final Map<int, Releases> _releases = {};
  Content? _content;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _downloadService = context.read<DownloadService>();
    _repository = context.read<ContentRepository>();
    Future.microtask(_onInit);
  }

  void _handleSetListIndex(int index) async {
    if (index == _index) return;

    setStateIfMounted(() => _index = index);

    final releases = _releases[index];

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
  }

  Future<void> _downloadRelease(Release release) async {
    final LibraryController libraryController =
        context.read<LibraryController>();
    final HistoricController historicController =
        context.read<HistoricController>();

    switch (release) {
      case Episode data when mounted && _content is Anime:
        await _downloadService.downloadReleaseVideoByHLS(
          data,
          _content!,
          _repository,
          statisticsCallback: (statistics) async {},
          onResult: (result) async {
            customLog(result.runtimeType);

            if (result is Success) {
              final animeEntity =
                  _content!.toEntity(isFavorite: false) as AnimeEntity;

              animeEntity.episodes.add(data.toEntity(anime: _content as Anime));

              await libraryController.add(
                contentEntity: _content!.toEntity(isFavorite: false),
              );
              await historicController.add(
                historyEntity: data.toEntity(anime: _content as Anime),
              );
            }

            if ([Cancel, Failure, Success].contains(result.runtimeType)) {
              if (result is Success) {
                customLog('Terminou');
              }
            }
          },
        );

        break;
    }
  }

  void _onInit() async {
    final args = argument();
    final navigationState = Navigator.of(context);
    final content = args.content;

    final resultCotent = await _repository.getData(content);

    resultCotent.fold(
      onError: navigationState.pop,
      onSuccess: _onSucess,
    );
  }

  Future<void> _onRefresh() async {
    final appSnackBar = context.appSnackBar;
    final resultBook = await _repository.getData(_content!);

    return await resultBook.fold<Future>(
      onError: appSnackBar.onError,
      onSuccess: (data) => _onSucess(data, true),
    );
  }

  Future<void> _getReleases(Content content, [bool onRefresh = false]) async {
    final releases = _releases[_index];

    if (releases == null || onRefresh) {
      final result = await _repository.getReleases(content, _index + 1);

      result.fold(
        onSuccess: (data) {
          final stringID = data.releases.first.stringID;
          customLog(stringID);
          _releases[_index] = data.releases;
          // final index = _releases.indexWhere((element) =>
          //     element.any((element) => element.stringID.contains(stringID)));
          // if (index != -1) {
          //   _releases[index] = data.releases;
          // } else {
          //   _releases.add(data.releases);
          // }
          // setState(() {});
          setStateIfMounted(() => _content = data);
        },
      );
    } else {
      _releases[_index] = content.releases;
    }
  }

  Future<void> _onSucess(Content data, [bool onRefresh = false]) async {
    if (!mounted) return;
    final libraryController = context.read<LibraryController>();

    final LibraryService libraryService =
        LibraryService(libraryController, context.read());

    if (data.releases.isEmpty) {
      await _getReleases(data, onRefresh);
    } else {
      _releases[_index] = data.releases;
    }

    if (libraryService.contains(content: data)) {
      libraryController.add(
        contentEntity: data.toEntity(
          updatedAt: DateTime.now(),
          isFavorite: true,
        ),
      );
    }

    setStateIfMounted(() {
      if (data is Anime && _content != null) {
        _content = (_content as Anime).merge(data);
      } else {
        _content = data;
      }

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

  static const _linearGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      Color.fromARGB(90, 176, 190, 197),
      Color.fromARGB(90, 176, 190, 197),
      Color(0xffE6E8EB),
      Color.fromARGB(90, 176, 190, 197),
      Color.fromARGB(90, 176, 190, 197),
    ],
    stops: <double>[0.0, 0.35, 0.5, 0.65, 1.0],
  );

  @override
  Widget buildByArgument(
    BuildContext context,
    ContentInformationArgs argument,
  ) {
    final size = MediaQuery.sizeOf(context);

    return Shimmer(
      linearGradient: _linearGradient,
      child: BookInformationScope(
        downloadRelease: _downloadRelease,
        index: _index,
        releasesIsLoading: _releasesIsLoading,
        setListIndex: _handleSetListIndex,
        content: _content ?? argument.content,
        isLoading: _isLoading,
        builder: (context) => Scaffold(
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
                    content: _content ?? argument.content,
                    isLoading: _isLoading,
                    maxExtent: size.height * .42,
                    minExtent: 100,
                  ),
                ),
                const SinopseWidget(),
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
    _downloadService.clearDownloadList();
    super.dispose();
  }
}
