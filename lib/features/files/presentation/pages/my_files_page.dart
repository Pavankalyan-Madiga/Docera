import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/storage/docera_file_model.dart';
import '../../../../core/storage/file_storage_service.dart';
import '../widgets/my_files_header.dart';
import '../widgets/file_category_chips.dart';
import '../widgets/new_folder_card.dart';
import '../widgets/folder_item.dart';
import '../widgets/file_item.dart';

class MyFilesPage extends StatefulWidget {
  const MyFilesPage({super.key});

  @override
  State<MyFilesPage> createState() => _MyFilesPageState();
}

class _MyFilesPageState extends State<MyFilesPage> {
  String selectedCategory = 'All';

  final List<Map<String, dynamic>> folders = [
    {
      'name': 'College',
      'items': 5,
      'date': 'Oct 20, 2026',
    },
    {
      'name': 'Notes',
      'items': 12,
      'date': 'Oct 18, 2026',
    },
    {
      'name': 'Projects',
      'items': 8,
      'date': 'Oct 12, 2026',
    },
  ];

  Future<List<DoceraFileModel>> _loadFiles() {
    return FileStorageService.getFiles();
  }

  List<DoceraFileModel> _filterFiles(
    List<DoceraFileModel> files,
  ) {
    if (selectedCategory == 'All') {
      return files;
    }

    return files
        .where(
          (file) => file.type == selectedCategory,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFFF8F9FD),
              padding: const EdgeInsets.fromLTRB(
                18,
                10,
                18,
                10,
              ),
              child: MyFilesHeader(
                onSearchTap: _onSearchTap,
                onFilterTap: _onFilterTap,
              ),
            ),
            Container(
              width: double.infinity,
              color: const Color(0xFFF8F9FD),
              padding: const EdgeInsets.only(
                left: 18,
                bottom: 12,
              ),
              child: FileCategoryChips(
                selectedCategory: selectedCategory,
                onCategorySelected: (category) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<List<DoceraFileModel>>(
                future: _loadFiles(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return _buildFoldersAndLoading();
                  }

                  if (snapshot.hasError) {
                    return _buildFoldersAndError(
                      snapshot.error.toString(),
                    );
                  }

                  final allFiles = snapshot.data ?? [];
                  final filteredFiles =
                      _filterFiles(allFiles);

                  return _buildContent(
                    filteredFiles,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    List<DoceraFileModel> files,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(
          child: SizedBox(height: 4),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) {
                  return NewFolderCard(
                    onTap: _showCreateFolderDialog,
                  );
                }

                final folder = folders[index - 1];

                return FolderItem(
                  name: folder['name'] as String,
                  itemCount: folder['items'] as int,
                  date: folder['date'] as String,
                  onTap: () {
                    _openFolder(index - 1);
                  },
                  onEdit: () {
                    _showRenameFolderDialog(
                      index - 1,
                    );
                  },
                  onDelete: () {
                    _showDeleteFolderDialog(
                      index - 1,
                    );
                  },
                );
              },
              childCount: folders.length + 1,
            ),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 135,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 22),
        ),
        if (files.isEmpty)
          const SliverToBoxAdapter(
            child: _EmptyFilesView(),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final file = files[index];

                  return FileItem(
                    name: file.name,
                    date: _formatDate(file.createdAt),
                    size: _formatFileSize(file.path),
                    type: _getFileTypeLabel(file),
                    color: _getFileColor(file),
                    onTap: () {
                      _openFile(file);
                    },
                    onFavoriteTap: () {
                      _toggleFavorite(file);
                    },
                    onMoreTap: () {
                      _showFileActions(file);
                    },
                  );
                },
                childCount: files.length,
              ),
            ),
          ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildFoldersAndLoading() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(
          child: SizedBox(height: 4),
        ),
        _buildFolderGrid(),
        const SliverToBoxAdapter(
          child: SizedBox(height: 22),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 30,
            ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF146CE8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFoldersAndError(String error) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(
          child: SizedBox(height: 4),
        ),
        _buildFolderGrid(),
        const SliverToBoxAdapter(
          child: SizedBox(height: 22),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Unable to load files\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF737A90),
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFolderGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return NewFolderCard(
                onTap: _showCreateFolderDialog,
              );
            }

            final folder = folders[index - 1];

            return FolderItem(
              name: folder['name'] as String,
              itemCount: folder['items'] as int,
              date: folder['date'] as String,
              onTap: () {
                _openFolder(index - 1);
              },
              onEdit: () {
                _showRenameFolderDialog(
                  index - 1,
                );
              },
              onDelete: () {
                _showDeleteFolderDialog(
                  index - 1,
                );
              },
            );
          },
          childCount: folders.length + 1,
        ),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: 135,
        ),
      ),
    );
  }

  String _getFileTypeLabel(
    DoceraFileModel file,
  ) {
    switch (file.extension.toLowerCase()) {
      case 'pdf':
        return 'PDF';
      case 'doc':
      case 'docx':
        return 'W';
      case 'xls':
      case 'xlsx':
        return 'X';
      case 'ppt':
      case 'pptx':
        return 'P';
      case 'jpg':
      case 'jpeg':
        return 'JPG';
      case 'png':
        return 'PNG';
      case 'webp':
        return 'WEBP';
      default:
        return file.extension.isEmpty
            ? 'FILE'
            : file.extension.toUpperCase();
    }
  }

  Color _getFileColor(
    DoceraFileModel file,
  ) {
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

  String _formatDate(
    DateTime date,
  ) {
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

  String _formatFileSize(
    String path,
  ) {
    try {
      final file = File(path);

      if (!file.existsSync()) {
        return 'Unknown size';
      }

      final bytes = file.lengthSync();

      if (bytes < 1024) {
        return '$bytes B';
      }

      if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      }

      if (bytes < 1024 * 1024 * 1024) {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }

      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    } catch (_) {
      return 'Unknown size';
    }
  }

  void _showCreateFolderDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Create Folder',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101631),
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization:
                TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Folder name',
              filled: true,
              fillColor: const Color(0xFFF5F6FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF146CE8),
                  width: 1.2,
                ),
              ),
            ),
            onSubmitted: (_) {
              _createFolder(
                dialogContext,
                controller.text,
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                _createFolder(
                  dialogContext,
                  controller.text,
                );
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _createFolder(
    BuildContext dialogContext,
    String value,
  ) {
    final name = value.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a folder name',
          ),
        ),
      );
      return;
    }

    final exists = folders.any(
      (folder) =>
          (folder['name'] as String).toLowerCase() ==
          name.toLowerCase(),
    );

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A folder with this name already exists',
          ),
        ),
      );
      return;
    }

    setState(() {
      folders.insert(
        0,
        {
          'name': name,
          'items': 0,
          'date': 'Today',
        },
      );
    });

    Navigator.of(dialogContext).pop();
  }

  void _showRenameFolderDialog(
    int folderIndex,
  ) {
    if (folderIndex < 0 ||
        folderIndex >= folders.length) {
      return;
    }

    final controller = TextEditingController(
      text: folders[folderIndex]['name'] as String,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Rename Folder',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101631),
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization:
                TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Folder name',
              filled: true,
              fillColor: const Color(0xFFF5F6FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF146CE8),
                  width: 1.2,
                ),
              ),
            ),
            onSubmitted: (_) {
              _renameFolder(
                dialogContext,
                folderIndex,
                controller.text,
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                _renameFolder(
                  dialogContext,
                  folderIndex,
                  controller.text,
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _renameFolder(
    BuildContext dialogContext,
    int folderIndex,
    String value,
  ) {
    final name = value.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a folder name',
          ),
        ),
      );
      return;
    }

    final exists = folders.asMap().entries.any(
      (entry) =>
          entry.key != folderIndex &&
          (entry.value['name'] as String)
                  .toLowerCase() ==
              name.toLowerCase(),
    );

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A folder with this name already exists',
          ),
        ),
      );
      return;
    }

    setState(() {
      folders[folderIndex]['name'] = name;
    });

    Navigator.of(dialogContext).pop();
  }

  void _showDeleteFolderDialog(
    int folderIndex,
  ) {
    if (folderIndex < 0 ||
        folderIndex >= folders.length) {
      return;
    }

    final folderName =
        folders[folderIndex]['name'] as String;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Folder?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101631),
            ),
          ),
          content: Text(
            'Are you sure you want to delete "$folderName"?',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF737B8C),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xFFE53935),
              ),
              onPressed: () {
                setState(() {
                  folders.removeAt(folderIndex);
                });

                Navigator.of(dialogContext).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _openFolder(int index) {
    if (index < 0 || index >= folders.length) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opening ${folders[index]['name']}',
        ),
      ),
    );
  }

  void _openFile(
    DoceraFileModel file,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opening ${file.name}',
        ),
      ),
    );
  }

  void _toggleFavorite(
    DoceraFileModel file,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Favorite: ${file.name}',
        ),
      ),
    );
  }

  void _showFileActions(
    DoceraFileModel file,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9DCE4),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101631),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(
                    Icons.drive_file_move_outline,
                  ),
                  title: const Text('Move'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                  ),
                  title: const Text('Rename'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFE53935),
                  ),
                  title: const Text('Delete'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();

                    await FileStorageService.deleteFile(
                      file,
                    );

                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onSearchTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Search'),
      ),
    );
  }

  void _onFilterTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filter'),
      ),
    );
  }
}

class _EmptyFilesView extends StatelessWidget {
  const _EmptyFilesView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 36,
        horizontal: 20,
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.folder_open_rounded,
              size: 30,
              color: Color(0xFF146CE8),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No files yet',
            style: TextStyle(
              color: Color(0xFF101631),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Files saved in Docera will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF737A90),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}