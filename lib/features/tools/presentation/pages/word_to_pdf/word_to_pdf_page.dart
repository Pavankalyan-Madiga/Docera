import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../../core/storage/file_storage_service.dart';
import 'services/word_to_pdf_service.dart';

class WordToPdfPage extends StatefulWidget {
  const WordToPdfPage({
    super.key,
  });

  @override
  State<WordToPdfPage> createState() =>
      _WordToPdfPageState();
}

class _WordToPdfPageState
    extends State<WordToPdfPage> {
  File? _selectedFile;
  bool _isProcessing = false;

  Future<void> _pickWordFile() async {
    try {
      final result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['docx'],
      );

      if (result == null) {
        return;
      }

      final path = result.path;

      if (path == null || path.isEmpty) {
        await _showAlert(
          title: 'Unable to Select File',
          message:
              'Unable to access the selected Word document.',
          icon: Icons.error_outline,
          iconColor: Colors.red,
        );
        return;
      }

      final file = File(path);

      if (!await file.exists()) {
        await _showAlert(
          title: 'File Not Found',
          message:
              'The selected Word document could not be found.',
          icon: Icons.error_outline,
          iconColor: Colors.red,
        );
        return;
      }

      setState(() {
        _selectedFile = file;
      });
    } catch (e) {
      debugPrint(
        'WORD FILE PICKER ERROR: $e',
      );

      if (!mounted) return;

      await _showAlert(
        title: 'Unable to Select File',
        message:
            'Something went wrong while selecting the Word document.',
        icon: Icons.error_outline,
        iconColor: Colors.red,
      );
    }
  }

  Future<void> _convertToPdf() async {
    final file = _selectedFile;

    if (file == null) {
      await _showAlert(
        title: 'Select Word File',
        message:
            'Please select a Word document first.',
        icon: Icons.description_outlined,
        iconColor: Colors.orange,
      );
      return;
    }

    if (!await file.exists()) {
      await _showAlert(
        title: 'File Not Found',
        message:
            'The selected Word document is no longer available.',
        icon: Icons.error_outline,
        iconColor: Colors.red,
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isProcessing = true;
    });

    try {
      final pdfFile =
          await WordToPdfService.convertToPdf(
        inputFile: file,
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
        'WORD TO PDF ERROR: $e',
      );

      debugPrint(
        'WORD TO PDF STACK TRACE:\n$stackTrace',
      );

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      await _showAlert(
        title: 'Conversion Failed',
        message:
            'Unable to convert this Word document to PDF. '
            'Please make sure the document is a valid .docx file.',
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
            'The converted PDF has been saved in Docera.',
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
            'Unable to save the converted PDF in Docera.',
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
          pdfFile.path.split('/').last;

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
            'The converted PDF has been saved successfully.',
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
            'Unable to save the converted PDF to your device.',
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

  void _reset() {
    if (!mounted) return;

    setState(() {
      _selectedFile = null;
    });
  }

  void _removeFile() {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _selectedFile = null;
    });
  }

  String _fileName() {
    final file = _selectedFile;

    if (file == null) {
      return '';
    }

    return file.path.split('/').last;
  }

  Future<String> _fileSize() async {
    final file = _selectedFile;

    if (file == null) {
      return '';
    }

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Word to PDF',
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
                child: _selectedFile == null
                    ? _EmptyState(
                        onSelectFile:
                            _pickWordFile,
                      )
                    : _WordContent(
                        fileName: _fileName(),
                        fileSize: _fileSize,
                        onRemove: _removeFile,
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
                          : _selectedFile == null
                              ? _pickWordFile
                              : _convertToPdf,
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
                          _selectedFile == null
                              ? Icons.description_outlined
                              : Icons
                                  .picture_as_pdf_outlined,
                        ),
                  label: Text(
                    _isProcessing
                        ? 'Converting...'
                        : _selectedFile == null
                            ? 'Select Word File'
                            : 'Convert to PDF',
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
  final VoidCallback onSelectFile;

  const _EmptyState({
    required this.onSelectFile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                color: theme.colorScheme.primary
                    .withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description_outlined,
                size: 46,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Convert Word to PDF',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Text(
                'Convert your Word document into a PDF directly on your device.',
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
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.blue
                    .withValues(alpha: 0.08),
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.blue
                      .withValues(alpha: 0.18),
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
                      'Currently supports .docx Word documents.',
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
              onPressed: onSelectFile,
              icon: const Icon(
                Icons.description_outlined,
              ),
              label: const Text(
                'Choose Word File',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordContent extends StatelessWidget {
  final String fileName;
  final Future<String> Function() fileSize;
  final VoidCallback onRemove;

  const _WordContent({
    required this.fileName,
    required this.fileSize,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary
                  .withValues(alpha: 0.07),
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color: theme.colorScheme.primary
                    .withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.blue
                        .withValues(alpha: 0.10),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description,
                    color: Colors.blue,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      FutureBuilder<String>(
                        future: fileSize(),
                        builder:
                            (context, snapshot) {
                          return Text(
                            snapshot.data ??
                                'Calculating size...',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors
                                  .grey
                                  .shade600,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(
                    Icons.close,
                  ),
                  tooltip: 'Remove file',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Word Document',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your document will be converted to PDF while preserving supported Word formatting.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green
                  .withValues(alpha: 0.08),
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color: Colors.green
                    .withValues(alpha: 0.20),
              ),
            ),
            child: const Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.offline_bolt_outlined,
                  size: 20,
                  color: Colors.green,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Conversion happens on your device. Your Word document is not uploaded to a server.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                    ),
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