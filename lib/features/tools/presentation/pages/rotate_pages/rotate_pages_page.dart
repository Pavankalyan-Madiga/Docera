import 'package:flutter/material.dart';

class Rotate_PagesPage extends StatelessWidget {
  const Rotate_PagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Rotate Pages'),
      ),
      body: Center(
        child: Text(
          'Rotate Pages',
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
