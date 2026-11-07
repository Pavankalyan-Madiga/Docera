import 'package:flutter/material.dart';

class FileItem extends StatelessWidget {
  const FileItem({
    super.key,
    required this.name,
    required this.date,
    required this.size,
    required this.type,
    required this.color,
    this.onTap,
    this.onFavoriteTap,
    this.onMoreTap,
  });

  final String name;
  final String date;
  final String size;
  final String type;
  final Color color;

  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 88,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFE9EBF1),
            ),
          ),
        ),
        child: Row(
          children: [
            _FileIcon(
              type: type,
              color: color,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101631),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$date  •  $size',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF737B8C),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onFavoriteTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 34,
                minHeight: 34,
              ),
              icon: const Icon(
                Icons.star_border_rounded,
                size: 23,
                color: Color(0xFF70788A),
              ),
            ),
            IconButton(
              onPressed: onTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 34,
                minHeight: 34,
              ),
              icon: const Icon(
                Icons.open_in_new_rounded,
                size: 22,
                color: Color(0xFF70788A),
              ),
            ),
            IconButton(
              onPressed: onMoreTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 28,
                minHeight: 34,
              ),
              icon: const Icon(
                Icons.more_vert_rounded,
                size: 23,
                color: Color(0xFF70788A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileIcon extends StatelessWidget {
  const _FileIcon({
    required this.type,
    required this.color,
  });

  final String type;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isImage = type == 'JPG';

    return Container(
      width: 48,
      height: 52,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Center(
        child: isImage
            ? const Icon(
                Icons.image_outlined,
                color: Colors.white,
                size: 27,
              )
            : Text(
                type,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}