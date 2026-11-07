import 'package:flutter/material.dart';

import '../features/files/presentation/pages/my_files_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/tools/presentation/pages/tools_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({
    super.key,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  void _changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final pages = [
      HomePage(
        onSeeAllFiles: () {
          _changeTab(1);
        },
      ),
      const MyFilesPage(),
      const ToolsPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: _changeTab,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        backgroundColor: theme.colorScheme.surface,
        indicatorColor: theme.colorScheme.primary.withValues(
          alpha: 0.12,
        ),
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: theme.colorScheme.onSurface.withValues(
                alpha: 0.55,
              ),
            ),
            selectedIcon: Icon(
              Icons.home_rounded,
              color: theme.colorScheme.primary,
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.folder_outlined,
              color: theme.colorScheme.onSurface.withValues(
                alpha: 0.55,
              ),
            ),
            selectedIcon: Icon(
              Icons.folder_rounded,
              color: theme.colorScheme.primary,
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.grid_view_rounded,
              color: theme.colorScheme.onSurface.withValues(
                alpha: 0.55,
              ),
            ),
            selectedIcon: Icon(
              Icons.grid_view_rounded,
              color: theme.colorScheme.primary,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}