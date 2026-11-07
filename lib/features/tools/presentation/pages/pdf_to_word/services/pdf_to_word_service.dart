import 'dart:io';

import 'package:quds_office_engine/quds_office_engine.dart';

class PdfToWordService {
  static Future<File> convertToWord({
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
        '${nameWithoutExtension}_converted.docx';

    final docxBytes = PdfToOffice.toDocx(
      pdfBytes,
    );

    if (docxBytes.isEmpty) {
      throw Exception(
        'The PDF conversion returned an empty Word document.',
      );
    }

    final outputFile = File(outputPath);

    await outputFile.writeAsBytes(
      docxBytes,
      flush: true,
    );

    if (!await outputFile.exists()) {
      throw Exception(
        'Failed to create the Word document.',
      );
    }

    final fileSize = await outputFile.length();

    if (fileSize == 0) {
      throw Exception(
        'The generated Word document is empty.',
      );
    }

    return outputFile;
  }
}