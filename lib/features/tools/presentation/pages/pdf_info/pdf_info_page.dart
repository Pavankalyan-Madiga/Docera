import 'package:flutter/material.dart';

class Pdf_InfoPage extends StatelessWidget {
  const Pdf_InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('PDF Info'),
      ),
      body: Center(
        child: Text(
          'PDF Info',
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
