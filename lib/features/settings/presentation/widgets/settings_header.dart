import 'package:flutter/material.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({
    super.key,
    this.onBackTap,
  });

  final VoidCallback? onBackTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          Material(
            color: const Color(0xFFF0F2F8),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onBackTap ?? () => Navigator.of(context).pop(),
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(9),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 21,
                  color: Color(0xFF101631),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF101631),
              letterSpacing: -0.8,
            ),
          ),
        ],
      ),
    );
  }
}