import 'package:flutter/material.dart';

import '../../models/tool_model.dart';

class ToolCard extends StatelessWidget {
  const ToolCard({
    super.key,
    required this.tool,
  });

  final ToolModel tool;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: tool.onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 112,
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFFF0F1F5),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08101631),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: tool.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  tool.icon,
                  size: 24,
                  color: tool.iconColor,
                ),
              ),
              const SizedBox(height: 7),
              Expanded(
                child: Center(
                  child: Text(
                    tool.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF101631),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}