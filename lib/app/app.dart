import 'package:docera/app/theme/app_theme.dart';
import 'package:docera/navigation/main_navigation.dart';
import 'package:flutter/material.dart';


class DoceraApp extends StatelessWidget {
  const DoceraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Docera',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigation(),
    );
  }
}