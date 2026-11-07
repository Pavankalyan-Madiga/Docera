import 'package:flutter/material.dart';

class Merge_PdfPage extends StatelessWidget {
  const Merge_PdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Merge PDF'),
      ),
      body: Center(
        child: Text(
          'Merge PDF',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
