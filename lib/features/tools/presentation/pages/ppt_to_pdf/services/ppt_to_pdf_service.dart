import 'dart:io';

import 'package:flutter/services.dart';
import 'package:quds_office_engine/quds_office_engine.dart';

class PptToPdfService {
  static Future<File> convertToPdf({
    required File inputFile,
  }) async {
    if (!await inputFile.exists()) {
      throw Exception('PowerPoint file does not exist.');
    }

    final pptxBytes = await inputFile.readAsBytes();

    if (pptxBytes.isEmpty) {
      throw Exception('The PowerPoint file is empty.');
    }

    final fontData = await rootBundle.load(
      'assets/fonts/LiberationSans-Regular.ttf',
    );

    final font = SfntFont.parse(
      fontData.buffer.asUint8List(),
    );

    final originalName =
        inputFile.path.split(Platform.pathSeparator).last;

    final lowerName = originalName.toLowerCase();

    if (!lowerName.endsWith('.pptx')) {
      throw Exception('Please select a valid PPTX file.');
    }

    final nameWithoutExtension = originalName.substring(
      0,
      originalName.length - 5,
    );

    final pdfBytes = OfficePdfExport.fromBytes(
      pptxBytes,
      fonts: OfficeFontSet(
        primary: font,
      ),
      title: originalName,
    );

    if (pdfBytes.isEmpty) {
      throw Exception(
        'The PDF conversion returned an empty file.',
      );
    }

    final outputPath =
        '${inputFile.parent.path}/'
        '${nameWithoutExtension}_converted.pdf';

    final outputFile = File(outputPath);

    await outputFile.writeAsBytes(
      pdfBytes,
      flush: true,
    );

    if (!await outputFile.exists()) {
      throw Exception(
        'Failed to create the converted PDF.',
      );
    }

    final size = await outputFile.length();

    if (size == 0) {
      throw Exception(
        'The converted PDF is empty.',
      );
    }

    return outputFile;
  }
}