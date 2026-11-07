import 'package:flutter/material.dart';

class NewFolderCard extends StatelessWidget {
  const NewFolderCard({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 135,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F8FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFBDD2F8),
              width: 1.1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 35,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0EBFF),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.create_new_folder_outlined,
                  size: 23,
                  color: Color(0xFF146CE8),
                ),
              ),
              const Spacer(),
              const Text(
                'New Folder',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101631),
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Create a folder',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF737B8C),
                ),
              ),
              const SizedBox(height: 2),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 17,
                    color: Color(0xFF146CE8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}