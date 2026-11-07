import 'dart:io';

import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class ScannerService {
  static Future<File> captureImage(
    CameraController controller,
  ) async {
    if (!controller.value.isInitialized) {
      throw StateError('Camera is not initialized');
    }

    final XFile capturedFile =
        await controller.takePicture();

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

    final targetPath =
        '${scanDirectory.path}/scan_$timestamp.jpg';

    final file = File(capturedFile.path);

    return file.copy(targetPath);
  }
}