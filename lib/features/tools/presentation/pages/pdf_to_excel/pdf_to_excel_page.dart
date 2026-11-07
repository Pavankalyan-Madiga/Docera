import 'package:flutter/material.dart';

class Pdf_To_ExcelPage extends StatelessWidget {
  const Pdf_To_ExcelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('PDF to Excel'),
      ),
      body: Center(
        child: Text(
          'PDF to Excel',
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
