enum ShoppingCategory {
  vegetables,
  fruits,
  dairy,
  cheese,
  meat,
  fish,
  bakery,
  eggs,
  canned,
  pantry,
  cereals,
  snacks,
  baking,
  drinks,
  toiletries,
  cleaning,
  pets,
  baby,
  other,
}

extension ShoppingCategoryDetails on ShoppingCategory {
  String get label {
    switch (this) {
      case ShoppingCategory.vegetables:
        return 'ירקות';
      case ShoppingCategory.fruits:
        return 'פירות';
      case ShoppingCategory.dairy:
        return 'חלב ומוצרי חלב';
      case ShoppingCategory.cheese:
        return 'גבינות';
      case ShoppingCategory.meat:
        return 'בשר ועוף';
      case ShoppingCategory.fish:
        return 'דגים';
      case ShoppingCategory.bakery:
        return 'מאפייה';
      case ShoppingCategory.eggs:
        return 'ביצים';
      case ShoppingCategory.canned:
        return 'שימורים';
      case ShoppingCategory.pantry:
        return 'פסטה, אורז וקטניות';
      case ShoppingCategory.cereals:
        return 'דגני בוקר';
      case ShoppingCategory.snacks:
        return 'חטיפים ומתוקים';
      case ShoppingCategory.baking:
        return 'תבלינים ואפייה';
      case ShoppingCategory.drinks:
        return 'שתייה';
      case ShoppingCategory.toiletries:
        return 'נייר וטואלטיקה';
      case ShoppingCategory.cleaning:
        return 'חומרי ניקוי';
      case ShoppingCategory.pets:
        return 'חיות מחמד';
      case ShoppingCategory.baby:
        return 'תינוקות';
      case ShoppingCategory.other:
        return 'אחר';
    }
  }

  int get sortOrder => ShoppingCategory.values.indexOf(this);
}
