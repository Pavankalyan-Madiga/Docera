import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _textRecognizer =
      TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  Future<String> recognizeText(File imageFile) async {
    if (!await imageFile.exists()) {
      throw Exception(
        'Image file does not exist',
      );
    }

    final inputImage = InputImage.fromFilePath(
      imageFile.path,
    );

    final recognizedText =
        await _textRecognizer.processImage(
      inputImage,
    );

    print(
      'OCR blocks: ${recognizedText.blocks.length}',
    );

    print(
      'OCR text: ${recognizedText.text}',
    );

    return recognizedText.text.trim();
  }

  Future<RecognizedText> recognizeTextDetails(
    File imageFile,
  ) async {
    final inputImage = InputImage.fromFilePath(
      imageFile.path,
    );

    return await _textRecognizer.processImage(
      inputImage,
    );
  }

  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}