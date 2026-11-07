import 'package:flutter/material.dart';

class Delete_PagesPage extends StatelessWidget {
  const Delete_PagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Delete Pages'),
      ),
      body: Center(
        child: Text(
          'Delete Pages',
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
