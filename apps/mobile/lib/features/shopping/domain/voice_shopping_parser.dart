import 'category_classifier.dart';
import 'shopping_category.dart';

class VoiceShoppingDraft {
  const VoiceShoppingDraft({
    required this.name,
    required this.quantity,
    required this.category,
  });

  final String name;
  final String quantity;
  final ShoppingCategory category;
}

abstract final class VoiceShoppingParser {
  static final Map<String, int> _hebrewNumbers = <String, int>{
    'אחד': 1,
    'אחת': 1,
    'שני': 2,
    'שתי': 2,
    'שניים': 2,
    'שתיים': 2,
    'שלושה': 3,
    'שלוש': 3,
    'ארבעה': 4,
    'ארבע': 4,
    'חמישה': 5,
    'חמש': 5,
    'שישה': 6,
    'שש': 6,
    'שבעה': 7,
    'שבע': 7,
    'שמונה': 8,
    'תשעה': 9,
    'תשע': 9,
    'עשרה': 10,
    'עשר': 10,
  };

  static List<VoiceShoppingDraft> parse(String transcript) {
    final String normalized = transcript
        .replaceAll(' וגם ', ',')
        .replaceAll(RegExp(r'\s+ו'), ',')
        .replaceAll(' ואז ', ',')
        .replaceAll(';', ',')
        .replaceAll('.', ',');

    final List<String> parts = normalized
        .split(',')
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toList();

    return parts.map(_parsePart).whereType<VoiceShoppingDraft>().toList();
  }

  static VoiceShoppingDraft? _parsePart(String raw) {
    String value = raw.trim();
    if (value.isEmpty) {
      return null;
    }

    value = value
        .replaceFirst(RegExp(r'^(תוסיף|הוסף|תוסיפי|אני צריך|אני צריכה)\s+'), '')
        .trim();

    String quantity = '';
    final RegExp digitPattern = RegExp(r'^(\d+)\s+(.+)$');
    final Match? digitMatch = digitPattern.firstMatch(value);

    if (digitMatch != null) {
      quantity = digitMatch.group(1) ?? '';
      value = digitMatch.group(2)?.trim() ?? value;
    } else {
      for (final MapEntry<String, int> entry in _hebrewNumbers.entries) {
        final String prefix = '${entry.key} ';
        if (value.startsWith(prefix)) {
          quantity = entry.value.toString();
          value = value.substring(prefix.length).trim();
          break;
        }
      }
    }

    if (value.isEmpty) {
      return null;
    }

    return VoiceShoppingDraft(
      name: value,
      quantity: quantity,
      category: CategoryClassifier.classify(value),
    );
  }
}
