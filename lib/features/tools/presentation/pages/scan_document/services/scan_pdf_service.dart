import 'dart:io';

import 'package:docera/core/storage/file_storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ScanPdfService {
  static Future<File> createPdf(
    List<File> pages,
  ) async {
    if (pages.isEmpty) {
      throw Exception('No scanned pages available.');
    }

    final pdf = pw.Document();

    for (final page in pages) {
      final imageBytes = await page.readAsBytes();

      final image = pw.MemoryImage(
        imageBytes,
      );

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
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

    final directory =
        await getTemporaryDirectory();

    final timestamp =
        DateTime.now().millisecondsSinceEpoch;

    final file = File(
      '${directory.path}/Scan_$timestamp.pdf',
    );

    final bytes = await pdf.save();

    await file.writeAsBytes(
      bytes,
      flush: true,
    );

    return file;
  }

  static Future<File> saveInDocera(
    File pdfFile,
  ) async {
    final savedFile =
        await FileStorageService.saveFile(
      pdfFile,
    );

    return savedFile.file;
  }

  static Future<bool> saveToDevice(
    File pdfFile,
  ) async {
    try {
      if (!await pdfFile.exists()) {
        throw Exception(
          'PDF file does not exist.',
        );
      }

      final fileName =
          pdfFile.path.split('/').last;

      final bytes =
          await pdfFile.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception(
          'PDF file is empty.',
        );
      }

      final outputUri =
          await FilePicker.saveFile(
        dialogTitle: 'Save PDF',
        fileName: fileName,
        bytes: bytes,
        mimeType: 'application/pdf',
      );

      if (outputUri == null) {
        return false;
      }

      return true;
    } catch (e) {
      print(
        'Save to device error: $e',
      );

      rethrow;
    }
  }
}