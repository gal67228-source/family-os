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

class _ProductMatch {
  const _ProductMatch({
    required this.length,
    required this.spokenName,
  });

  final int length;
  final String spokenName;
}

abstract final class VoiceShoppingParser {
  static const Map<String, int> _hebrewNumbers = <String, int>{
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
    'זוג': 2,
  };

  static const List<String> _knownProducts = <String>[
    // Multi-word products must appear before single-word products.
    'גבינה צהובה',
    'גבינה לבנה',
    'חלב שלושה אחוז',
    'חלב 3 אחוז',
    'חלב אחוז אחד',
    'חזה עוף',
    'בשר טחון',
    'נייר טואלט',
    'נייר אפייה',
    'נוזל כלים',
    'אבקת כביסה',
    'מרכך כביסה',
    'משחת שיניים',
    'שמן זית',
    'קפה נמס',
    'תפוח אדמה',
    'פלפל שחור',
    'אבקת אפייה',
    'חול לחתול',
    'מזון לכלב',
    'מזון לחתול',
    'טונה טרייה',
    'טונה טרי',

    // Dairy and cheese.
    'חלב',
    'יוגורט',
    'שמנת',
    'לבן',
    'גבינה',
    'גבינות',
    'קוטג',
    "קוטג'",
    'בולגרית',
    'מוצרלה',

    // Eggs, bakery and pantry.
    'ביצים',
    'ביצה',
    'לחם',
    'לחמניות',
    'לחמניה',
    'פיתה',
    'פיתות',
    'חלה',
    'בגט',
    'פסטה',
    'אורז',
    'קוסקוס',
    'פתיתים',
    'עדשים',
    'שעועית',
    'קמח',
    'סוכר',
    'מלח',
    'שמרים',

    // Vegetables.
    'עגבניות',
    'עגבניה',
    'עגבנייה',
    'מלפפונים',
    'מלפפון',
    'חסה',
    'בצל',
    'בצלים',
    'גזר',
    'גזרים',
    'פלפל',
    'פלפלים',
    'קישוא',
    'קישואים',
    'ברוקולי',

    // Fruit.
    'בננות',
    'בננה',
    'תפוחים',
    'תפוח',
    'תפוזים',
    'תפוז',
    'ענבים',
    'אבטיח',
    'מלון',
    'אגסים',
    'אגס',
    'תותים',
    'תות',

    // Meat, fish and canned products.
    'עוף',
    'בשר',
    'שניצל',
    'קציצות',
    'נקניק',
    'נקניקיות',
    'דג',
    'דגים',
    'סלמון',
    'טונה',
    'תירס',
    'אפונה',
    'שימורים',

    // Breakfast and snacks.
    'קורנפלקס',
    'גרנולה',
    'שוקולד',
    'במבה',
    'ביסלי',
    'חטיף',
    'חטיפים',
    'עוגיות',

    // Drinks.
    'מים',
    'קולה',
    'מיץ',
    'סודה',

    // Toiletries and cleaning.
    'מגבונים',
    'שמפו',
    'סבון',
    'אקונומיקה',
    'מרכך',
    'ניקוי',

    // Baby and pets.
    'טיטולים',
    'חיתולים',
    'מטרנה',
    'סימילאק',
  ];

  static final List<List<String>> _knownProductTokens = _knownProducts
      .map(
        (String product) =>
            product.split(RegExp(r'\s+')).map(_normalizeToken).toList(),
      )
      .toList();

  static List<VoiceShoppingDraft> parse(String transcript) {
    final String cleaned = transcript
        .replaceAll(RegExp(r'[\n;.]'), ',')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.isEmpty) {
      return <VoiceShoppingDraft>[];
    }

    final List<VoiceShoppingDraft> result = <VoiceShoppingDraft>[];

    for (final String chunk in cleaned.split(',')) {
      final List<String> tokens = chunk
          .trim()
          .split(RegExp(r'\s+'))
          .where((String token) => token.isNotEmpty)
          .toList();

      result.addAll(_parseTokenSequence(tokens));
    }

    return result;
  }

  static List<VoiceShoppingDraft> _parseTokenSequence(
    List<String> rawTokens,
  ) {
    final List<VoiceShoppingDraft> result = <VoiceShoppingDraft>[];
    final List<String> tokens = rawTokens
        .map(_removeStandalonePunctuation)
        .where((String token) => token.isNotEmpty)
        .toList();

    int index = 0;
    String pendingQuantity = '';

    while (index < tokens.length) {
      String token = tokens[index];

      if (_isCommandWord(token) || _isConnector(token)) {
        index++;
        continue;
      }

      final String? quantity = _quantityFromToken(token);
      if (quantity != null) {
        pendingQuantity = quantity;
        index++;
        continue;
      }

      token = _stripLeadingConnector(token);
      tokens[index] = token;

      final _ProductMatch? match = _findLongestProduct(tokens, index);

      if (match != null) {
        result.add(
          VoiceShoppingDraft(
            name: match.spokenName,
            quantity: pendingQuantity,
            category: CategoryClassifier.classify(match.spokenName),
          ),
        );
        pendingQuantity = '';
        index += match.length;
        continue;
      }

      // Unknown words are still preserved as individual products.
      // This prevents one long unrecognized sentence from becoming
      // a single shopping item.
      result.add(
        VoiceShoppingDraft(
          name: token,
          quantity: pendingQuantity,
          category: CategoryClassifier.classify(token),
        ),
      );
      pendingQuantity = '';
      index++;
    }

    return result;
  }

  static _ProductMatch? _findLongestProduct(
    List<String> tokens,
    int start,
  ) {
    _ProductMatch? best;

    for (final List<String> productTokens in _knownProductTokens) {
      if (start + productTokens.length > tokens.length) {
        continue;
      }

      bool matches = true;
      for (int offset = 0; offset < productTokens.length; offset++) {
        final String spoken = _normalizeToken(tokens[start + offset]);
        if (spoken != productTokens[offset]) {
          matches = false;
          break;
        }
      }

      if (!matches) {
        continue;
      }

      if (best == null || productTokens.length > best.length) {
        best = _ProductMatch(
          length: productTokens.length,
          spokenName:
              tokens.sublist(start, start + productTokens.length).join(' '),
        );
      }
    }

    return best;
  }

  static String? _quantityFromToken(String token) {
    final String normalized = _normalizeToken(token);
    final int? numeric = int.tryParse(normalized);
    if (numeric != null) {
      return numeric.toString();
    }

    final int? hebrew = _hebrewNumbers[normalized];
    return hebrew?.toString();
  }

  static bool _isConnector(String token) {
    final String normalized = _normalizeToken(token);
    return normalized == 'ו' ||
        normalized == 'וגם' ||
        normalized == 'גם' ||
        normalized == 'ואז' ||
        normalized == 'ואחרכך';
  }

  static bool _isCommandWord(String token) {
    final String normalized = _normalizeToken(token);
    return normalized == 'תוסיף' ||
        normalized == 'הוסף' ||
        normalized == 'תוסיפי' ||
        normalized == 'צריך' ||
        normalized == 'צריכה' ||
        normalized == 'רוצה';
  }

  static String _stripLeadingConnector(String token) {
    final String normalized = _normalizeToken(token);
    if (!normalized.startsWith('ו') || normalized.length < 2) {
      return token;
    }

    final String withoutVav = normalized.substring(1);
    final bool knownStart = _knownProductTokens.any(
      (List<String> product) =>
          product.isNotEmpty && product.first == withoutVav,
    );

    return knownStart ? token.substring(1) : token;
  }

  static String _removeStandalonePunctuation(String token) {
    return token
        .replaceAll(
          RegExp(r'^[,!?]+|[,!?]+$'),
          '',
        )
        .trim();
  }

  static String _normalizeToken(String token) {
    return token.trim().toLowerCase().replaceAll('׳', "'").replaceAll('״', '"');
  }
}
