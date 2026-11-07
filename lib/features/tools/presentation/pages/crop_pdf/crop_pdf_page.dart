import 'package:flutter/material.dart';

class Crop_PdfPage extends StatelessWidget {
  const Crop_PdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Crop PDF'),
      ),
      body: Center(
        child: Text(
          'Crop PDF',
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
