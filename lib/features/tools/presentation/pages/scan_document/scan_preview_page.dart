import 'dart:io';

import 'package:flutter/material.dart';

import 'scan_editor_page.dart';

class ScanPreviewPage extends StatefulWidget {
  const ScanPreviewPage({
    super.key,
    required this.pages,
  });

  final List<File> pages;

  @override
  State<ScanPreviewPage> createState() => _ScanPreviewPageState();
}

class _ScanPreviewPageState extends State<ScanPreviewPage> {
  late List<File> _pages;

  @override
  void initState() {
    super.initState();
    _pages = List<File>.from(widget.pages);
  }

  Future<void> _editPage(int index) async {
    final updatedPages = await Navigator.push<List<File>>(
      context,
      MaterialPageRoute(
        builder: (_) => ScanEditorPage(
          pages: List<File>.from(_pages),
          initialIndex: index,
        ),
      ),
    );

    if (!mounted || updatedPages == null) return;

    setState(() {
      _pages
        ..clear()
        ..addAll(updatedPages);
    });
  }

  void _deletePage(int index) {
    setState(() {
      _pages.removeAt(index);
    });

    if (_pages.isEmpty) {
      Navigator.pop(context, <File>[]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FD),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Scan Preview',
          style: TextStyle(
            color: Color(0xFF101631),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF101631),
          ),
        ),
      ),
      body: _pages.isEmpty
          ? const Center(
              child: Text(
                'No pages',
                style: TextStyle(
                  color: Color(0xFF737A90),
                  fontSize: 15,
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(
                18,
                12,
                18,
                110,
              ),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _PageCard(
                  file: _pages[index],
                  pageNumber: index + 1,
                  onEdit: () => _editPage(index),
                  onDelete: () => _deletePage(index),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            18,
            8,
            18,
            16,
          ),
          child: SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _pages.isEmpty
                  ? null
                  : () {
                      Navigator.pop(
                        context,
                        List<File>.from(_pages),
                      );
                    },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF146CE8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                _pages.isEmpty
                    ? 'No Pages'
                    : 'Use ${_pages.length} ${_pages.length == 1 ? 'Page' : 'Pages'}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageCard extends StatelessWidget {
  const _PageCard({
    required this.file,
    required this.pageNumber,
    required this.onEdit,
    required this.onDelete,
  });

  final File file;
  final int pageNumber;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  file,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$pageNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 5,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 17,
                    ),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF146CE8),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFE53935),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}