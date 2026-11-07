import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'translation_page.dart';

class OcrResultPage extends StatefulWidget {
  final File imageFile;
  final String extractedText;

  const OcrResultPage({
    super.key,
    required this.imageFile,
    required this.extractedText,
  });

  @override
  State<OcrResultPage> createState() =>
      _OcrResultPageState();
}

class _OcrResultPageState
    extends State<OcrResultPage> {
  late final TextEditingController
      _textController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    _textController =
        TextEditingController(
      text: widget.extractedText,
    );
  }

  Future<void> _copyText() async {
    await Clipboard.setData(
      ClipboardData(
        text: _textController.text,
      ),
    );

    if (!mounted) return;

    _showMessage(
      'Text copied to clipboard',
    );
  }

  Future<void> _shareText() async {
    final text =
        _textController.text.trim();

    if (text.isEmpty) {
      _showMessage(
        'There is no text to share',
      );
      return;
    }

    await SharePlus.instance.share(
      ShareParams(
        text: text,
        title: 'OCR Text',
      ),
    );
  }

  Future<void> _openTranslation() async {
    final text =
        _textController.text.trim();

    if (text.isEmpty) {
      _showMessage(
        'There is no text to translate',
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TranslationPage(
          text: text,
        ),
      ),
    );
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _clearText() {
    _textController.clear();

    setState(() {
      _isEditing = true;
    });
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context);

    final hasText =
        _textController.text
            .trim()
            .isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OCR Result',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
                _toggleEditing,
            tooltip:
                _isEditing
                    ? 'Done'
                    : 'Edit',
            icon: Icon(
              _isEditing
                  ? Icons.check
                  : Icons.edit_outlined,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                18,
                8,
                18,
                14,
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius
                              .circular(14),
                      border: Border.all(
                        color: theme
                            .dividerColor,
                      ),
                    ),
                    clipBehavior:
                        Clip.antiAlias,
                    child: Image.file(
                      widget.imageFile,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          'Recognized Text',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Review and edit the extracted text',
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 18,
                ),
                child: Container(
                  width:
                      double.infinity,
                  decoration:
                      BoxDecoration(
                    color: theme
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(
                          alpha: 0.35,
                        ),
                    borderRadius:
                        BorderRadius
                            .circular(18),
                    border: Border.all(
                      color: theme
                          .dividerColor
                          .withValues(
                            alpha: 0.6,
                          ),
                    ),
                  ),
                  padding:
                      const EdgeInsets
                          .all(16),
                  child: TextField(
                    controller:
                        _textController,
                    readOnly:
                        !_isEditing,
                    maxLines: null,
                    expands: true,
                    textAlignVertical:
                        TextAlignVertical
                            .top,
                    style:
                        const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                    ),
                    decoration:
                        InputDecoration(
                      border:
                          InputBorder.none,
                      hintText:
                          'No text detected',
                      hintStyle:
                          TextStyle(
                        color: Colors
                            .grey
                            .shade500,
                      ),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets
                      .fromLTRB(
                18,
                14,
                18,
                18,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child:
                            _ActionButton(
                          icon: Icons
                              .copy_outlined,
                          label: 'Copy',
                          onPressed:
                              hasText
                                  ? _copyText
                                  : null,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child:
                            _ActionButton(
                          icon: Icons
                              .share_outlined,
                          label: 'Share',
                          onPressed:
                              hasText
                                  ? _shareText
                                  : null,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child:
                            _ActionButton(
                          icon: Icons
                              .translate_outlined,
                          label:
                              'Translate',
                          onPressed:
                              hasText
                                  ? _openTranslation
                                  : null,
                          highlighted:
                              true,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child:
                            _ActionButton(
                          icon: Icons
                              .delete_outline,
                          label: 'Clear',
                          onPressed:
                              hasText
                                  ? _clearText
                                  : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  SizedBox(
                    width:
                        double.infinity,
                    height: 52,
                    child:
                        FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(
                          context,
                        );
                      },
                      icon: const Icon(
                        Icons.check,
                      ),
                      label:
                          const Text(
                        'Done',
                        style:
                            TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),
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
}

class _ActionButton
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool highlighted;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context);

    final backgroundColor =
        highlighted
            ? theme
                .colorScheme
                .primary
                .withValues(
                  alpha: 0.12,
                )
            : Colors.transparent;

    final foregroundColor =
        highlighted
            ? theme
                .colorScheme
                .primary
            : theme
                .colorScheme
                .primary;

    return SizedBox(
      height: 58,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style:
            OutlinedButton.styleFrom(
          backgroundColor:
              backgroundColor,
          padding:
              const EdgeInsets
                  .symmetric(
            horizontal: 6,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              30,
            ),
          ),
        ),
        icon: Icon(
          icon,
          size: 20,
          color: foregroundColor,
        ),
        label: Text(
          label,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: foregroundColor,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),
    );
  }
}