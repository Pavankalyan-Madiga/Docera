import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _action(
          icon: Icons.document_scanner_outlined,
          title: 'Scan',
          subtitle: 'Document',
          iconColor: const Color(0xFF7A36E8),
          backgroundColor: const Color(0xFFF0E9FF),
        ),
        const SizedBox(width: 7),
        _action(
          icon: Icons.text_fields_rounded,
          title: 'OCR',
          subtitle: 'Image to Text',
          iconColor: const Color(0xFF16B990),
          backgroundColor: const Color(0xFFE5FAF4),
        ),
        const SizedBox(width: 7),
        _action(
          icon: Icons.draw_rounded,
          title: 'PDF',
          subtitle: 'Sign',
          iconColor: const Color(0xFFF04B55),
          backgroundColor: const Color(0xFFFFECEC),
        ),
        const SizedBox(width: 7),
        _action(
          icon: Icons.lock_rounded,
          title: 'PDF',
          subtitle: 'Protect',
          iconColor: const Color(0xFF146CE8),
          backgroundColor: const Color(0xFFE8F0FF),
        ),
      ],
    );
  }

  Widget _action({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Expanded(
      child: Container(
        height: 119,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 9,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                size: 27,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF161C35),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF252C46),
              ),
            ),
          ],
        ),
      ),
    );
  }
}