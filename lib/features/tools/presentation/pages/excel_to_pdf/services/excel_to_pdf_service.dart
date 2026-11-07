import 'dart:io';

import 'package:excel_ce/excel_ce.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ExcelToPdfService {
  static Future<File> convertToPdf({
    required File inputFile,
  }) async {
    final bytes = await inputFile.readAsBytes();

    final excel = Excel.decodeBytes(bytes);

    final pdf = pw.Document();

    var hasData = false;

    for (final sheetName in excel.tables.keys) {
      final sheet = excel.tables[sheetName];

      if (sheet == null || sheet.rows.isEmpty) {
        continue;
      }

      final rows = <List<String>>[];

      for (final row in sheet.rows) {
        final values = <String>[];

        for (final cell in row) {
          values.add(
            _cellValueToString(cell?.value),
          );
        }

        rows.add(values);
      }

      if (rows.isEmpty) {
        continue;
      }

      final columnCount = rows.fold<int>(
        0,
        (maximum, row) {
          return row.length > maximum
              ? row.length
              : maximum;
        },
      );

      if (columnCount == 0) {
        continue;
      }

      final normalizedRows = rows.map(
        (row) {
          return List<String>.generate(
            columnCount,
            (index) {
              if (index < row.length) {
                return row[index];
              }

              return '';
            },
          );
        },
      ).toList();

      if (normalizedRows.isEmpty) {
        continue;
      }

      hasData = true;

      final headers = normalizedRows.first;

      final data = normalizedRows.length > 1
          ? normalizedRows.sublist(1)
          : <List<String>>[];

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) {
            return [
              pw.Text(
                sheetName,
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.TableHelper.fromTextArray(
                headers: headers,
                data: data,
                border: pw.TableBorder.all(
                  color: PdfColors.grey600,
                  width: 0.5,
                ),
                headerDecoration:
                    const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                headerStyle: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
                cellStyle: const pw.TextStyle(
                  fontSize: 7,
                ),
                cellPadding:
                    const pw.EdgeInsets.all(4),
                cellAlignment:
                    pw.Alignment.centerLeft,
                headerAlignment:
                    pw.Alignment.centerLeft,
              ),
            ];
          },
        ),
      );
    }

    if (!hasData) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Center(
              child: pw.Text(
                'No data found in Excel file.',
                style: const pw.TextStyle(
                  fontSize: 14,
                ),
              ),
            );
          },
        ),
      );
    }

    final pdfBytes = await pdf.save();

    final originalName =
        inputFile.path.split('/').last;

    final nameWithoutExtension =
        originalName.toLowerCase().endsWith('.xlsx')
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

  static String _cellValueToString(
    CellValue? value,
  ) {
    switch (value) {
      case null:
        return '';

      case TextCellValue():
        return _textSpanToString(value.value);

      case FormulaCellValue():
        return value.formula;

      case IntCellValue():
        return value.value.toString();

      case DoubleCellValue():
        return value.value.toString();

      case BoolCellValue():
        return value.value ? 'TRUE' : 'FALSE';

      case DateCellValue():
        return value
            .asDateTimeLocal()
            .toString()
            .split(' ')
            .first;

      case TimeCellValue():
        return value
            .asDuration()
            .toString();

      case DateTimeCellValue():
        return value
            .asDateTimeLocal()
            .toString();
    }
  }

  static String _textSpanToString(
    TextSpan span,
  ) {
    final buffer = StringBuffer();

    if (span.text != null) {
      buffer.write(span.text);
    }

    final children = span.children;

    if (children != null) {
      for (final child in children) {
        buffer.write(
          _textSpanToString(child),
        );
      }
    }

    return buffer.toString();
  }
}