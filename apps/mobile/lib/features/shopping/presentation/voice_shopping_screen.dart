import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../families/application/family_controller.dart';
import '../application/shopping_controller.dart';
import '../domain/shopping_category.dart';
import '../domain/voice_shopping_parser.dart';

class VoiceShoppingScreen extends ConsumerStatefulWidget {
  const VoiceShoppingScreen({super.key});

  @override
  ConsumerState<VoiceShoppingScreen> createState() =>
      _VoiceShoppingScreenState();
}

class _VoiceShoppingScreenState extends ConsumerState<VoiceShoppingScreen> {
  final SpeechToText _speech = SpeechToText();
  bool _speechAvailable = false;
  bool _isInitializing = true;
  String _transcript = '';
  String? _message;
  List<VoiceShoppingDraft> _drafts = <VoiceShoppingDraft>[];

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    final bool available = await _speech.initialize(
      onStatus: (String status) {
        if (!mounted) {
          return;
        }
        setState(() {});
      },
      onError: (error) {
        if (!mounted) {
          return;
        }
        setState(() {
          _message = 'ההכתבה נעצרה. נסה שוב.';
        });
      },
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _speechAvailable = available;
      _isInitializing = false;
      if (!available) {
        _message = 'זיהוי קולי אינו זמין. ודא שהרשאת המיקרופון מאושרת.';
      }
    });
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      await _initializeSpeech();
      return;
    }

    if (_speech.isListening) {
      await _speech.stop();
      if (mounted) {
        setState(() {});
      }
      return;
    }

    setState(() {
      _message = null;
      _transcript = '';
      _drafts = <VoiceShoppingDraft>[];
    });

    final List<LocaleName> locales = await _speech.locales();
    String? hebrewLocale;
    for (final LocaleName locale in locales) {
      if (locale.localeId.toLowerCase().startsWith('he')) {
        hebrewLocale = locale.localeId;
        break;
      }
    }

    await _speech.listen(
      onResult: _onResult,
      listenOptions: SpeechListenOptions(
        localeId: hebrewLocale,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
        partialResults: true,
        cancelOnError: true,
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  void _onResult(SpeechRecognitionResult result) {
    final String words = result.recognizedWords.trim();

    setState(() {
      _transcript = words;
      _drafts = VoiceShoppingParser.parse(words);
      if (result.finalResult && _drafts.isEmpty) {
        _message = 'לא זוהו מוצרים. נסה לומר: חלב, שתי גבינות ולחם.';
      }
    });
  }

  Future<void> _addAll() async {
    final String? familyId = ref.read(familyControllerProvider).activeFamilyId;
    if (familyId == null || _drafts.isEmpty) {
      return;
    }

    int added = 0;
    for (final VoiceShoppingDraft draft in _drafts) {
      final bool success =
          await ref.read(shoppingControllerProvider.notifier).addItem(
                familyId: familyId,
                name: draft.name,
                quantity: draft.quantity,
                note: '',
                category: draft.category,
              );
      if (success) {
        added++;
      }
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('נוספו $added מוצרים לרשימה')),
    );
    context.go('/shopping');
  }

  void _removeDraft(int index) {
    setState(() {
      _drafts = List<VoiceShoppingDraft>.from(_drafts)..removeAt(index);
    });
  }

  void _changeCategory(int index, ShoppingCategory category) {
    final VoiceShoppingDraft current = _drafts[index];
    setState(() {
      _drafts = List<VoiceShoppingDraft>.from(_drafts)
        ..[index] = VoiceShoppingDraft(
          name: current.name,
          quantity: current.quantity,
          category: category,
        );
    });
  }

  Future<void> _editDraft(int index) async {
    final VoiceShoppingDraft current = _drafts[index];
    final TextEditingController name =
        TextEditingController(text: current.name);
    final TextEditingController quantity =
        TextEditingController(text: current.quantity);
    ShoppingCategory category = current.category;

    final VoiceShoppingDraft? result = await showDialog<VoiceShoppingDraft>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            void Function(void Function()) setDialogState,
          ) {
            return AlertDialog(
              title: const Text('עריכת מוצר'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'שם'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: quantity,
                    decoration: const InputDecoration(labelText: 'כמות'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<ShoppingCategory>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'מחלקה'),
                    items: ShoppingCategory.values
                        .map(
                          (ShoppingCategory value) =>
                              DropdownMenuItem<ShoppingCategory>(
                            value: value,
                            child: Text(value.label),
                          ),
                        )
                        .toList(),
                    onChanged: (ShoppingCategory? value) {
                      if (value != null) {
                        setDialogState(() {
                          category = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('ביטול'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(
                    VoiceShoppingDraft(
                      name: name.text.trim(),
                      quantity: quantity.text.trim(),
                      category: category,
                    ),
                  ),
                  child: const Text('שמור'),
                ),
              ],
            );
          },
        );
      },
    );

    name.dispose();
    quantity.dispose();

    if (result == null || result.name.isEmpty || !mounted) {
      return;
    }

    setState(() {
      _drafts = List<VoiceShoppingDraft>.from(_drafts)..[index] = result;
    });
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool listening = _speech.isListening;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('הוספה קולית')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: <Widget>[
            AppCard(
              child: Column(
                children: <Widget>[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: listening ? 108 : 92,
                    height: listening ? 108 : 92,
                    decoration: BoxDecoration(
                      color: listening
                          ? AppColors.error.withValues(alpha: 0.12)
                          : AppColors.softBlue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _isInitializing ? null : _toggleListening,
                      icon: Icon(
                        listening ? Icons.stop_rounded : Icons.mic_rounded,
                        size: 46,
                        color: listening ? AppColors.error : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isInitializing
                        ? 'מכין את המיקרופון...'
                        : listening
                            ? 'מקשיב... אמור את המוצרים'
                            : 'לחץ על המיקרופון והתחל לדבר',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'לדוגמה: חלב, שתי גבינות, 6 ביצים ולחם',
                    textAlign: TextAlign.center,
                  ),
                  if (_transcript.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _transcript,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  if (_message != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      _message!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            if (_drafts.isNotEmpty) ...<Widget>[
              const SizedBox(height: 20),
              Text(
                'המוצרים שזוהו',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              for (int index = 0; index < _drafts.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: AppColors.softGreen,
                          child: Text(
                            _drafts[index].quantity.isEmpty
                                ? '1'
                                : _drafts[index].quantity,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _drafts[index].name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 5),
                              DropdownButton<ShoppingCategory>(
                                value: _drafts[index].category,
                                isDense: true,
                                underline: const SizedBox.shrink(),
                                items: ShoppingCategory.values
                                    .map(
                                      (ShoppingCategory category) =>
                                          DropdownMenuItem<ShoppingCategory>(
                                        value: category,
                                        child: Text(category.label),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (ShoppingCategory? value) {
                                  if (value != null) {
                                    _changeCategory(index, value);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'ערוך',
                          onPressed: () => _editDraft(index),
                          icon: const Icon(Icons.edit_rounded),
                        ),
                        IconButton(
                          tooltip: 'הסר',
                          onPressed: () => _removeDraft(index),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _addAll,
                icon: const Icon(Icons.playlist_add_check_rounded),
                label: Text('הוסף ${_drafts.length} מוצרים לרשימה'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
