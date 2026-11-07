import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../../core/storage/file_storage_service.dart';
import 'services/pdf_to_word_service.dart';

class PdfToWordPage extends StatefulWidget {
  const PdfToWordPage({super.key});

  @override
  State<PdfToWordPage> createState() =>
      _PdfToWordPageState();
}

class _PdfToWordPageState extends State<PdfToWordPage> {
  File? _selectedFile;
  bool _isProcessing = false;

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

    final file = File(path);

    if (!await file.exists()) {
      await _showError(
        'The selected PDF could not be found.',
      );
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedFile = file;
    });
  }

  Future<void> _convertPdf() async {
    final file = _selectedFile;

    if (file == null) {
      await _showError(
        'Please select a PDF file first.',
      );
      return;
    }

    if (!await file.exists()) {
      await _showError(
        'The selected PDF could not be found.',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final convertedFile =
          await PdfToWordService.convertToWord(
        inputFile: file,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      await _showSaveOptions(
        convertedFile,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      await _showError(
        _cleanError(e),
      );
    }
  }

  Future<void> _showSaveOptions(
    File convertedFile,
  ) async {
    final result = await showModalBottomSheet<String>(
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
                const Icon(
                  Icons.check_circle_outline,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Word Document Created',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _fileName(convertedFile),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
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
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
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
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || result == null || result == 'cancel') {
      return;
    }

    if (result == 'docera') {
      await _saveInDocera(convertedFile);
    } else if (result == 'device') {
      await _saveToDevice(convertedFile);
    }
  }

  Future<void> _saveInDocera(
    File convertedFile,
  ) async {
    try {
      await FileStorageService.saveFile(
        convertedFile,
      );

      if (!mounted) {
        return;
      }

      await _showSuccess(
        'The Word document has been saved in Docera.',
      );

      _reset();
    } catch (_) {
      if (!mounted) {
        return;
      }

      await _showError(
        'Failed to save the Word document in Docera.',
      );
    }
  }

  Future<void> _saveToDevice(
    File convertedFile,
  ) async {
    try {
      final bytes = await convertedFile.readAsBytes();

      final destination = await FilePicker.saveFile(
        dialogTitle: 'Save Word Document',
        fileName: _fileName(convertedFile),
        bytes: bytes,
      );

      if (!mounted) {
        return;
      }

      if (destination == null) {
        return;
      }

      await _showSuccess(
        'The Word document has been saved to your device.',
      );

      _reset();
    } catch (_) {
      if (!mounted) {
        return;
      }

      await _showError(
        'Failed to save the Word document to your device.',
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
          title: const Text(
            'Something went wrong',
          ),
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
            FilledButton(
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

  String _cleanError(
    Object error,
  ) {
    return error
        .toString()
        .replaceFirst('Exception: ', '');
  }

  String _fileName(File file) {
    return file.path
        .split(Platform.pathSeparator)
        .last;
  }

  String _fileSize(File file) {
    final size = file.lengthSync();

    if (size < 1024) {
      return '$size B';
    }

    if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    }

    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  void _reset() {
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedFile = null;
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final file = _selectedFile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF to Word'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: file == null
                    ? _buildEmptyState()
                    : _buildSelectedFile(file),
              ),
              if (file != null)
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
                            Icons.description_outlined,
                          ),
                    label: Text(
                      _isProcessing
                          ? 'Converting...'
                          : 'Convert to Word',
                    ),
                  ),
                ),
              if (file != null)
                const SizedBox(height: 12),
              if (file != null)
                TextButton(
                  onPressed: _isProcessing
                      ? null
                      : _pickPdf,
                  child: const Text(
                    'Choose Another PDF',
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                'Conversion happens offline on your device.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(24),
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
              ),
              child: const Icon(
                Icons.picture_as_pdf_outlined,
                size: 42,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Convert PDF to Word',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Convert your PDF into an editable Word document.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed:
                  _isProcessing ? null : _pickPdf,
              icon: const Icon(
                Icons.upload_file_outlined,
              ),
              label: const Text('Select PDF'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFile(
    File file,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(18),
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_outlined,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _fileName(file),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _fileSize(file),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
                const SizedBox(height: 16),
                IconButton(
                  onPressed: _isProcessing
                      ? null
                      : _removeFile,
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                  tooltip: 'Remove PDF',
                ),
              ],
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
                  Icons.info_outline,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Text, images, tables and multiple pages are converted when supported by the PDF.',
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