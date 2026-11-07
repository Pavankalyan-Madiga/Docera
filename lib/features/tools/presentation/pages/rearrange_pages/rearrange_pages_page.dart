import 'package:flutter/material.dart';

class Rearrange_PagesPage extends StatelessWidget {
  const Rearrange_PagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Rearrange Pages'),
      ),
      body: Center(
        child: Text(
          'Rearrange Pages',
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
