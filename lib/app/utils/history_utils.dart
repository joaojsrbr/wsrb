import 'package:app_wsrb_jsr/app/utils/app_snack_bar.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';

class HistoryUtils {
  HistoryUtils._();

  static Future<void> questionDelete(
    BuildContext context,
    List<HistoricEntity> entity, {
    required VoidCallback onConfirmDelete,
    required ValueChanged<List<HistoricEntity>> onUndoDelete,
  }) async {
    String listText = "";

    if (entity.length == 1) {
      listText = "item ${entity.first.title}";
    } else {
      // listText = entity
      //     .sublist(0, entity.length > 2 ? 2 : entity.length)
      //     .map((entity) => entity.title)
      //     .join(" ,")
      //     .padLeft(1, "...");
      listText = "${entity.length} itens";
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Deseja remover $listText?"),
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

      await context.showCancelableSnackBar(
        content: Text("$listText removido."),
        onCancel: () => onUndoDelete.call(entity),
      );
    }
  }
}
