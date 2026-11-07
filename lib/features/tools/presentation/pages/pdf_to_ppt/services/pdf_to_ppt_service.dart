import 'dart:io';

import 'package:quds_office_engine/quds_office_engine.dart';

class PdfToPptService {
  static Future<File> convertToPpt({
    required File inputFile,
  }) async {
    if (!await inputFile.exists()) {
      throw Exception(
        'PDF file does not exist.',
      );
    }

    final pdfBytes = await inputFile.readAsBytes();

    if (pdfBytes.isEmpty) {
      throw Exception(
        'The PDF file is empty.',
      );
    }

    final originalName =
        inputFile.path.split(Platform.pathSeparator).last;

    final lowerName = originalName.toLowerCase();

    if (!lowerName.endsWith('.pdf')) {
      throw Exception(
        'Please select a valid PDF file.',
      );
    }

    final nameWithoutExtension = originalName.substring(
      0,
      originalName.length - 4,
    );

    final outputPath =
        '${inputFile.parent.path}/'
        '${nameWithoutExtension}_converted.pptx';

    final pptBytes = PdfToOffice.toPptx(
      pdfBytes,
    );

    if (pptBytes.isEmpty) {
      throw Exception(
        'The PDF conversion returned an empty PowerPoint file.',
      );
    }

    final outputFile = File(outputPath);

    await outputFile.writeAsBytes(
      pptBytes,
      flush: true,
    );

    if (!await outputFile.exists()) {
      throw Exception(
        'Failed to create the PowerPoint file.',
      );
    }

    final fileSize = await outputFile.length();

    if (fileSize == 0) {
      throw Exception(
        'The generated PowerPoint file is empty.',
      );
    }

    return outputFile;
  }
}