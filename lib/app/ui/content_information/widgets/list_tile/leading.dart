import 'package:app_wsrb_jsr/app/ui/shared/widgets/bottom_menu.dart';
import 'package:border_progress_indicator/border_progress_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
import 'package:provider/provider.dart';

class ReleaseLeading extends StatelessWidget {
  const ReleaseLeading({
    super.key,
    required this.release,
    // A propriedade 'content' não estava sendo usada, mas a mantive.
    // Considere removê-la se não for necessária.
    required this.content,
  });

  final Release release;
  final Content content;

  @override
  Widget build(BuildContext context) {
    // --- 1. Coleta de Estado e Variáveis ---
    final colorScheme = Theme.of(context).colorScheme;

    // Controladores e Repositórios
    final historicController = context.watch<HistoricController>();
    // final appConfigController = context.watch<AppConfigController>();
    final downloadInfo = context.watch<DownloadInfo?>();
    final bottomMenuController =
        BottomMenu.menuControllerOf<List<String>>(context);

    // Dados do Histórico
    final historic = historicController.repo.getHistoric(release: release);
    final watchPercent = historic?.getPercent() ?? 0.0; // e.g., 0.75 for 75%
    final isWatched = historic?.isComplete == true;

    // Durações
    final episodeDuration = historic?.epdToDuration ?? Duration.zero;
    final episodeCurrentDuration = historic?.cdToDuration ?? Duration.zero;

    // Estado da UI
    final selectedIDs = bottomMenuController.args ?? const [];
    final isSelected = selectedIDs.contains(release.stringID);
    final progressColor =
        isWatched ? colorScheme.primary : colorScheme.secondary;
    final showDurationLabel =
        episodeCurrentDuration != Duration.zero && watchPercent > 0;

    // --- 2. Construção do Widget ---
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      width: 110,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        // A borda de seleção é aplicada aqui.
        border: isSelected ? Border.all(color: Colors.white) : null,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camada 1: Thumbnail ou Placeholder
          BuildThumbnail(release: release),

          // Camada 2: Indicador de Progresso de Visualização
          BuildWatchProgressIndicator(
            watchPercent: watchPercent,
            progressColor: progressColor,
            isSelected: isSelected,
          ),

          // Camada 3: Indicador de Progresso de Download (sobrepõe o de visualização se ativo)
          BuildDownloadProgressIndicator(
            downloadInfo: downloadInfo,
            progressColor: progressColor,
          ),

          // Camada 4: Rótulo de Duração (se aplicável)
          if (showDurationLabel)
            Positioned(
              top: 4,
              right: 6,
              child: BuildDurationLabel(
                currentDuration: episodeCurrentDuration,
                totalDuration: episodeDuration,
                textColor: historic?.completeColor(colorScheme),
              ),
            ),
        ],
      ),
    );
  }
}

class BuildDurationLabel extends StatelessWidget {
  const BuildDurationLabel({
    super.key,
    required this.currentDuration,
    required this.totalDuration,
    required this.textColor,
  });

  final Duration currentDuration;
  final Duration totalDuration;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final label = currentDuration.label(reference: totalDuration);
    return Text(
      label,
      style: TextStyle(color: textColor),
    );
  }
}

class BuildDownloadProgressIndicator extends StatelessWidget {
  const BuildDownloadProgressIndicator({
    super.key,
    required this.downloadInfo,
    required this.progressColor,
  });

  final DownloadInfo? downloadInfo;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    final isDownloading = downloadInfo?.isDownloading == true;
    final durationMs = downloadInfo?.videoDuration?.inMilliseconds;
    final time = downloadInfo?.time ?? 0;

    if (!isDownloading || durationMs == null || time <= 0.0) {
      return const SizedBox.shrink();
    }

    final downloadPercent = (time * 100) / durationMs;
    // customLog(downloadPercent); // customLog mantido se necessário

    return AnimatedBorderProgressIndicator(
      value: downloadPercent / 100,
      color: progressColor,
      strokeWidth: 2,
      borderRadius: 6,
    );
  }
}

class BuildThumbnail extends StatelessWidget {
  const BuildThumbnail({
    super.key,
    required this.release,
  });

  final Release release;

  @override
  Widget build(BuildContext context) {
    final thumbnail =
        (release is Episode) ? (release as Episode).thumbnail : null;

    if (thumbnail == null) {
      // Retorna um placeholder se não houver thumbnail.
      return const Card.filled();
    }

    final appConfigController = context.read<AppConfigController>();

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ShaderMask(
        blendMode: BlendMode.srcOver,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withAlpha(50), Colors.black.withAlpha(50)],
        ).createShader(bounds),
        child: CachedNetworkImage(
          cacheManager: App.APP_IMAGE_CACHE,
          httpHeaders: {
            ...App.HEADERS,
            'Referer': '${appConfigController.config.source.baseURL}/',
          },
          imageUrl: thumbnail,
          fit: BoxFit.cover,
          memCacheWidth: 200,
          memCacheHeight: 150,
          placeholder: (context, url) => Card.filled(
            margin: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          errorWidget: (context, url, error) => Card.filled(
            margin: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }
}

class BuildWatchProgressIndicator extends StatelessWidget {
  const BuildWatchProgressIndicator({
    super.key,
    required this.watchPercent,
    required this.progressColor,
    required this.isSelected,
  });

  final double watchPercent;
  final Color progressColor;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    if (watchPercent <= 0.0) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      // O layoutBuilder evita que o widget "pisque" durante a transição.
      layoutBuilder: (currentChild, previousChildren) {
        if (previousChildren.isNotEmpty) {
          return Stack(children: previousChildren);
        }
        return currentChild ?? const SizedBox.shrink();
      },
      child: !isSelected
          ? AnimatedBorderProgressIndicator(
              value: watchPercent,
              color: progressColor,
              strokeWidth: 2,
              borderRadius: 6,
            )
          : const SizedBox.shrink(),
    );
  }
}
