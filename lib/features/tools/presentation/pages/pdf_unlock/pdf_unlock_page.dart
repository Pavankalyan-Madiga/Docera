import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../../core/storage/file_storage_service.dart';
import 'services/pdf_unlock_service.dart';

class PdfUnlockPage extends StatefulWidget {
  const PdfUnlockPage({
    super.key,
  });

  @override
  State<PdfUnlockPage> createState() =>
      _PdfUnlockPageState();
}

class _PdfUnlockPageState
    extends State<PdfUnlockPage> {
  File? _selectedFile;

  final TextEditingController _passwordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _isProcessing = false;

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) {
        return;
      }

      final path = result.path;

      if (path == null || path.isEmpty) {
        _showAlert(
          title: 'Unable to Select PDF',
          message: 'Unable to access the selected PDF.',
          icon: Icons.error_outline,
          iconColor: Colors.red,
        );
        return;
      }

      final file = File(path);

      if (!await file.exists()) {
        _showAlert(
          title: 'File Not Found',
          message: 'The selected PDF could not be found.',
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
        'PDF PICKER ERROR: $e',
      );

      _showAlert(
        title: 'Unable to Select PDF',
        message: 'Something went wrong while selecting the PDF.',
        icon: Icons.error_outline,
        iconColor: Colors.red,
      );
    }
  }

  Future<void> _unlockPdf() async {
    final file = _selectedFile;

    if (file == null) {
      _showAlert(
        title: 'Select PDF',
        message: 'Please select a PDF first.',
        icon: Icons.picture_as_pdf_outlined,
        iconColor: Colors.orange,
      );
      return;
    }

    final password =
        _passwordController.text.trim();

    if (password.isEmpty) {
      _showAlert(
        title: 'Password Required',
        message: 'Please enter the PDF password.',
        icon: Icons.lock_outline,
        iconColor: Colors.orange,
      );
      return;
    }

    if (!await file.exists()) {
      _showAlert(
        title: 'File Not Found',
        message: 'The selected PDF is no longer available.',
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
      final unlockedFile =
          await PdfUnlockService.unlockPdf(
        inputFile: file,
        password: password,
      );

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      await _showSaveOptions(
        unlockedFile,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'PDF UNLOCK ERROR: $e',
      );

      debugPrint(
        'PDF UNLOCK STACK TRACE:\n$stackTrace',
      );

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      await _showAlert(
        title: 'Wrong Password',
        message:
            'The password you entered is incorrect. '
            'Please enter the correct password and try again.',
        icon: Icons.lock_outline,
        iconColor: Colors.red,
      );
    }
  }

  Future<void> _showSaveOptions(
    File unlockedFile,
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
                  'PDF Unlocked',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose where you want to save the unlocked PDF.',
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
      await _saveInDocera(
        unlockedFile,
      );
    } else if (result == 'device') {
      await _saveToDevice(
        unlockedFile,
      );
    }
  }

  Future<void> _saveInDocera(
    File unlockedFile,
  ) async {
    try {
      final savedFile =
          await FileStorageService.saveFile(
        unlockedFile,
      );

      if (!mounted) return;

      _reset();

      await _showAlert(
        title: 'PDF Saved',
        message:
            'The unlocked PDF has been saved in Docera.',
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
            'Unable to save the unlocked PDF in Docera.',
        icon: Icons.error_outline,
        iconColor: Colors.red,
      );
    }
  }

  Future<void> _saveToDevice(
    File unlockedFile,
  ) async {
    try {
      final bytes =
          await unlockedFile.readAsBytes();

      final fileName =
          unlockedFile.path.split('/').last;

      final outputUri =
          await FilePicker.saveFile(
        dialogTitle: 'Save Unlocked PDF',
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
            'The unlocked PDF has been saved successfully.',
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
            'Unable to save the unlocked PDF to your device.',
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
          contentPadding: const EdgeInsets.fromLTRB(
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
      _passwordController.clear();
    });
  }

  void _removeFile() {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _selectedFile = null;
      _passwordController.clear();
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
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Unlock PDF',
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
              Expanded(
                child: _selectedFile == null
                    ? _EmptyState(
                        onSelectPdf: _pickPdf,
                      )
                    : _UnlockContent(
                        fileName: _fileName(),
                        fileSize: _fileSize,
                        passwordController:
                            _passwordController,
                        obscurePassword:
                            _obscurePassword,
                        onTogglePassword: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                        onRemove: _removeFile,
                      ),
              ),
              const SizedBox(height: 16),
              if (_selectedFile == null)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: _pickPdf,
                    icon: const Icon(
                      Icons.picture_as_pdf_outlined,
                    ),
                    label: const Text(
                      'Select PDF',
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
                        _isProcessing
                            ? null
                            : _unlockPdf,
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
                        : const Icon(
                            Icons.lock_open_outlined,
                          ),
                    label: Text(
                      _isProcessing
                          ? 'Unlocking PDF...'
                          : 'Remove Password',
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

class _EmptyState extends StatelessWidget {
  final VoidCallback onSelectPdf;

  const _EmptyState({
    required this.onSelectPdf,
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
                Icons.lock_open_outlined,
                size: 46,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Unlock Your PDF',
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
                'Remove password protection from a PDF using its current password.',
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
              onPressed: onSelectPdf,
              icon: const Icon(
                Icons.picture_as_pdf_outlined,
              ),
              label: const Text(
                'Choose PDF',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnlockContent extends StatelessWidget {
  final String fileName;
  final Future<String> Function() fileSize;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onRemove;

  const _UnlockContent({
    required this.fileName,
    required this.fileSize,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
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
                    color: Colors.red
                        .withValues(alpha: 0.10),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red,
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
                  tooltip: 'Remove PDF',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'PDF Password',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the current password to remove password protection.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            textInputAction:
                TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter current PDF password',
              prefixIcon: const Icon(
                Icons.lock_outline,
              ),
              suffixIcon: IconButton(
                onPressed: onTogglePassword,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange
                  .withValues(alpha: 0.08),
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color: Colors.orange
                    .withValues(alpha: 0.20),
              ),
            ),
            child: const Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.orange,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You must provide the correct PDF password. '
                    'Docera cannot bypass or recover an unknown password.',
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