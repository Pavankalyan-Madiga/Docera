import 'package:flutter/material.dart';

import '../../../../core/storage/docera_file_model.dart';
import '../../../../core/storage/file_storage_service.dart';

class RecentFilesSection extends StatelessWidget {
  const RecentFilesSection({
    super.key,
    this.onSeeAll,
    this.onFileTap,
  });

  final VoidCallback? onSeeAll;
  final void Function(DoceraFileModel file)? onFileTap;

  Future<List<DoceraFileModel>> _loadRecentFiles() {
    return FileStorageService.getRecentFiles(
      limit: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DoceraFileModel>>(
      future: _loadRecentFiles(),
      builder: (context, snapshot) {
        final files = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Recent Files',
                      style: TextStyle(
                        color: Color(0xFF101631),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (onSeeAll != null)
                    GestureDetector(
                      onTap: onSeeAll,
                      child: const Text(
                        'See all',
                        style: TextStyle(
                          color: Color(0xFF146CE8),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (snapshot.connectionState ==
                ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 30,
                ),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF146CE8),
                    ),
                  ),
                ),
              )
            else if (snapshot.hasError)
              _buildError()
            else if (files.isEmpty)
              _buildEmpty()
            else
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                child: Column(
                  children: [
                    for (
                      int index = 0;
                      index < files.length;
                      index++
                    ) ...[
                      _RecentFileRow(
                        file: files[index],
                        onTap: () {
                          onFileTap?.call(files[index]);
                        },
                      ),
                      if (index != files.length - 1)
                        const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 18,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE8EAF0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FF),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: Color(0xFF146CE8),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No recent files',
                    style: TextStyle(
                      color: Color(0xFF101631),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Your saved files will appear here.',
                    style: TextStyle(
                      color: Color(0xFF737A90),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 20,
      ),
      child: Text(
        'Unable to load recent files.',
        style: TextStyle(
          color: Color(0xFF737A90),
          fontSize: 13,
        ),
      ),
    );
  }
}

class _RecentFileRow extends StatelessWidget {
  const _RecentFileRow({
    required this.file,
    required this.onTap,
  });

  final DoceraFileModel file;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE8EAF0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _getFileColor(file)
                      .withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(
                    _getFileType(file),
                    style: TextStyle(
                      color: _getFileColor(file),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF101631),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          _formatDate(file.createdAt),
                          style: const TextStyle(
                            color: Color(0xFF737A90),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: Color(0xFFB7BBC7),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          file.extension.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF737A90),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9AA0AF),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFileType(DoceraFileModel file) {
    switch (file.extension.toLowerCase()) {
      case 'pdf':
        return 'PDF';
      case 'doc':
      case 'docx':
        return 'DOC';
      case 'xls':
      case 'xlsx':
        return 'XLS';
      case 'ppt':
      case 'pptx':
        return 'PPT';
      case 'jpg':
      case 'jpeg':
        return 'JPG';
      case 'png':
        return 'PNG';
      case 'webp':
        return 'WEBP';
      default:
        return 'FILE';
    }
  }

  Color _getFileColor(DoceraFileModel file) {
    switch (file.extension.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFFF3030);
      case 'doc':
      case 'docx':
        return const Color(0xFF1478E8);
      case 'xls':
      case 'xlsx':
        return const Color(0xFF12A968);
      case 'ppt':
      case 'pptx':
        return const Color(0xFFFF7100);
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
        return const Color(0xFF8B3DDB);
      default:
        return const Color(0xFF737A90);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} '
        '${date.day.toString().padLeft(2, '0')}, '
        '${date.year}';
  }
}