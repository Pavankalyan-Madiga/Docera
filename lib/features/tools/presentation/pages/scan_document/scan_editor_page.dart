import 'dart:io';

import 'package:flutter/material.dart';

import 'services/scan_image_service.dart';
import 'services/scan_pdf_service.dart';

class ScanEditorPage extends StatefulWidget {
  const ScanEditorPage({
    super.key,
    required this.pages,
    this.initialIndex = 0,
  });

  final List<File> pages;
  final int initialIndex;

  @override
  State<ScanEditorPage> createState() =>
      _ScanEditorPageState();
}

class _ScanEditorPageState
    extends State<ScanEditorPage> {
  late List<File> _pages;
  late int _currentIndex;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    _pages =
        List<File>.from(widget.pages);

    _currentIndex =
        widget.initialIndex.clamp(
      0,
      _pages.length - 1,
    );
  }

  File get _currentPage =>
      _pages[_currentIndex];

  Future<void> _rotate() async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final rotated =
          await ScanImageService.rotateImage(
        _currentPage,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _pages[_currentIndex] =
            rotated;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to rotate image.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _enhance() async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final enhanced =
          await ScanImageService.enhanceImage(
        _currentPage,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _pages[_currentIndex] =
            enhanced;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to enhance image.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _createPdf() async {
    if (_pages.isEmpty) {
      _showMessage(
        'No scanned pages available.',
      );
      return;
    }

    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final pdfFile =
          await ScanPdfService.createPdf(
        _pages,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      await _showSaveDialog(
        pdfFile,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      _showMessage(
        'Unable to create PDF.',
      );
    }
  }

  Future<void> _showSaveDialog(
    File pdfFile,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor:
          Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              20,
            ),
            decoration:
                const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration:
                      BoxDecoration(
                    color: const Color(
                      0xFFD9DCE5,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Save PDF',
                  style: TextStyle(
                    color: Color(
                      0xFF101631,
                    ),
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                const Text(
                  'Choose where you want to save your PDF.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: Color(
                      0xFF737A90,
                    ),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                _SaveOption(
                  icon:
                      Icons.folder_rounded,
                  title:
                      'Save in Docera',
                  subtitle:
                      'Available in My Files and Recent Files',
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pop();

                    _saveInDocera(
                      pdfFile,
                    );
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                _SaveOption(
                  icon: Icons
                      .phone_android_rounded,
                  title:
                      'Save to Device',
                  subtitle:
                      'Choose a location on your device',
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pop();

                    _saveToDevice(
                      pdfFile,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveInDocera(
    File pdfFile,
  ) async {
    try {
      await ScanPdfService.saveInDocera(
        pdfFile,
      );

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'PDF Saved',
            ),
            content: const Text(
              'Your PDF has been saved in Docera.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pop();
                },
                child: const Text(
                  'OK',
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(
        _pages,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Failed to save PDF in Docera.',
      );
    }
  }

  Future<void> _saveToDevice(
    File pdfFile,
  ) async {
    try {
      final saved =
          await ScanPdfService.saveToDevice(
        pdfFile,
      );

      if (!mounted) {
        return;
      }

      if (!saved) {
        _showMessage(
          'Save cancelled.',
        );
        return;
      }

      _showMessage(
        'PDF saved successfully to your device.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Save failed: $e',
      );
    }
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
        ),
      );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (_pages.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit Scan',
          ),
        ),
        body: const Center(
          child: Text(
            'No pages available.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor:
            Colors.white,
        elevation: 0,
        foregroundColor:
            const Color(0xFF101631),
        title: const Text(
          'Edit Scan',
          style: TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Container(
                  width:
                      double.infinity,
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                    border: Border.all(
                      color: const Color(
                        0xFFE8EAF0,
                      ),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                    child:
                        InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4,
                      child:
                          Image.file(
                        _currentPage,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_isProcessing)
              const Padding(
                padding:
                    EdgeInsets.only(
                  bottom: 12,
                ),
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(
                    0xFF146CE8,
                  ),
                ),
              ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child:
                        _EditorAction(
                      icon: Icons
                          .rotate_right_rounded,
                      label: 'Rotate',
                      onTap: _rotate,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child:
                        _EditorAction(
                      icon: Icons
                          .auto_fix_high_rounded,
                      label: 'Enhance',
                      onTap: _enhance,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            SizedBox(
              height: 82,
              child:
                  ListView.separated(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 16,
                ),
                scrollDirection:
                    Axis.horizontal,
                itemCount:
                    _pages.length,
                separatorBuilder:
                    (
                  context,
                  index,
                ) {
                  return const SizedBox(
                    width: 10,
                  );
                },
                itemBuilder:
                    (
                  context,
                  index,
                ) {
                  final selected =
                      index ==
                          _currentIndex;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex =
                            index;
                      });
                    },
                    child: Container(
                      width: 62,
                      height: 78,
                      padding:
                          const EdgeInsets
                              .all(
                        3,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                        border:
                            Border.all(
                          color: selected
                              ? const Color(
                                  0xFF146CE8,
                                )
                              : const Color(
                                  0xFFE8EAF0,
                                ),
                          width: selected
                              ? 2
                              : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius
                                .circular(
                          9,
                        ),
                        child:
                            Image.file(
                          _pages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                16,
              ),
              child: SizedBox(
                width:
                    double.infinity,
                height: 54,
                child:
                    ElevatedButton.icon(
                  onPressed:
                      _isProcessing
                          ? null
                          : _createPdf,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF146CE8,
                    ),
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                  icon: const Icon(
                    Icons
                        .picture_as_pdf_rounded,
                  ),
                  label: const Text(
                    'Create PDF',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorAction
    extends StatelessWidget {
  const _EditorAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(
        14,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        child: Container(
          height: 52,
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
            border: Border.all(
              color: const Color(
                0xFFE8EAF0,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: const Color(
                  0xFF146CE8,
                ),
                size: 21,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Color(
                    0xFF101631,
                  ),
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveOption
    extends StatelessWidget {
  const _SaveOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: const Color(
        0xFFF7F8FC,
      ),
      borderRadius:
          BorderRadius.circular(
        16,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        child: Padding(
          padding:
              const EdgeInsets.all(
            14,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration:
                    BoxDecoration(
                  color: const Color(
                    0xFFEAF1FF,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),
                child: Icon(
                  icon,
                  color: const Color(
                    0xFF146CE8,
                  ),
                  size: 23,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(
                        color: Color(
                          0xFF101631,
                        ),
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      subtitle,
                      style:
                          const TextStyle(
                        color: Color(
                          0xFF737A90,
                        ),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons
                    .chevron_right_rounded,
                color: Color(
                  0xFF9AA0AF,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}