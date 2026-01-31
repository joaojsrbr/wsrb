import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes/routes.dart';
import '../ui/player/arguments/player_args.dart';
import '../ui/reading/arguments/reading_args.dart';
import '../ui/shared/widgets/release_content.dart';
import 'dual.dart';

final class ReleaseUtils {
  const ReleaseUtils._();

  static Future<void> onDoubleTap(BuildContext context, Release release) async {
    // if (!(release is Episode && release.sinopse?.isNotEmpty == true)) {
    //   return;
    // }

    if (release case Episode data when data.sinopse?.isNotEmpty ?? false) {
      await showModalBottomSheet(
        isScrollControlled: false,
        isDismissible: true,
        showDragHandle: true,
        useRootNavigator: true,
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Sinopse',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  data.sinopse!.trim(),
                  textAlign: TextAlign.justify,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 30),
            ],
          );
        },
      );
    }
  }

  static Future<void> openWithIntent(String url) async {
    final intent = AndroidIntent(
      action: 'action_view',
      data: url,
      type: 'application/x-mpegURL',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  }

  static Future<void> onTap(
    BuildContext context,
    Release release,
    Content content, [
    int index = 0,
  ]) async {
    final releaseFile = AppStorage.getReleaseFile(content, release);

    customLog('tapped name: ${release.title} - id: ${release.stringID}');

    switch ((content, release)) {
      case (Book content, Chapter data):
        await context.pushEnum(
          RouteName.READ,
          extra: ReadingViewArgs(
            capturedThemes: InheritedTheme.capture(
              from: context,
              to: Navigator.of(context).context,
            ),
            chapter: data,
            currentIndex: index,
            book: content,
          ),
        );
        break;
      case (Anime content, Episode data):
        final record = await _fileOrURL(release, content, releaseFile, context);
        if (record case (Data selectData, List<Data> qualities) when context.mounted) {
          final historicController = context.read<HistoricController>();
          final startPossition = historicController.repo
              .getHistoric<EpisodeEntity>(release: release, content: content)
              ?.position
              ?.currentDuration
              .microsecondsToDuration;

          // if (selectData is VideoData) {
          //   final server = await startProxy(
          //     targetBaseUrl: selectData.videoContent,
          //     extraHeaders: selectData.httpHeaders ?? {},
          //     bindAddress: InternetAddress.loopbackIPv4,
          //   );
          //   final proxyUrl =
          //       'http://${server.address.address}:${server.port}/playlist.m3u8';

          //   Future<void> openProxyM3u8() async {
          //     final uri = Uri.parse(proxyUrl);
          //     await launchUrl(uri, mode: LaunchMode.externalApplication);
          //   }

          //   await openProxyM3u8();
          //   // await server.close(force: true);
          // }

          await context.pushEnum(
            RouteName.PLAYER,
            extra: PlayerArgs(
              firstSelectData: selectData,
              data: qualities,
              anime: content,
              episode: data,
              startPossition: startPossition,
            ),
          );
        }
        break;
    }
  }

  static Future<(Data?, List<Data>)?> _fileOrURL(
    Release release,
    Content content,
    File? file,
    BuildContext context,
  ) async {
    final repository = context.read<ContentRepository>();
    // final historicController = context.read<HistoricController>();

    // final colorScheme = Theme.of(context).colorScheme;

    final List<Data?> data = [];
    final result = await repository.getContent(release, content);

    result.fold(onSuccess: (success) => data.addAll(success.nonNulls.cast<Data?>()));

    if (!context.mounted) {
      return (null, data.nonNulls.toList());
    }

    data.insert(0, null);

    // final position = historicController.repo
    //     .getHistoric<EpisodeEntity>(release: release, content: content)
    //     ?.position;

    if (file != null) data[0] = FileVideoData(file: file);
    // bool enable = false;
    return await showModalBottomSheet<(Data?, List<Data>)?>(
      isScrollControlled: true,
      context: context,
      builder: (context) => _SelectData(content: content, release: release, data: data),
    );
  }
}

class _SelectData extends StatelessWidget {
  const _SelectData({required this.release, required this.content, required this.data});
  final Release release;
  final Content content;
  final List<Data?> data;

  void _onTap(Data select, List<Data?> data, BuildContext context) {
    Navigator.of(context).pop((select, data.nonNulls.toList()));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sizeOf = context.sizeOf;
    // customLog(sizeOf.height);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // const Divider(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(right: 8, left: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReleaseLeading(
                    width: 80,
                    downloadProgressIndicatorEnable: false,
                    watchProgressIndicatorEnable: false,
                    height: 100,
                    release: release,
                    content: content,
                    showDurationLabel: false,
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 100,
                    width: 180,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${release.numberInt}. ${release.title}',
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DefaultTextStyle(
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color(
                                0xFFB0B0B0,
                              ), // cinza claro para contraste no dark
                              height: 1.3,
                            ),
                            child: ReleaseSubtitle(release: release, enableIcon: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     StatefulBuilder(
                  //       builder: (context, set) {
                  //         return SizedBox(
                  //           width: 60,
                  //           height: 40,
                  //           child: Switch(
                  //             value: enable,
                  //             onChanged: (bool value) {},
                  //             thumbIcon: WidgetStateProperty.resolveWith<Icon?>((
                  //               Set<WidgetState> states,
                  //             ) {
                  //               if (states.contains(WidgetState.disabled)) {
                  //                 return const Icon(Icons.history);
                  //               }

                  //               return const Icon(Icons.history);
                  //             }),
                  //           ),
                  //         );
                  //       },
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.only(top: 12),
        //   child: Text('Selecione uma fonte', style: textTheme.titleLarge),
        // ),
        // const Divider(),
        SizedBox(
          width: double.infinity,
          height: 100,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 22),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(right: 8, left: 8),
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(data.length, (index) {
                    final video = Dual(data.unmodifiable, data.reversed.unmodifiable)
                        .pick<UnmodifiableListView<Data?>>(data.contains(null))
                        .elementAt(index);

                    // data.contains(null)
                    //     ? data.elementAt(index)
                    //     : data.reversed.elementAt(index);
                    final color = video == null ? Colors.grey : Colors.white;
                    final title = video?.getTitle() ?? "Local";

                    Widget container = ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // DecoratedBox(decoration: BoxDecoration(color: color)),
                          Center(
                            child: Text(
                              title,
                              style: textTheme.labelMedium?.copyWith(color: color),
                            ),
                          ),
                          if (video != null)
                            Material(
                              type: MaterialType.transparency,
                              child: InkWell(onTap: () => _onTap(video, data, context)),
                            ),
                        ],
                      ),
                    );

                    container = Card.outlined(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: container,
                    );
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      height: 80,
                      width: sizeOf.width / 2.2,
                      child: container,
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
