import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ScanImageService {
  static Future<File> rotateImage(File file) async {
    final bytes = await file.readAsBytes();

    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw StateError('Unable to decode image');
    }

    final rotated = img.copyRotate(
      decoded,
      angle: 90,
    );

    return _saveImage(
      rotated,
      prefix: 'rotated',
    );
  }

  static Future<File> resizeImage(
    File file, {
    int maxWidth = 2000,
    int maxHeight = 2000,
  }) async {
    final bytes = await file.readAsBytes();

    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw StateError('Unable to decode image');
    }

    final widthRatio =
        maxWidth / decoded.width;

    final heightRatio =
        maxHeight / decoded.height;

    final ratio = math.min(
      1.0,
      math.min(
        widthRatio,
        heightRatio,
      ),
    );

    if (ratio >= 1.0) {
      return file;
    }

    final resized = img.copyResize(
      decoded,
      width: (decoded.width * ratio).round(),
      height: (decoded.height * ratio).round(),
    );

    return _saveImage(
      resized,
      prefix: 'resized',
    );
  }

  static Future<File> enhanceImage(File file) async {
    final bytes = await file.readAsBytes();

    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw StateError('Unable to decode image');
    }

    final enhanced = img.adjustColor(
      decoded,
      contrast: 1.15,
      brightness: 1.05,
      saturation: 0.85,
    );

    return _saveImage(
      enhanced,
      prefix: 'enhanced',
    );
  }

  static Future<File> _saveImage(
    img.Image image, {
    required String prefix,
  }) async {
    final directory =
        await getApplicationDocumentsDirectory();

    final scanDirectory = Directory(
      '${directory.path}/scans',
    );

    if (!await scanDirectory.exists()) {
      await scanDirectory.create(
        recursive: true,
      );
    }

    final timestamp =
        DateTime.now().millisecondsSinceEpoch;

    final path =
        '${scanDirectory.path}/${prefix}_$timestamp.jpg';

    final bytes = img.encodeJpg(
      image,
      quality: 92,
    );

    final file = File(path);

    await file.writeAsBytes(
      bytes,
      flush: true,
    );

    return file;
  }
}