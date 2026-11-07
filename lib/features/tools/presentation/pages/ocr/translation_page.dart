import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:share_plus/share_plus.dart';

import 'services/translation_service.dart';

class TranslationPage extends StatefulWidget {
  final String text;

  const TranslationPage({
    super.key,
    required this.text,
  });

  @override
  State<TranslationPage> createState() =>
      _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  final TranslationService _translationService =
      TranslationService();

  final List<_LanguageOption> _languages = [
    _LanguageOption(
      name: 'English',
      language: TranslateLanguage.english,
    ),
    _LanguageOption(
      name: 'Telugu',
      language: TranslateLanguage.telugu,
    ),
    _LanguageOption(
      name: 'Hindi',
      language: TranslateLanguage.hindi,
    ),
    _LanguageOption(
      name: 'Tamil',
      language: TranslateLanguage.tamil,
    ),
    _LanguageOption(
      name: 'Kannada',
      language: TranslateLanguage.kannada,
    ),
    _LanguageOption(
      name: 'Bengali',
      language: TranslateLanguage.bengali,
    ),
    _LanguageOption(
      name: 'Gujarati',
      language: TranslateLanguage.gujarati,
    ),
    _LanguageOption(
      name: 'Marathi',
      language: TranslateLanguage.marathi,
    ),

    _LanguageOption(
      name: 'Urdu',
      language: TranslateLanguage.urdu,
    ),
    _LanguageOption(
      name: 'Arabic',
      language: TranslateLanguage.arabic,
    ),
    _LanguageOption(
      name: 'Chinese',
      language: TranslateLanguage.chinese,
    ),
    _LanguageOption(
      name: 'Japanese',
      language: TranslateLanguage.japanese,
    ),
    _LanguageOption(
      name: 'Korean',
      language: TranslateLanguage.korean,
    ),
    _LanguageOption(
      name: 'Spanish',
      language: TranslateLanguage.spanish,
    ),
    _LanguageOption(
      name: 'French',
      language: TranslateLanguage.french,
    ),
    _LanguageOption(
      name: 'German',
      language: TranslateLanguage.german,
    ),
    _LanguageOption(
      name: 'Italian',
      language: TranslateLanguage.italian,
    ),
    _LanguageOption(
      name: 'Portuguese',
      language: TranslateLanguage.portuguese,
    ),
    _LanguageOption(
      name: 'Russian',
      language: TranslateLanguage.russian,
    ),
    _LanguageOption(
      name: 'Turkish',
      language: TranslateLanguage.turkish,
    ),
    _LanguageOption(
      name: 'Indonesian',
      language: TranslateLanguage.indonesian,
    ),
    _LanguageOption(
      name: 'Vietnamese',
      language: TranslateLanguage.vietnamese,
    ),
    _LanguageOption(
      name: 'Thai',
      language: TranslateLanguage.thai,
    ),
    _LanguageOption(
      name: 'Dutch',
      language: TranslateLanguage.dutch,
    ),
    _LanguageOption(
      name: 'Polish',
      language: TranslateLanguage.polish,
    ),
    _LanguageOption(
      name: 'Ukrainian',
      language: TranslateLanguage.ukrainian,
    ),
    _LanguageOption(
      name: 'Persian',
      language: TranslateLanguage.persian,
    ),
    _LanguageOption(
      name: 'Hebrew',
      language: TranslateLanguage.hebrew,
    ),
  ];

  TranslateLanguage? _sourceLanguage;
  TranslateLanguage _targetLanguage =
      TranslateLanguage.telugu;

  String _sourceLabel = 'Auto Detect';
  String _translatedText = '';

  bool _isDetecting = false;
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _translate() async {
    final text = widget.text.trim();

    if (text.isEmpty) {
      _showMessage(
        'There is no text to translate',
      );
      return;
    }

    setState(() {
      _isTranslating = true;
    });

    try {
      TranslateLanguage? source =
          _sourceLanguage;

      if (source == null) {
        setState(() {
          _isDetecting = true;
        });

        source = await _translationService
            .detectLanguage(text);

        if (!mounted) return;

        setState(() {
          _isDetecting = false;
        });

        if (source == null) {
          _showMessage(
            'Unable to detect the source language',
          );
          return;
        }

        final detected =
            _languageName(source);

        setState(() {
          _sourceLabel = detected;
        });
      }

      if (source == _targetLanguage) {
        setState(() {
          _translatedText = text;
        });
        return;
      }

      final result =
          await _translationService.translate(
        text: text,
        sourceLanguage: source,
        targetLanguage: _targetLanguage,
      );

      if (!mounted) return;

      setState(() {
        _translatedText = result;
      });
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Translation failed: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTranslating = false;
          _isDetecting = false;
        });
      }
    }
  }

  Future<void> _copyTranslation() async {
    if (_translatedText.trim().isEmpty) {
      return;
    }

    await Clipboard.setData(
      ClipboardData(
        text: _translatedText,
      ),
    );

    if (!mounted) return;

    _showMessage(
      'Translation copied',
    );
  }

  Future<void> _shareTranslation() async {
    final text = _translatedText.trim();

    if (text.isEmpty) {
      return;
    }

    await SharePlus.instance.share(
      ShareParams(
        text: text,
        title: 'Docera Translation',
      ),
    );
  }

  Future<void> _selectSourceLanguage() async {
    final result =
        await showModalBottomSheet<_LanguageOption?>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.auto_awesome,
                ),
                title: const Text(
                  'Auto Detect',
                ),
                selected:
                    _sourceLanguage == null,
                onTap: () {
                  Navigator.pop(
                    context,
                    null,
                  );
                },
              ),
              ..._languages.map(
                (language) {
                  return ListTile(
                    title: Text(
                      language.name,
                    ),
                    selected:
                        _sourceLanguage ==
                            language.language,
                    onTap: () {
                      Navigator.pop(
                        context,
                        language,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    setState(() {
      if (result == null) {
        _sourceLanguage = null;
        _sourceLabel = 'Auto Detect';
      } else {
        _sourceLanguage = result.language;
        _sourceLabel = result.name;
      }

      _translatedText = '';
    });
  }

  Future<void> _selectTargetLanguage() async {
    final result =
        await showModalBottomSheet<_LanguageOption>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            children: _languages.map(
              (language) {
                return ListTile(
                  title: Text(
                    language.name,
                  ),
                  selected:
                      _targetLanguage ==
                          language.language,
                  onTap: () {
                    Navigator.pop(
                      context,
                      language,
                    );
                  },
                );
              },
            ).toList(),
          ),
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _targetLanguage =
          result.language;
      _translatedText = '';
    });
  }

  void _swapLanguages() {
    if (_sourceLanguage == null) {
      _showMessage(
        'Detect the source language first',
      );
      return;
    }

    final oldSource = _sourceLanguage!;
    final oldTarget = _targetLanguage;

    setState(() {
      _sourceLanguage = oldTarget;
      _targetLanguage = oldSource;
      _sourceLabel =
          _languageName(oldTarget);
      _translatedText = '';
    });
  }

  String _languageName(
    TranslateLanguage language,
  ) {
    for (final item in _languages) {
      if (item.language == language) {
        return item.name;
      }
    }

    return language.name;
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _translationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasTranslation =
        _translatedText.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Translate',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  12,
                  18,
                  20,
                ),
                children: [
                  _SectionCard(
                    title: 'Original Text',
                    icon: Icons.description_outlined,
                    child: Text(
                      widget.text,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _TranslationCard(
                    theme: theme,
                    sourceLabel: _sourceLabel,
                    targetLabel:
                        _languageName(
                      _targetLanguage,
                    ),
                    onSourceTap:
                        _selectSourceLanguage,
                    onTargetTap:
                        _selectTargetLanguage,
                    onSwap: _swapLanguages,
                    translatedText:
                        _translatedText,
                    hasTranslation:
                        hasTranslation,
                    isTranslating:
                        _isTranslating,
                    isDetecting:
                        _isDetecting,
                    onCopy:
                        _copyTranslation,
                    onShare:
                        _shareTranslation,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed:
                          _isTranslating
                              ? null
                              : _translate,
                      icon: _isTranslating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.translate,
                            ),
                      label: Text(
                        _isDetecting
                            ? 'Detecting Language...'
                            : _isTranslating
                                ? 'Translating...'
                                : hasTranslation
                                    ? 'Translate Again'
                                    : 'Translate',
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption {
  final String name;
  final TranslateLanguage language;

  const _LanguageOption({
    required this.name,
    required this.language,
  });
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.35),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: theme.dividerColor
              .withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 21,
                color:
                    theme.colorScheme.primary,
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w700,
                  color: theme
                      .colorScheme
                      .primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _TranslationCard extends StatelessWidget {
  final ThemeData theme;
  final String sourceLabel;
  final String targetLabel;
  final VoidCallback onSourceTap;
  final VoidCallback onTargetTap;
  final VoidCallback onSwap;
  final String translatedText;
  final bool hasTranslation;
  final bool isTranslating;
  final bool isDetecting;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _TranslationCard({
    required this.theme,
    required this.sourceLabel,
    required this.targetLabel,
    required this.onSourceTap,
    required this.onTargetTap,
    required this.onSwap,
    required this.translatedText,
    required this.hasTranslation,
    required this.isTranslating,
    required this.isDetecting,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary
              .withValues(alpha: 0.25),
        ),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary
                .withValues(alpha: 0.07),
            theme.colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.translate,
                color:
                    theme.colorScheme.primary,
              ),
              const SizedBox(width: 9),
              Text(
                'Translation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w700,
                  color: theme
                      .colorScheme
                      .primary,
                ),
              ),
              const Spacer(),
              if (hasTranslation)
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green
                        .withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Translated',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight:
                              FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _LanguageButton(
                  label: sourceLabel,
                  title: 'From',
                  onTap: onSourceTap,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed:
                    sourceLabel == 'Auto Detect'
                        ? null
                        : onSwap,
                icon: const Icon(
                  Icons.swap_horiz,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LanguageButton(
                  label: targetLabel,
                  title: 'To',
                  onTap: onTargetTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            constraints:
                const BoxConstraints(
              minHeight: 140,
            ),
            padding:
                const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary
                  .withValues(alpha: 0.05),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: isTranslating
                ? const Center(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text(
                          'Preparing translation...',
                        ),
                      ],
                    ),
                  )
                : hasTranslation
                    ? Text(
                        translatedText,
                        style:
                            const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                        ),
                      )
                    : Center(
                        child: Text(
                          isDetecting
                              ? 'Detecting source language...'
                              : 'Your translation will appear here',
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            color: Colors
                                .grey
                                .shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
          ),
          if (hasTranslation) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCopy,
                    icon: const Icon(
                      Icons.copy_outlined,
                    ),
                    label: const Text(
                      'Copy Translation',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onShare,
                    icon: const Icon(
                      Icons.share_outlined,
                    ),
                    label: const Text(
                      'Share Translation',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String title;
  final String label;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.title,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(14),
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.dividerColor,
          ),
          borderRadius:
              BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 19,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}