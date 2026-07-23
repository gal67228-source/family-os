import 'shopping_category.dart';

abstract final class CategoryClassifier {
  static ShoppingCategory classify(String productName) {
    final String value = productName.trim().toLowerCase();

    const Map<ShoppingCategory, List<String>> keywords =
        <ShoppingCategory, List<String>>{
      ShoppingCategory.vegetables: <String>[
        'עגבנ',
        'מלפפון',
        'חסה',
        'בצל',
        'גזר',
        'פלפל',
        'תפוח אדמה',
        'קישוא',
        'ברוקולי',
      ],
      ShoppingCategory.fruits: <String>[
        'בננה',
        'תפוח',
        'תפוז',
        'ענבים',
        'אבטיח',
        'מלון',
        'אגס',
        'תות',
      ],
      ShoppingCategory.dairy: <String>[
        'חלב',
        'יוגורט',
        'שמנת',
        'לבן',
      ],
      ShoppingCategory.cheese: <String>[
        'גבינ',
        'קוטג',
        'בולגרית',
        'צהובה',
        'מוצרלה',
      ],
      ShoppingCategory.meat: <String>[
        'עוף',
        'בשר',
        'שניצל',
        'קציצ',
        'נקניק',
      ],
      ShoppingCategory.fish: <String>[
        'דג',
        'סלמון',
        'טונה טרי',
      ],
      ShoppingCategory.bakery: <String>[
        'לחם',
        'לחמנ',
        'פיתה',
        'חלה',
        'בגט',
      ],
      ShoppingCategory.eggs: <String>['ביצ'],
      ShoppingCategory.canned: <String>[
        'שימורים',
        'תירס',
        'טונה',
        'אפונה בקופסה',
      ],
      ShoppingCategory.pantry: <String>[
        'פסטה',
        'אורז',
        'עדשים',
        'שעועית',
        'קוסקוס',
        'פתיתים',
      ],
      ShoppingCategory.cereals: <String>[
        'קורנפלקס',
        'גרנולה',
        'דגני',
      ],
      ShoppingCategory.snacks: <String>[
        'שוקולד',
        'במבה',
        'ביסלי',
        'חטיף',
        'עוגיות',
      ],
      ShoppingCategory.baking: <String>[
        'קמח',
        'סוכר',
        'מלח',
        'פלפל שחור',
        'אבקת אפייה',
        'שמרים',
      ],
      ShoppingCategory.drinks: <String>[
        'מים',
        'קולה',
        'מיץ',
        'סודה',
        'שתייה',
      ],
      ShoppingCategory.toiletries: <String>[
        'נייר טואלט',
        'מגבונים',
        'שמפו',
        'סבון',
        'משחת שיניים',
      ],
      ShoppingCategory.cleaning: <String>[
        'אקונומיקה',
        'נוזל כלים',
        'כביסה',
        'ניקוי',
        'מרכך',
      ],
      ShoppingCategory.pets: <String>[
        'כלב',
        'חתול',
        'חול לחתול',
        'מזון לחיות',
      ],
      ShoppingCategory.baby: <String>[
        'טיטולים',
        'חיתולים',
        'מטרנה',
        'סימילאק',
        'תינוק',
      ],
    };

    for (final MapEntry<ShoppingCategory, List<String>> entry
        in keywords.entries) {
      if (entry.value.any(value.contains)) {
        return entry.key;
      }
    }
    return ShoppingCategory.other;
  }
}
