import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'ocr_result_page.dart';
import 'services/ocr_service.dart';

class OcrPage extends StatefulWidget {
  const OcrPage({
    super.key,
  });

  @override
  State<OcrPage> createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  final OcrService _ocrService = OcrService();

  File? _selectedImage;
  bool _isProcessing = false;

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.pickFile(
        type: FileType.image,
      );

      if (result == null) {
        return;
      }

      final path = result.path;

      if (path == null || path.isEmpty) {
        _showError(
          'Unable to access selected image',
        );
        return;
      }

      final file = File(path);

      if (!await file.exists()) {
        _showError(
          'Selected image could not be found',
        );
        return;
      }

      setState(() {
        _selectedImage = file;
      });
    } catch (e) {
      debugPrint(
        'OCR FILE PICKER ERROR: $e',
      );

      if (!mounted) return;

      _showError(
        'Unable to select image: $e',
      );
    }
  }

  Future<void> _runOcr() async {
    final image = _selectedImage;

    if (image == null) {
      _showError(
        'Please select an image first',
      );
      return;
    }

    if (!await image.exists()) {
      _showError(
        'Selected image is no longer available',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      debugPrint(
        'Starting OCR for: ${image.path}',
      );

      final text = await _ocrService.recognizeText(
        image,
      );

      debugPrint(
        'OCR result length: ${text.length}',
      );

      debugPrint(
        'OCR result:\n$text',
      );

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      if (text.trim().isEmpty) {
        _showError(
          'No text was detected in this image',
        );
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OcrResultPage(
            imageFile: image,
            extractedText: text,
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        'OCR ERROR: $e',
      );

      debugPrint(
        'OCR STACK TRACE:\n$stackTrace',
      );

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      _showError(
        'OCR failed: $e',
      );
    }
  }

  void _removeImage() {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _selectedImage = null;
    });
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'OCR',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.colorScheme.primary
                        .withValues(alpha: 0.20),
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Currently, OCR detects English text only. '
                        'Support for more languages will be added in a future update.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _selectedImage == null
                    ? _EmptyOcrState(
                        onSelectImage: _pickImage,
                      )
                    : _ImagePreview(
                        imageFile: _selectedImage!,
                        onRemove: _removeImage,
                      ),
              ),
              const SizedBox(height: 16),
              if (_selectedImage == null)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(
                      Icons.add_photo_alternate_outlined,
                    ),
                    label: const Text(
                      'Select Image',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed:
                        _isProcessing ? null : _runOcr,
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.text_fields,
                          ),
                    label: Text(
                      _isProcessing
                          ? 'Extracting Text...'
                          : 'Extract Text',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

class _EmptyOcrState extends StatelessWidget {
  final VoidCallback onSelectImage;

  const _EmptyOcrState({
    required this.onSelectImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                Icons.document_scanner_outlined,
                size: 46,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Extract Text from Images',
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
                'Select a document image from your device to extract its text.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: onSelectImage,
              icon: const Icon(
                Icons.add_photo_alternate_outlined,
              ),
              label: const Text(
                'Choose Image',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final File imageFile;
  final VoidCallback onRemove;

  const _ImagePreview({
    required this.imageFile,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(
            alpha: 0.5,
          ),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Image.file(
                imageFile,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Material(
              color: Colors.black.withValues(
                alpha: 0.6,
              ),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(9),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}