import 'package:flutter/material.dart';

class Split_PdfPage extends StatelessWidget {
  const Split_PdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Split PDF'),
      ),
      body: Center(
        child: Text(
          'Split PDF',
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
