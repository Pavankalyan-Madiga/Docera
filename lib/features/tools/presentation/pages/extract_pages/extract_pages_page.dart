import 'package:flutter/material.dart';

class Extract_PagesPage extends StatelessWidget {
  const Extract_PagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Extract Pages'),
      ),
      body: Center(
        child: Text(
          'Extract Pages',
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
