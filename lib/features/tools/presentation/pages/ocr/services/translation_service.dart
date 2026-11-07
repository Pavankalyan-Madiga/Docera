import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  final OnDeviceTranslatorModelManager _modelManager =
      OnDeviceTranslatorModelManager();

  final LanguageIdentifier _languageIdentifier =
      LanguageIdentifier(
    confidenceThreshold: 0.5,
  );

  Future<TranslateLanguage?> detectLanguage(
    String text,
  ) async {
    final value = text.trim();

    if (value.isEmpty) {
      return null;
    }

    final languageCode =
        await _languageIdentifier.identifyLanguage(value);

    if (languageCode == 'und') {
      return null;
    }

    return _languageFromCode(languageCode);
  }

  Future<String> translate({
    required String text,
    required TranslateLanguage sourceLanguage,
    required TranslateLanguage targetLanguage,
  }) async {
    final value = text.trim();

    if (value.isEmpty) {
      return '';
    }

    if (sourceLanguage == targetLanguage) {
      return value;
    }

    await _downloadModel(sourceLanguage);
    await _downloadModel(targetLanguage);

    final translator = OnDeviceTranslator(
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );

    try {
      return await translator.translateText(value);
    } finally {
      await translator.close();
    }
  }

  Future<void> _downloadModel(
    TranslateLanguage language,
  ) async {
    final code = language.bcpCode;

    final isDownloaded =
        await _modelManager.isModelDownloaded(code);

    if (!isDownloaded) {
      await _modelManager.downloadModel(
        code,
        isWifiRequired: false,
      );
    }
  }

  TranslateLanguage? _languageFromCode(
    String code,
  ) {
    final normalized = code.toLowerCase().split('-').first;

    switch (normalized) {
      case 'en':
        return TranslateLanguage.english;
      case 'te':
        return TranslateLanguage.telugu;
      case 'hi':
        return TranslateLanguage.hindi;
      case 'ta':
        return TranslateLanguage.tamil;
      case 'kn':
        return TranslateLanguage.kannada;
      case 'bn':
        return TranslateLanguage.bengali;
      case 'gu':
        return TranslateLanguage.gujarati;
      case 'mr':
        return TranslateLanguage.marathi;
      case 'ur':
        return TranslateLanguage.urdu;
      case 'ar':
        return TranslateLanguage.arabic;
      case 'zh':
        return TranslateLanguage.chinese;
      case 'ja':
        return TranslateLanguage.japanese;
      case 'ko':
        return TranslateLanguage.korean;
      case 'es':
        return TranslateLanguage.spanish;
      case 'fr':
        return TranslateLanguage.french;
      case 'de':
        return TranslateLanguage.german;
      case 'it':
        return TranslateLanguage.italian;
      case 'pt':
        return TranslateLanguage.portuguese;
      case 'ru':
        return TranslateLanguage.russian;
      case 'tr':
        return TranslateLanguage.turkish;
      case 'id':
        return TranslateLanguage.indonesian;
      case 'vi':
        return TranslateLanguage.vietnamese;
      case 'th':
        return TranslateLanguage.thai;
      case 'nl':
        return TranslateLanguage.dutch;
      case 'pl':
        return TranslateLanguage.polish;
      case 'uk':
        return TranslateLanguage.ukrainian;
      case 'fa':
        return TranslateLanguage.persian;
      case 'he':
        return TranslateLanguage.hebrew;
      default:
        return null;
    }
  }

  Future<void> dispose() async {
    await _languageIdentifier.close();
  }
}