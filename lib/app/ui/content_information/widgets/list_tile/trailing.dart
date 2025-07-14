import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ReleaseTrailing extends StatelessWidget {
  const ReleaseTrailing({
    super.key,
    required this.release,
    required this.content,
  });

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
    final isDownloadingThisRelease = downloadInfo?.isDownloading == true &&
        downloadInfo?.releaseId == release.stringID;

    final downloadRelease = ContentScope.of(context).downloadRelease;

    // --- 2. Animação e Lógica de UI ---
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        // Animação de Fade e Scale para uma transição suave.
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
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
    required void Function(Release) downloadRelease,
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
            content:
                'Deseja cancelar o download do episódio ${release.number}?',
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
            content:
                'O arquivo baixado do episódio ${release.number} será removido.',
            confirmText: 'DELETAR',
            isDestructive: true,
          );
          if (confirm && context.mounted) {
            await downloadService.deleteReleaseFile(
              content: content,
              release: release,
            );
          }
        },
      );
    } else {
      // ESTADO: Padrão (Pronto para Baixar)
      return IconButton(
        key: const ValueKey('default'),
        padding: EdgeInsets.zero,
        icon: Icon(MdiIcons.downloadCircleOutline, size: 28),
        onPressed: () => downloadRelease(release),
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

    final percent = (downloadInfo!.time * 100) /
        downloadInfo!.videoDuration!.inMilliseconds;

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
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 9),
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
                  color: isDestructive
                      ? Colors.red
                      : Theme.of(context).primaryColor),
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
