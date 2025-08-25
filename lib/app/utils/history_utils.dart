import 'package:app_wsrb_jsr/app/ui/home/widgets/filtro_bottom_sheet.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/global_overlay.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';

class HistoryUtils {
  HistoryUtils._();

  static Future<void> historicFilterSheet(BuildContext context) async {
    // final result = await Navigator.push(
    //   context,
    //   FiltroBottomSheetRoute(
    //     appConfigController: context.read(),
    //     bottomSheetAnimationController: HomeScope.of(
    //       context,
    //     ).bottomSheetAnimationController,
    //   ),
    // );

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Necessário para ajustar à altura do conteúdo/teclado
      shape: RoundedRectangleBorder(),
      builder: (context) => FiltroBottomSheet(),
    );

    // _appConfigController.setFilterWatching(result);
    customLog(result);
  }

  static Future<void> questionDelete(
    BuildContext context,
    List<HistoricEntity> entity, {
    required VoidCallback onConfirmDelete,
    required ValueChanged<List<HistoricEntity>> onUndoDelete,
  }) async {
    String listText = entity.length == 1
        ? "item ${entity.first.title}"
        : "${entity.length} itens";

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Deseja remover $listText?",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        content: const Text("Essa ação não pode ser desfeita depois de 5 segundos."),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sim"),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      onConfirmDelete();

      context.showCancelableNotification(
        "$listText removido.",
        position: NotificationPosition.top,
        onCancel: () => onUndoDelete.call(entity),
      );
    }
  }
}
