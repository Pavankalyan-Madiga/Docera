import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'docera_file_model.dart';

class FileStorageService {
  static Directory? _doceraDirectory;

  static Future<Directory> _getDirectory() async {
    if (_doceraDirectory != null) {
      return _doceraDirectory!;
    }

    final directory = await getApplicationDocumentsDirectory();

    final doceraDirectory = Directory(
      '${directory.path}/Docera',
    );

    if (!await doceraDirectory.exists()) {
      await doceraDirectory.create(
        recursive: true,
      );
    }

    _doceraDirectory = doceraDirectory;

    return doceraDirectory;
  }

  static Future<DoceraFileModel> saveFile(
    File file,
  ) async {
    final directory = await _getDirectory();

    final originalName = file.path.split('/').last;

    final extension = originalName.contains('.')
        ? originalName.split('.').last.toLowerCase()
        : '';

    final timestamp =
        DateTime.now().millisecondsSinceEpoch;

    final nameWithoutExtension = originalName.contains('.')
        ? originalName.substring(
            0,
            originalName.lastIndexOf('.'),
          )
        : originalName;

    final safeName =
        '${nameWithoutExtension}_$timestamp';

    final targetName = extension.isEmpty
        ? safeName
        : '$safeName.$extension';

    final targetFile = File(
      '${directory.path}/$targetName',
    );

    final savedFile = await file.copy(
      targetFile.path,
    );

    return DoceraFileModel(
      name: savedFile.path.split('/').last,
      path: savedFile.path,
      extension: extension,
      createdAt: DateTime.now(),
    );
  }

  static Future<List<DoceraFileModel>> getFiles() async {
    final directory = await _getDirectory();

    if (!await directory.exists()) {
      return [];
    }

    final entities = await directory.list().toList();

    final files = <DoceraFileModel>[];

    for (final entity in entities) {
      if (entity is! File) continue;

      final name = entity.path.split('/').last;

      if (name.startsWith('.')) continue;

      final extension = name.contains('.')
          ? name.split('.').last.toLowerCase()
          : '';

      final stat = await entity.stat();

      files.add(
        DoceraFileModel(
          name: name,
          path: entity.path,
          extension: extension,
          createdAt: stat.modified,
        ),
      );
    }

    files.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return files;
  }

  static Future<List<DoceraFileModel>> getRecentFiles({
    int limit = 5,
  }) async {
    final files = await getFiles();

    return files.take(limit).toList();
  }

  static Future<void> deleteFile(
    DoceraFileModel file,
  ) async {
    final target = File(file.path);

    if (await target.exists()) {
      await target.delete();
    }
  }

  static Future<void> renameFile(
    DoceraFileModel file,
    String newName,
  ) async {
    final target = File(file.path);

    if (!await target.exists()) {
      return;
    }

    final directory = await _getDirectory();

    final newPath =
        '${directory.path}/$newName';

    await target.rename(newPath);
  }
}