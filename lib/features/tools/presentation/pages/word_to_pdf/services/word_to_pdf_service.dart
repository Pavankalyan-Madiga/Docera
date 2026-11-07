import 'dart:io';

import 'package:flutter/services.dart';
import 'package:quds_office_engine/quds_office_engine.dart';

class WordToPdfService {
  static Future<File> convertToPdf({
    required File inputFile,
  }) async {
    final docxBytes = await inputFile.readAsBytes();

    final fontData = await rootBundle.load(
      'assets/fonts/LiberationSans-Regular.ttf',
    );

    final font = SfntFont.parse(
      fontData.buffer.asUint8List(),
    );

    final pdfBytes = OfficePdfExport.fromBytes(
      docxBytes,
      fonts: OfficeFontSet(
        primary: font,
      ),
      title: inputFile.path.split('/').last,
    );

    final originalName =
        inputFile.path.split('/').last;

    final nameWithoutExtension =
        originalName.toLowerCase().endsWith('.docx')
            ? originalName.substring(
                0,
                originalName.length - 5,
              )
            : originalName;

    final outputPath =
        '${inputFile.parent.path}/'
        '${nameWithoutExtension}_converted.pdf';

    final outputFile = File(outputPath);

    await outputFile.writeAsBytes(
      pdfBytes,
      flush: true,
    );

    return outputFile;
  }
}