import 'package:flutter/material.dart';

import '../../models/settings_item_model.dart';
import 'settings_item.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<SettingsItemModel> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF101631),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE9EBF1),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06101631),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                SettingsItem(
                  item: items[i],
                ),
                if (i != items.length - 1)
                  const Padding(
                    padding: EdgeInsets.only(left: 66),
                    child: Divider(
                      height: 1,
                      color: Color(0xFFEDEEF2),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}