import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ImagesToPdfService {
  static Future<File> convertToPdf({
    required List<File> images,
  }) async {
    if (images.isEmpty) {
      throw Exception(
        'Please select at least one image.',
      );
    }

    final pdf = pw.Document();

    for (final imageFile in images) {
      if (!await imageFile.exists()) {
        throw Exception(
          'One of the selected images could not be found.',
        );
      }

      final bytes = await imageFile.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception(
          'One of the selected images is empty.',
        );
      }

      final image = pw.MemoryImage(bytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (context) {
            return pw.Center(
              child: pw.Image(
                image,
                fit: pw.BoxFit.contain,
              ),
            );
          },
        ),
      );
    }

    final firstImageName =
        images.first.path.split(Platform.pathSeparator).last;

    final baseName = firstImageName.contains('.')
        ? firstImageName.substring(
            0,
            firstImageName.lastIndexOf('.'),
          )
        : 'images';

    final directory = images.first.parent;

    final timestamp =
        DateTime.now().millisecondsSinceEpoch;

    final outputFile = File(
      '${directory.path}/'
      '${baseName}_images_$timestamp.pdf',
    );

    final pdfBytes = await pdf.save();

    if (pdfBytes.isEmpty) {
      throw Exception(
        'The PDF conversion returned an empty file.',
      );
    }

    await outputFile.writeAsBytes(
      pdfBytes,
      flush: true,
    );

    if (!await outputFile.exists()) {
      throw Exception(
        'Failed to create the PDF file.',
      );
    }

    final fileSize = await outputFile.length();

    if (fileSize == 0) {
      throw Exception(
        'The generated PDF is empty.',
      );
    }

    return outputFile;
  }
}