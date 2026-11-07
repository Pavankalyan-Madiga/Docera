import 'package:flutter/material.dart';

class MyFilesHeader extends StatelessWidget {
  const MyFilesHeader({
    super.key,
    this.onSearchTap,
    this.onFilterTap,
  });

  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          const Text(
            'My Files',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF101631),
              letterSpacing: -1.2,
            ),
          ),
          const Spacer(),
          _HeaderButton(
            icon: Icons.search_rounded,
            onTap: onSearchTap,
          ),
          const SizedBox(width: 8),
          _HeaderButton(
            icon: Icons.tune_rounded,
            onTap: onFilterTap,
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0F2F8),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(
            icon,
            size: 21,
            color: const Color(0xFF101631),
          ),
        ),
      ),
    );
  }
}