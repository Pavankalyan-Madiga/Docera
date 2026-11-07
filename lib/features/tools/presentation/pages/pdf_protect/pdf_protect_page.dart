import 'dart:io';

import 'package:docera/features/tools/presentation/pages/pdf_protect/service/pdf_protect_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../../core/storage/file_storage_service.dart';

class PdfProtectPage extends StatefulWidget {
  const PdfProtectPage({
    super.key,
  });

  @override
  State<PdfProtectPage> createState() =>
      _PdfProtectPageState();
}

class _PdfProtectPageState
    extends State<PdfProtectPage> {
  File? _selectedFile;

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController
      _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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
        _showMessage(
          'Unable to access selected PDF',
        );
        return;
      }

      final file = File(path);

      if (!await file.exists()) {
        _showMessage(
          'Selected PDF could not be found',
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

      _showMessage(
        'Unable to select PDF: $e',
      );
    }
  }

  Future<void> _protectPdf() async {
    final file = _selectedFile;

    if (file == null) {
      _showMessage(
        'Please select a PDF first',
      );
      return;
    }

    final password =
        _passwordController.text.trim();

    final confirmPassword =
        _confirmPasswordController.text.trim();

    if (password.isEmpty) {
      _showMessage(
        'Please enter a password',
      );
      return;
    }

    if (password.length < 4) {
      _showMessage(
        'Password must contain at least 4 characters',
      );
      return;
    }

    if (confirmPassword.isEmpty) {
      _showMessage(
        'Please confirm your password',
      );
      return;
    }

    if (password != confirmPassword) {
      _showMessage(
        'Passwords do not match',
      );
      return;
    }

    if (!await file.exists()) {
      _showMessage(
        'Selected PDF is no longer available',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isProcessing = true;
    });

    try {
      final protectedFile =
          await PdfProtectService.protectPdf(
        inputFile: file,
        password: password,
      );

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      await _showSaveOptions(
        protectedFile,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'PDF PROTECT ERROR: $e',
      );

      debugPrint(
        'PDF PROTECT STACK TRACE:\n$stackTrace',
      );

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      _showMessage(
        'Failed to protect PDF: $e',
      );
    }
  }

  Future<void> _showSaveOptions(
    File protectedFile,
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
                  'PDF Protected',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose where you want to save the protected PDF.',
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
        protectedFile,
      );
    } else if (result == 'device') {
      await _saveToDevice(
        protectedFile,
      );
    }
  }

  Future<void> _saveInDocera(
    File protectedFile,
  ) async {
    try {
      final savedFile =
          await FileStorageService.saveFile(
        protectedFile,
      );

      if (!mounted) return;

      _showSuccess(
        'Saved in Docera: ${savedFile.name}',
      );

      _reset();
    } catch (e) {
      debugPrint(
        'SAVE DOCERA ERROR: $e',
      );

      _showMessage(
        'Unable to save in Docera: $e',
      );
    }
  }

  Future<void> _saveToDevice(
    File protectedFile,
  ) async {
    try {
      final bytes =
          await protectedFile.readAsBytes();

      final fileName =
          protectedFile.path.split('/').last;

      final outputUri =
          await FilePicker.saveFile(
        dialogTitle: 'Save Protected PDF',
        fileName: fileName,
        bytes: bytes,
        mimeType: 'application/pdf',
      );

      if (!mounted) return;

      if (outputUri == null) {
        return;
      }

      _showSuccess(
        'Protected PDF saved successfully',
      );

      _reset();
    } catch (e) {
      debugPrint(
        'SAVE DEVICE ERROR: $e',
      );

      _showMessage(
        'Unable to save PDF: $e',
      );
    }
  }

  void _reset() {
    if (!mounted) return;

    setState(() {
      _selectedFile = null;
      _passwordController.clear();
      _confirmPasswordController.clear();
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

  void _showMessage(
    String message,
  ) {
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

  void _showSuccess(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(
            seconds: 3,
          ),
        ),
      );
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
    _confirmPasswordController.dispose();
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
          'PDF Protect',
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
                    : _ProtectContent(
                        file: _selectedFile!,
                        fileName: _fileName(),
                        fileSize: _fileSize,
                        passwordController:
                            _passwordController,
                        confirmPasswordController:
                            _confirmPasswordController,
                        obscurePassword:
                            _obscurePassword,
                        obscureConfirmPassword:
                            _obscureConfirmPassword,
                        onTogglePassword: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                        onToggleConfirmPassword: () {
                          setState(() {
                            _obscureConfirmPassword =
                                !_obscureConfirmPassword;
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
                            : _protectPdf,
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
                            Icons.lock_outline,
                          ),
                    label: Text(
                      _isProcessing
                          ? 'Protecting PDF...'
                          : 'Protect PDF',
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
                Icons.lock_outline,
                size: 46,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Protect Your PDF',
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
                'Add password protection to your PDF and keep your document secure.',
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

class _ProtectContent extends StatelessWidget {
  final File file;
  final String fileName;
  final Future<String> Function() fileSize;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final VoidCallback onRemove;

  const _ProtectContent({
    required this.file,
    required this.fileName,
    required this.fileSize,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
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
          const SizedBox(height: 20),
          const Text(
            'Set Password',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The password will be required to open the protected PDF.',
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
                TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter password',
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
          const SizedBox(height: 14),
          TextField(
            controller:
                confirmPasswordController,
            obscureText:
                obscureConfirmPassword,
            textInputAction:
                TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Re-enter password',
              prefixIcon: const Icon(
                Icons.lock_reset_outlined,
              ),
              suffixIcon: IconButton(
                onPressed:
                    onToggleConfirmPassword,
                icon: Icon(
                  obscureConfirmPassword
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
                  Icons.verified_user_outlined,
                  size: 20,
                  color: Colors.green,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your PDF will be encrypted using AES-256 protection. '
                    'Keep your password safe because Docera cannot recover it.',
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