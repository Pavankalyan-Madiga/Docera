import 'package:flutter/material.dart';

class SettingsItemModel {
  const SettingsItemModel({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.subtitle,
    this.onTap,
    this.showSwitch = false,
    this.value = false,
    this.onChanged,
    this.showArrow = true,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final bool showSwitch;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool showArrow;
}