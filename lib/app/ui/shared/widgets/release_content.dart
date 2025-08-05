import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/bottom_menu.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_network_image_cache.dart';
import 'package:border_progress_indicator/border_progress_indicator.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
import 'package:provider/provider.dart';

class ReleaseContent<T extends Release> extends StatelessWidget {
  const ReleaseContent({
    super.key,
    required this.release,
    required this.content,
    required this.index,
    this.onTap,
    this.selected = false,
    this.onLongPress,
    this.onDoubleTap,
    this.trailing,
    this.leading,
  });
  final int index;
  final T release;
  final Content content;
  final bool selected;
  final Widget? trailing;
  final Widget? leading;
  final void Function(T release)? onTap;
  final void Function(T release)? onLongPress;
  final void Function(T release)? onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final DownloadService downloadService = context.watch<DownloadService>();
    final DownloadInfo? downloadInfo = downloadService.downloadList.firstWhereOrNull(
      (info) => info.releaseId.contains(release.stringID),
    );

    final colorScheme = Theme.of(context).colorScheme;

    Widget container = ListTile(
      selected: selected,
      isThreeLine: false,
      dense: true,
      // isThreeLine: false,
      subtitle: _ReleaseSubtitle(release: release),
      horizontalTitleGap: 20,
      contentPadding: const EdgeInsets.only(left: 16.0, right: 8),
      trailing: trailing ?? ReleaseTrailing(content: content, release: release),
      leading: leading ?? ReleaseLeading(content: content, release: release),
      subtitleTextStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Color(0xFFB0B0B0), // cinza claro para contraste no dark
        height: 1.3,
      ),
      titleTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.3,
        overflow: TextOverflow.ellipsis,
      ),
      // onTap: () => _listTitleOntap(context),
      onTap: null,
      minVerticalPadding: 0,
      minTileHeight: 76,
      visualDensity: const VisualDensity(vertical: 3, horizontal: -2),
      title: Text('${release.number}. ${release.title}', maxLines: 2),
    );

    if (downloadInfo != null) {
      container = ChangeNotifierProvider.value(value: downloadInfo, child: container);
    }

    return InkWell(
      onTap: onTap != null ? () => onTap?.call(release) : null,
      onDoubleTap: () => onDoubleTap?.call(release),
      splashFactory: InkRipple.splashFactory,
      onLongPress: () => onLongPress?.call(release),
      overlayColor: _OverlayColor(colorScheme),
      child: container,
    );
  }
}

class _ReleaseSubtitle extends StatelessWidget {
  const _ReleaseSubtitle({required this.release});

  final Release release;

  @override
  Widget build(BuildContext context) {
    if (release case Episode data when data.registrationData != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(MdiIcons.clock, size: 16),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                data.formatRegistrationData(),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

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
    final bottomMenuController = BottomMenu.menuControllerMaybeOf<List<String>>(context);

    // Dados do Histórico
    final historic = historicController.repo.getHistoric(release: release);
    final watchPercent = historic?.getPercent() ?? 0.0; // e.g., 0.75 for 75%
    final isWatched = historic?.isComplete == true;

    // Durações
    final episodeDuration = historic?.epdToDuration ?? Duration.zero;
    final episodeCurrentDuration = historic?.cdToDuration ?? Duration.zero;

    // Estado da UI
    final selectedIDs = bottomMenuController?.args ?? const [];
    final isSelected = selectedIDs.contains(release.stringID);
    final progressColor = isWatched ? colorScheme.primary : colorScheme.secondary;
    final showDurationLabel = episodeCurrentDuration != Duration.zero && watchPercent > 0;

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
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
    return Text(label, style: TextStyle(color: textColor));
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
  const BuildThumbnail({super.key, required this.release});

  final Release release;

  @override
  Widget build(BuildContext context) {
    final thumbnail = (release is Episode) ? (release as Episode).thumbnail : null;

    if (thumbnail == null) {
      // Retorna um placeholder se não houver thumbnail.
      return Card.filled(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );
    }

    // final appConfigController = context.read<AppConfigController>();

    return CustomCachedNetworkImage(
      imageUrl: thumbnail,
      borderRadius: BorderRadius.circular(8),
      blendMode: BlendMode.srcOver,
      memCacheWidth: 200,
      memCacheHeight: 150,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.black.withAlpha(50), Colors.black.withAlpha(50)],
      ).createShader(bounds),
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
              strokeWidth: 3,
              borderRadius: 8,
            )
          : const SizedBox.shrink(),
    );
  }
}

class ReleaseTrailing extends StatelessWidget {
  const ReleaseTrailing({super.key, required this.release, required this.content});

  final Release release;
  final Content content;

  @override
  Widget build(BuildContext context) {
    // --- 1. Coleta de Estado ---
    final downloadService = context.watch<DownloadService>();
    final downloadInfo = context.watch<DownloadInfo?>();

    final releaseFile = AppStorage.getReleaseFile(content, release);
    final isDownloaded = releaseFile?.existsSync() ?? false;

    // Verifica se o download em progresso é para este 'release' específico.
    final isDownloadingThisRelease =
        downloadInfo?.isDownloading == true &&
        downloadInfo?.releaseId == release.stringID;

    final downloadRelease = ContentScope.maybeOf(context)?.downloadRelease;

    // --- 2. Animação e Lógica de UI ---
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        // Animação de Fade e Scale para uma transição suave.
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: _buildIconButton(
        context,
        isDownloading: isDownloadingThisRelease,
        isDownloaded: isDownloaded,
        downloadInfo: downloadInfo,
        downloadService: downloadService,
        downloadRelease: downloadRelease,
      ),
    );
  }

  // Constrói o IconButton apropriado com base no estado atual.
  Widget _buildIconButton(
    BuildContext context, {
    required bool isDownloading,
    required bool isDownloaded,
    required DownloadInfo? downloadInfo,
    required DownloadService downloadService,
    required void Function(Release)? downloadRelease,
  }) {
    if (isDownloading) {
      // ESTADO: Em Download
      return IconButton(
        // A chave garante que o AnimatedSwitcher identifique este widget como único.
        key: const ValueKey('downloading'),
        padding: EdgeInsets.zero,
        icon: _DownloadProgressIndicator(downloadInfo: downloadInfo),
        onPressed: () async {
          final confirm = await _showConfirmationDialog(
            context,
            title: 'Cancelar Download?',
            content: 'Deseja cancelar o download do episódio ${release.number}?',
            confirmText: 'SIM, CANCELAR',
          );
          if (confirm && downloadInfo?.id != null && context.mounted) {
            await downloadService.cancelReleaseDownload(
              content: content,
              release: release,
              sessionId: downloadInfo!.id,
            );
          }
        },
      );
    } else if (isDownloaded) {
      // ESTADO: Já Baixado
      return IconButton(
        key: const ValueKey('downloaded'),
        padding: EdgeInsets.zero,
        icon: Icon(MdiIcons.checkCircle, size: 28, color: Colors.blueAccent),
        onPressed: () async {
          final confirm = await _showConfirmationDialog(
            context,
            title: 'Deletar Episódio?',
            content: 'O arquivo baixado do episódio ${release.number} será removido.',
            confirmText: 'DELETAR',
            isDestructive: true,
          );
          if (confirm && context.mounted) {
            await downloadService.deleteReleaseFile(content: content, release: release);
          }
        },
      );
    } else {
      // ESTADO: Padrão (Pronto para Baixar)
      return IconButton(
        key: const ValueKey('default'),
        padding: EdgeInsets.zero,
        icon: Icon(MdiIcons.downloadCircleOutline, size: 28),
        onPressed: () => downloadRelease?.call(release),
      );
    }
  }
}

/// Um widget privado para exibir o indicador de progresso de download.
class _DownloadProgressIndicator extends StatelessWidget {
  const _DownloadProgressIndicator({required this.downloadInfo});

  final DownloadInfo? downloadInfo;

  @override
  Widget build(BuildContext context) {
    final hasProgress =
        downloadInfo?.videoDuration != null && (downloadInfo?.time ?? 0) > 0.0;

    if (!hasProgress) {
      // Exibe um spinner genérico se o progresso ainda não for conhecido.
      return const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator.adaptive(strokeWidth: 3),
      );
    }

    final percent =
        (downloadInfo!.time * 100) / downloadInfo!.videoDuration!.inMilliseconds;

    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator.adaptive(
            value: percent / 100,
            strokeWidth: 3,
            backgroundColor: Colors.grey.withOpacity(0.3),
          ),
          Center(
            child: Text(
              '${percent.ceil()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }
}

/// Função auxiliar para mostrar um diálogo de confirmação adaptativo.
Future<bool> _showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String content,
  required String confirmText,
  bool isDestructive = false,
}) async {
  final result = await showAdaptiveDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog.adaptive(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text('NÃO'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text(
              confirmText,
              style: TextStyle(
                color: isDestructive ? Colors.red : Theme.of(context).primaryColor,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );
  // Retorna 'true' se o usuário confirmar, 'false' caso contrário ou se o diálogo for dispensado.
  return result ?? false;
}

class _OverlayColor extends WidgetStateProperty<Color?> {
  _OverlayColor(ColorScheme colorScheme) {
    _color = colorScheme.primary;
  }

  Color? _color;

  @override
  Color? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.pressed)) {
      return _color?.withAlpha(36);
    } else if (states.contains(WidgetState.hovered)) {
      return _color?.withAlpha(20);
    } else if (states.contains(WidgetState.focused)) {
      return Colors.transparent;
    }
    return Colors.transparent;
  }
}
