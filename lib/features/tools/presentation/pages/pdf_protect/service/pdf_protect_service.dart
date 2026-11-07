import 'dart:io';

import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfProtectService {
  static Future<File> protectPdf({
    required File inputFile,
    required String password,
  }) async {
    final bytes = await inputFile.readAsBytes();

    final document = PdfDocument(
      inputBytes: bytes,
    );

    try {
      final security = document.security;

      security.userPassword = password;
      security.ownerPassword =
          '${password}_docera_owner';

      security.algorithm =
          PdfEncryptionAlgorithm.aesx256Bit;

      final protectedBytes =
          await document.save();

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
          '${nameWithoutExtension}_protected.pdf';

      final outputFile = File(outputPath);

      await outputFile.writeAsBytes(
        protectedBytes,
        flush: true,
      );

      return outputFile;
    } finally {
      document.dispose();
    }
  }
}