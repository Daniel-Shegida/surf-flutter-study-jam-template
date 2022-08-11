import 'package:flutter/material.dart';

/// Controller to open dialogs.
class DialogController {
  /// Create an instance [DialogController].
  const DialogController();

  /// Shows a [SnackBar].
  void showSnackBar(BuildContext context, String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        shape:
            const Border(left: BorderSide(color: Colors.redAccent, width: 15)),
        behavior: SnackBarBehavior.fixed,
        content: Row(children: <Widget>[
          const Icon(
            Icons.error,
            color: Colors.redAccent,
            size: 36,
          ),
          const SizedBox(
            width: 16,
          ),
          Text(
            content,
            style: const TextStyle(fontSize: 16),
          ),
        ]), // Text(content),
      ),
    );
  }
}
