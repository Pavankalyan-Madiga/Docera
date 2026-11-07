import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'services/pdf_to_images_service.dart';
import '../../../../../../core/storage/file_storage_service.dart';

class PdfToImagesPage extends StatefulWidget {
  const PdfToImagesPage({
    super.key,
  });

  @override
  State<PdfToImagesPage> createState() =>
      _PdfToImagesPageState();
}

class _PdfToImagesPageState
    extends State<PdfToImagesPage> {
  File? _selectedFile;

  bool _isProcessing = false;

  List<File> _convertedImages = [];

  Future<void> _pickPdf() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (files.isEmpty) {
      return;
    }

    final path = files.first.path;

    if (path!.isEmpty) {
      return;
    }

    setState(() {
      _selectedFile = File(path);
      _convertedImages = [];
    });
  }

  Future<void> _convertPdf() async {
    if (_selectedFile == null) {
      await _showError(
        'Please select a PDF file first.',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final images =
          await PdfToImagesService.convertToImages(
        inputFile: _selectedFile!,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _convertedImages = images;
      });

      await _showSaveOptions();
    } catch (e) {
      if (!mounted) {
        return;
      }

      await _showError(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _showSaveOptions() async {
    if (_convertedImages.isEmpty) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Images Created',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_convertedImages.length} image'
                  '${_convertedImages.length == 1 ? '' : 's'} '
                  'created successfully.',
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _saveInDocera();
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
                    onPressed: () async {
                      Navigator.pop(context);
                      await _saveToDevice();
                    },
                    icon: const Icon(
                      Icons.download_outlined,
                    ),
                    label: const Text(
                      'Save to Device',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveInDocera() async {
    try {
      for (final image in _convertedImages) {
        await FileStorageService.saveFile(image);
      }

      if (!mounted) {
        return;
      }

      await _showSuccess(
        '${_convertedImages.length} image'
        '${_convertedImages.length == 1 ? '' : 's'} '
        'saved in Docera.',
      );

      _reset();
    } catch (e) {
      if (!mounted) {
        return;
      }

      await _showError(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  Future<void> _saveToDevice() async {
    try {
      final directory =
          await FilePicker.getDirectoryPath(
        dialogTitle: 'Select folder',
      );

      if (directory == null ||
          directory.isEmpty) {
        return;
      }

      for (final image in _convertedImages) {
        final destination = File(
          '$directory/'
          '${image.path.split(Platform.pathSeparator).last}',
        );

        await image.copy(
          destination.path,
        );
      }

      if (!mounted) {
        return;
      }

      await _showSuccess(
        '${_convertedImages.length} image'
        '${_convertedImages.length == 1 ? '' : 's'} '
        'saved successfully.',
      );

      _reset();
    } catch (e) {
      if (!mounted) {
        return;
      }

      await _showError(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  Future<void> _showError(
    String message,
  ) async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSuccess(
    String message,
  ) async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _reset() {
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedFile = null;
      _convertedImages = [];
    });
  }

  String _fileName() {
    if (_selectedFile == null) {
      return '';
    }

    return _selectedFile!.path
        .split(Platform.pathSeparator)
        .last;
  }

  Future<void> _removeFile() async {
    setState(() {
      _selectedFile = null;
      _convertedImages = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PDF to Images',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Convert PDF to Images',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Convert every PDF page into a high-quality PNG image.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _selectedFile == null
                    ? _buildEmptyState()
                    : _buildSelectedFile(),
              ),
              const SizedBox(height: 16),
              if (_selectedFile != null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        _isProcessing
                            ? null
                            : _convertPdf,
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.image_outlined,
                          ),
                    label: Text(
                      _isProcessing
                          ? 'Converting...'
                          : 'Convert to Images',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf_outlined,
            size: 64,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Select a PDF file',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Each page will be converted into a PNG image.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _pickPdf,
            icon: const Icon(
              Icons.upload_file_outlined,
            ),
            label: const Text(
              'Select PDF',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFile() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(12),
                    color: Theme.of(context)
                        .colorScheme
                        .errorContainer,
                  ),
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: Theme.of(context)
                        .colorScheme
                        .onErrorContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _fileName(),
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed:
                      _isProcessing
                          ? null
                          : _removeFile,
                  icon: const Icon(
                    Icons.close,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed:
                _isProcessing
                    ? null
                    : _pickPdf,
            icon: const Icon(
              Icons.swap_horiz,
            ),
            label: const Text(
              'Choose Another PDF',
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(16),
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
            ),
            child: const Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.offline_bolt_outlined,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Conversion happens locally on your device. '
                    'Your PDF does not need to be uploaded.',
                  ),
                ),
              ],
            ),
          ),
          if (_convertedImages.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              '${_convertedImages.length} images ready',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}