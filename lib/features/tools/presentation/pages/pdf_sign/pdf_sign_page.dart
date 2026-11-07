import 'package:flutter/material.dart';

class Pdf_SignPage extends StatelessWidget {
  const Pdf_SignPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('PDF Sign'),
      ),
      body: Center(
        child: Text(
          'PDF Sign',
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
