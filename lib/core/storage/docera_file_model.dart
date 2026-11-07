import 'dart:io';

class DoceraFileModel {
  final String name;
  final String path;
  final String extension;
  final DateTime createdAt;

  const DoceraFileModel({
    required this.name,
    required this.path,
    required this.extension,
    required this.createdAt,
  });

  File get file => File(path);

  String get type {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'PDF';
      case 'doc':
      case 'docx':
        return 'Documents';
      case 'xls':
      case 'xlsx':
        return 'Spreadsheets';
      case 'ppt':
      case 'pptx':
        return 'Presentations';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
        return 'Images';
      default:
        return 'Other';
    }
  }
}