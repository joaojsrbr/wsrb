import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';

class HistoryUtils {
  HistoryUtils._();

  static Future<bool> questionDelete(BuildContext context, HistoricEntity entity) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Deseja remover ${entity.title}?"),
        content: Text("Essa ação não pode ser desfeita"),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar", style: TextStyle(color: Colors.red)),
          ),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Sim")),
        ],
      ),
    );
    return result ?? false;
  }
}
