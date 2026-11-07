import 'package:flutter/material.dart';

class Compress_PdfPage extends StatelessWidget {
  const Compress_PdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Compress PDF'),
      ),
      body: Center(
        child: Text(
          'Compress PDF',
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
