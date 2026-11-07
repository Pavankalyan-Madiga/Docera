import 'dart:io';

import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfUnlockService {
  static Future<File> unlockPdf({
    required File inputFile,
    required String password,
  }) async {
    final bytes = await inputFile.readAsBytes();

    PdfDocument? document;

    try {
      document = PdfDocument(
        inputBytes: bytes,
        password: password,
      );

      document.security.userPassword = '';
      document.security.ownerPassword = '';

      final unlockedBytes = await document.save();

      final originalName =
          inputFile.path.split('/').last;

      final nameWithoutExtension =
          originalName.toLowerCase().endsWith('.pdf')
              ? originalName.substring(
                  0,
                  originalName.length - 4,
                )
              : originalName;

      final outputPath =
          '${inputFile.parent.path}/'
          '${nameWithoutExtension}_unlocked.pdf';

      final outputFile = File(outputPath);

      await outputFile.writeAsBytes(
        unlockedBytes,
        flush: true,
      );

      return outputFile;
    } finally {
      document?.dispose();
    }
  }
}