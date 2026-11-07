import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'scan_preview_page.dart';
import 'scan_editor_page.dart';
import 'services/scanner_service.dart';

class ScanDocumentPage extends StatefulWidget {
  const ScanDocumentPage({super.key});

  @override
  State<ScanDocumentPage> createState() => _ScanDocumentPageState();
}

class _ScanDocumentPageState extends State<ScanDocumentPage> {
  CameraController? _controller;
  final List<File> _pages = [];

  bool _isInitializing = true;
  bool _isCapturing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw StateError('No camera available');
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isInitializing = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isInitializing = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _capturePage() async {
    final controller = _controller;

    if (controller == null ||
        !controller.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final file = await ScannerService.captureImage(controller);

      if (!mounted) return;

      setState(() {
        _pages.add(file);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to capture document: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _openPreview() async {
    if (_pages.isEmpty) return;

    final updatedPages = await Navigator.push<List<File>>(
      context,
      MaterialPageRoute(
        builder: (_) => ScanPreviewPage(
          pages: List<File>.from(_pages),
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

  Future<void> _openEditor() async {
    if (_pages.isEmpty) return;

    final updatedPages = await Navigator.push<List<File>>(
      context,
      MaterialPageRoute(
        builder: (_) => ScanEditorPage(
          pages: List<File>.from(_pages),
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

  Future<void> _finishScanning() async {
    if (_pages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Capture at least one page'),
        ),
      );
      return;
    }

    await _openEditor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: 56,
              ),
              const SizedBox(height: 16),
              const Text(
                'Camera unavailable',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _isInitializing = true;
                    _error = null;
                  });

                  _initializeCamera();
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: Text(
          'Camera is not ready',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: CameraPreview(controller),
        ),
        CustomPaint(
          painter: _DocumentOverlayPainter(),
        ),
        Positioned(
          top: 14,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CircleButton(
                icon: Icons.close_rounded,
                onTap: () => Navigator.pop(context),
              ),
              if (_pages.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    '${_pages.length} ${_pages.length == 1 ? 'page' : 'pages'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_pages.isNotEmpty)
          Positioned(
            left: 20,
            right: 20,
            bottom: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BottomAction(
                  icon: Icons.photo_library_outlined,
                  label: 'Preview',
                  onTap: _openPreview,
                ),
                const SizedBox(width: 14),
                _BottomAction(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  onTap: _openEditor,
                ),
              ],
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 58),
              GestureDetector(
                onTap: _capturePage,
                child: Container(
                  width: 78,
                  height: 78,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isCapturing
                          ? Colors.white54
                          : Colors.white,
                    ),
                    child: _isCapturing
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.black,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 34),
              if (_pages.isNotEmpty)
                _CircleButton(
                  icon: Icons.check_rounded,
                  backgroundColor: const Color(0xFF146CE8),
                  onTap: _finishScanning,
                )
              else
                const SizedBox(width: 58),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.backgroundColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(
            icon,
            color: Colors.white,
            size: 25,
          ),
        ),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final left = size.width * 0.10;
    final right = size.width * 0.90;
    final top = size.height * 0.22;
    final bottom = size.height * 0.72;

    final rect = Rect.fromLTRB(
      left,
      top,
      right,
      bottom,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(12),
      ),
      paint,
    );

    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cornerLength = 22.0;

    final corners = [
      [
        Offset(left, top + cornerLength),
        Offset(left, top),
        Offset(left + cornerLength, top),
      ],
      [
        Offset(right - cornerLength, top),
        Offset(right, top),
        Offset(right, top + cornerLength),
      ],
      [
        Offset(left, bottom - cornerLength),
        Offset(left, bottom),
        Offset(left + cornerLength, bottom),
      ],
      [
        Offset(right - cornerLength, bottom),
        Offset(right, bottom),
        Offset(right, bottom - cornerLength),
      ],
    ];

    for (final points in corners) {
      final path = Path()
        ..moveTo(points[0].dx, points[0].dy)
        ..lineTo(points[1].dx, points[1].dy)
        ..lineTo(points[2].dx, points[2].dy);

      canvas.drawPath(path, cornerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}