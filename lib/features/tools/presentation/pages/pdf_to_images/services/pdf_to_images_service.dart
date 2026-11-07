import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_pdfviewer_platform_interface/pdfviewer_platform_interface.dart';

class PdfToImagesService {
  static Future<List<File>> convertToImages({
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

    if (!originalName.toLowerCase().endsWith('.pdf')) {
      throw Exception(
        'Please select a valid PDF file.',
      );
    }

    final documentId =
        'docera_${DateTime.now().microsecondsSinceEpoch}';

    final renderer = PdfViewerPlatform.instance;

    await renderer.initializePdfRenderer(
      pdfBytes,
      documentId,
    );

    try {
      final pagesWidth =
          await renderer.getPagesWidth(documentId);

      final pagesHeight =
          await renderer.getPagesHeight(documentId);

      if (pagesWidth == null || pagesHeight == null) {
        throw Exception(
          'Unable to read PDF page dimensions.',
        );
      }

      if (pagesWidth.isEmpty || pagesHeight.isEmpty) {
        throw Exception(
          'The PDF does not contain any pages.',
        );
      }

      final pageCount = pagesWidth.length;

      final outputDirectory =
          await _createOutputDirectory();

      final baseName = originalName.substring(
        0,
        originalName.length - 4,
      );

      final outputFiles = <File>[];

      for (var index = 0; index < pageCount; index++) {
        final pageNumber = index + 1;

        final width =
            pagesWidth[index].toInt();

        final height =
            pagesHeight[index].toInt();

        if (width <= 0 || height <= 0) {
          throw Exception(
            'Invalid dimensions for page $pageNumber.',
          );
        }

        final imageBytes = await renderer.getPage(
          pageNumber,
          width,
          height,
          documentId,
        );

        if (imageBytes == null || imageBytes.isEmpty) {
          throw Exception(
            'Failed to render page $pageNumber.',
          );
        }

        final pngBytes = await _convertToPng(
          imageBytes,
          width,
          height,
        );

        final outputFile = File(
          '${outputDirectory.path}/'
          '${baseName}_page_$pageNumber.png',
        );

        await outputFile.writeAsBytes(
          pngBytes,
          flush: true,
        );

        if (!await outputFile.exists()) {
          throw Exception(
            'Failed to save page $pageNumber.',
          );
        }

        outputFiles.add(outputFile);
      }

      return outputFiles;
    } finally {
      await renderer.closeDocument(
        documentId,
      );
    }
  }

  static Future<Directory> _createOutputDirectory() async {
    final directory =
        await getTemporaryDirectory();

    final outputDirectory = Directory(
      '${directory.path}/'
      'docera_pdf_images_'
      '${DateTime.now().millisecondsSinceEpoch}',
    );

    await outputDirectory.create(
      recursive: true,
    );

    return outputDirectory;
  }

  static Future<Uint8List> _convertToPng(
    Uint8List pixels,
    int width,
    int height,
  ) async {
    final completer = Completer<ui.Image>();

    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );

    final image = await completer.future;

    try {
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception(
          'Failed to convert PDF page to PNG.',
        );
      }

      return byteData.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }
}