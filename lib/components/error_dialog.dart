import 'package:flutter/material.dart';
import 'package:linktostream/components/update_checker.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog(this.errorMessage, {Key? key}) : super(key: key);
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.from(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
      ),
      child: AlertDialog(
        title: const Text('Error from yt-dlp'),
        icon: const Icon(Icons.error),
        iconPadding: const EdgeInsets.only(top: 12),
        content: SelectableText(errorMessage),
        insetPadding: const EdgeInsets.all(12),
        titlePadding: const EdgeInsets.symmetric(vertical: 3),
        contentPadding: const EdgeInsets.all(12),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        scrollable: true,
        actions: [
          OutlinedButton(
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const UpdateChecker(),
              );
            },
            child: const Text('Check for updates'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }
}
