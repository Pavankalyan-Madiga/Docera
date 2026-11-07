import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../../core/storage/file_storage_service.dart';
import 'services/images_to_pdf_service.dart';

class ImagesToPdfPage extends StatefulWidget {
  const ImagesToPdfPage({
    super.key,
  });

  @override
  State<ImagesToPdfPage> createState() =>
      _ImagesToPdfPageState();
}

class _ImagesToPdfPageState
    extends State<ImagesToPdfPage> {
  final List<File> _selectedImages = [];

  bool _isProcessing = false;

Future<void> _pickImages() async {
  try {
    final files = await FilePicker.pickFiles(
      type: FileType.image,
    );

    if (files.isEmpty) {
      return;
    }

    final newImages = <File>[];

    for (final platformFile in files) {
      final path = platformFile.path;

      if (path!.isEmpty) {
        continue;
      }

      final imageFile = File(path);

      if (await imageFile.exists()) {
        newImages.add(imageFile);
      }
    }

    if (newImages.isEmpty) {
      if (!mounted) return;

      await _showAlert(
        title: 'Unable to Select Images',
        message:
            'The selected images could not be accessed.',
        icon: Icons.error_outline,
        iconColor: Colors.red,
      );

      return;
    }

    if (!mounted) return;

    setState(() {
      for (final image in newImages) {
        final alreadyAdded = _selectedImages.any(
          (existing) =>
              existing.path == image.path,
        );

        if (!alreadyAdded) {
          _selectedImages.add(image);
        }
      }
    });
  } catch (e, stackTrace) {
    debugPrint(
      'IMAGE PICKER ERROR: $e',
    );

    debugPrint(
      'IMAGE PICKER STACK TRACE:\n$stackTrace',
    );

    if (!mounted) return;

    await _showAlert(
      title: 'Unable to Select Images',
      message:
          'Something went wrong while selecting the images.',
      icon: Icons.error_outline,
      iconColor: Colors.red,
    );
  }
}

  Future<void> _convertToPdf() async {
    if (_selectedImages.isEmpty) {
      await _showAlert(
        title: 'Select Images',
        message:
            'Please select at least one image before converting.',
        icon: Icons.image_outlined,
        iconColor: Colors.orange,
      );

      return;
    }

    for (final image in _selectedImages) {
      if (!await image.exists()) {
        await _showAlert(
          title: 'Image Not Found',
          message:
              'One of the selected images is no longer available.',
          icon: Icons.error_outline,
          iconColor: Colors.red,
        );

        return;
      }
    }

    FocusScope.of(context).unfocus();

    if (!mounted) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final pdfFile =
          await ImagesToPdfService.convertToPdf(
        images: List<File>.from(
          _selectedImages,
        ),
      );

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      await _showSaveOptions(
        pdfFile,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'IMAGES TO PDF ERROR: $e',
      );

      debugPrint(
        'IMAGES TO PDF STACK TRACE:\n$stackTrace',
      );

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      await _showAlert(
        title: 'Conversion Failed',
        message:
            'Unable to convert the selected images to PDF.\n\n$e',
        icon: Icons.error_outline,
        iconColor: Colors.red,
      );
    }
  }

  Future<void> _showSaveOptions(
    File pdfFile,
  ) async {
    final result =
        await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'PDF Created',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose where you want to save the converted PDF.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        'docera',
                      );
                    },
                    icon: const Icon(
                      Icons.folder_outlined,
                    ),
                    label: const Text(
                      'Save in Docera',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        'device',
                      );
                    },
                    icon: const Icon(
                      Icons.download_outlined,
                    ),
                    label: const Text(
                      'Save to Device',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      'cancel',
                    );
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    if (result == 'docera') {
      await _saveInDocera(pdfFile);
    }

    if (result == 'device') {
      await _saveToDevice(pdfFile);
    }
  }

  Future<void> _saveInDocera(
    File pdfFile,
  ) async {
    try {
      await FileStorageService.saveFile(
        pdfFile,
      );

      if (!mounted) return;

      _reset();

      await _showAlert(
        title: 'PDF Saved',
        message:
            'The PDF has been saved in Docera successfully.',
        icon: Icons.check_circle_outline,
        iconColor: Colors.green,
      );
    } catch (e) {
      debugPrint(
        'SAVE DOCERA ERROR: $e',
      );

      if (!mounted) return;

      await _showAlert(
        title: 'Save Failed',
        message:
            'Unable to save the PDF in Docera.',
        icon: Icons.error_outline,
        iconColor: Colors.red,
      );
    }
  }

  Future<void> _saveToDevice(
    File pdfFile,
  ) async {
    try {
      final bytes =
          await pdfFile.readAsBytes();

      final fileName =
          pdfFile.path.split(
            Platform.pathSeparator,
          ).last;

      final outputUri =
          await FilePicker.saveFile(
        dialogTitle: 'Save PDF',
        fileName: fileName,
        bytes: bytes,
        mimeType: 'application/pdf',
      );

      if (!mounted) return;

      if (outputUri == null) {
        return;
      }

      _reset();

      await _showAlert(
        title: 'PDF Saved',
        message:
            'The PDF has been saved successfully.',
        icon: Icons.check_circle_outline,
        iconColor: Colors.green,
      );
    } catch (e) {
      debugPrint(
        'SAVE DEVICE ERROR: $e',
      );

      if (!mounted) return;

      await _showAlert(
        title: 'Save Failed',
        message:
            'Unable to save the PDF to your device.',
        icon: Icons.error_outline,
        iconColor: Colors.red,
      );
    }
  }

  Future<void> _showAlert({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding:
              const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            12,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: iconColor.withValues(
                    alpha: 0.10,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 38,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeImage(int index) {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _reset() {
    if (!mounted) return;

    setState(() {
      _selectedImages.clear();
    });
  }

  void _moveImage(
    int oldIndex,
    int newIndex,
  ) {
    if (_isProcessing) {
      return;
    }

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final image =
        _selectedImages.removeAt(oldIndex);

    _selectedImages.insert(
      newIndex,
      image,
    );

    setState(() {});
  }

  String _fileName(File file) {
    return file.path.split(
      Platform.pathSeparator,
    ).last;
  }

  Future<String> _fileSize(File file) async {
    final bytes = await file.length();

    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final hasImages =
        _selectedImages.isNotEmpty;

    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Images to PDF',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            18,
            12,
            18,
            18,
          ),
          child: Column(
            children: [
              Expanded(
                child: hasImages
                    ? _SelectedImagesContent(
                        images:
                            _selectedImages,
                        fileName: _fileName,
                        fileSize: _fileSize,
                        onRemove: _removeImage,
                        onChange: _pickImages,
                        onReorder: _moveImage,
                        isProcessing:
                            _isProcessing,
                      )
                    : _EmptyState(
                        onSelectImages:
                            _pickImages,
                      ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed:
                      _isProcessing
                          ? null
                          : hasImages
                              ? _convertToPdf
                              : _pickImages,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          hasImages
                              ? Icons
                                  .picture_as_pdf_outlined
                              : Icons
                                  .photo_library_outlined,
                        ),
                  label: Text(
                    _isProcessing
                        ? 'Creating PDF...'
                        : hasImages
                            ? 'Convert to PDF'
                            : 'Select Images',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
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

class _EmptyState extends StatelessWidget {
  final VoidCallback onSelectImages;

  const _EmptyState({
    required this.onSelectImages,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                size: 46,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Convert Images to PDF',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding:
                  EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Text(
                'Select multiple images and combine them into a single PDF document.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              padding:
                  const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(
                  alpha: 0.08,
                ),
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.blue.withValues(
                    alpha: 0.18,
                  ),
                ),
              ),
              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You can select multiple JPG, JPEG, PNG, and other supported image files.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: onSelectImages,
              icon: const Icon(
                Icons.photo_library_outlined,
              ),
              label: const Text(
                'Choose Images',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedImagesContent
    extends StatelessWidget {
  final List<File> images;
  final String Function(File) fileName;
  final Future<String> Function(File) fileSize;
  final void Function(int) onRemove;
  final VoidCallback onChange;
  final void Function(int, int) onReorder;
  final bool isProcessing;

  const _SelectedImagesContent({
    required this.images,
    required this.fileName,
    required this.fileSize,
    required this.onRemove,
    required this.onChange,
    required this.onReorder,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Selected Images',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${images.length} ${images.length == 1 ? 'image' : 'images'}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Drag images to change their PDF page order.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed:
                isProcessing ? null : onChange,
            icon: const Icon(
              Icons.add_photo_alternate_outlined,
            ),
            label: const Text(
              'Add More Images',
            ),
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ReorderableListView.builder(
            buildDefaultDragHandles: false,
            padding:
                const EdgeInsets.only(
              bottom: 10,
            ),
            itemCount: images.length,
            onReorder: onReorder,
            itemBuilder:
                (context, index) {
              final image = images[index];

              return _ImageItem(
                key: ValueKey(
                  image.path,
                ),
                index: index,
                image: image,
                fileName:
                    fileName(image),
                fileSize:
                    fileSize(image),
                onRemove: () {
                  onRemove(index);
                },
                isProcessing:
                    isProcessing,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ImageItem extends StatelessWidget {
  final int index;
  final File image;
  final String fileName;
  final Future<String> fileSize;
  final VoidCallback onRemove;
  final bool isProcessing;

  const _ImageItem({
    super.key,
    required this.index,
    required this.image,
    required this.fileName,
    required this.fileSize,
    required this.onRemove,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        leading: ClipRRect(
          borderRadius:
              BorderRadius.circular(10),
          child: Image.file(
            image,
            width: 58,
            height: 58,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) {
              return Container(
                width: 58,
                height: 58,
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),
        title: Text(
          fileName,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: FutureBuilder<String>(
          future: fileSize,
          builder:
              (context, snapshot) {
            return Text(
              'Page ${index + 1}'
              '${snapshot.hasData ? ' • ${snapshot.data}' : ''}',
              style: TextStyle(
                fontSize: 12,
                color:
                    Colors.grey.shade600,
              ),
            );
          },
        ),
        trailing: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            ReorderableDragStartListener(
              index: index,
              enabled: !isProcessing,
              child: const Padding(
                padding:
                    EdgeInsets.all(8),
                child: Icon(
                  Icons
                      .drag_indicator_rounded,
                  color: Colors.grey,
                ),
              ),
            ),
            IconButton(
              onPressed:
                  isProcessing
                      ? null
                      : onRemove,
              icon: const Icon(
                Icons.close,
              ),
              tooltip: 'Remove',
            ),
          ],
        ),
      ),
    );
  }
}