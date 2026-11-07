import 'package:flutter/material.dart';

import '../../models/settings_item_model.dart';

class SettingsItem extends StatelessWidget {
  const SettingsItem({
    super.key,
    required this.item,
  });

  final SettingsItemModel item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.showSwitch ? null : item.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.backgroundColor,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  item.icon,
                  size: 21,
                  color: item.iconColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF101631),
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF7B8291),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (item.showSwitch)
                Switch.adaptive(
                  value: item.value,
                  onChanged: item.onChanged,
                  activeTrackColor: const Color(0xFF146CE8),
                )
              else if (item.showArrow)
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: Color(0xFF9298A6),
                ),
            ],
          ),
        ),
      ),
    );
  }
}