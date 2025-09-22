import 'dart:io';

import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/reading/arguments/reading_args.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  static Future<void> onTap(
    BuildContext context,
    Release release,
    Content content,
    int index,
  ) async {
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
        final result = await _fileOrURL(release, releaseFile, context, content);
        if (result != null && context.mounted) {
          await context.pushEnum(
            RouteName.PLAYER,
            extra: PlayerArgs(data: result, anime: content, episode: data),
          );
        }
        break;
    }
  }

  static Future<List<Data>?> _fileOrURL(
    Release release,
    File? file,
    BuildContext context,
    Content content,
  ) async {
    final repository = context.read<ContentRepository>();

    // final colorScheme = Theme.of(context).colorScheme;

    final data = (await repository.getContent(
      release,
      content,
    )).fold(onSuccess: (success) => success)?.nonNulls.cast<Data?>().toList();

    if (!context.mounted || data == null) return null;

    data.insert(0, null);

    if (file != null) data[0] = FileVideoData(file: file);

    return await showModalBottomSheet<List<Data>>(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text('Selecione uma fonte', style: textTheme.titleLarge),
            ),
            SizedBox(
              width: double.infinity,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 16, bottom: 22),
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(2, (index) {
                      final video = data[index];
                      final color = video == null ? Colors.grey : Colors.white;
                      Widget container = ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // DecoratedBox(decoration: BoxDecoration(color: color)),
                            Center(
                              child: Text(
                                video is VideoData ? 'Online' : 'Local',
                                style: textTheme.labelMedium?.copyWith(color: color),
                              ),
                            ),
                            Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                onTap: video == null
                                    ? null
                                    : () {
                                        Navigator.of(context).pop(
                                          data
                                              .where((data) => data != null)
                                              .nonNulls
                                              .toList(),
                                        );
                                      },
                              ),
                            ),
                          ],
                        ),
                      );

                      if (video == null) {
                        container = Card.filled(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: container,
                        );
                      } else {
                        container = Card.outlined(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: container,
                        );
                      }
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        height: 70,
                        width: 120,
                        child: container,
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
