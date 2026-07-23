import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../families/application/family_controller.dart';
import '../application/shopping_controller.dart';
import '../domain/category_classifier.dart';
import '../domain/shopping_category.dart';

class AddShoppingItemScreen extends ConsumerStatefulWidget {
  const AddShoppingItemScreen({super.key});

  @override
  ConsumerState<AddShoppingItemScreen> createState() =>
      _AddShoppingItemScreenState();
}

class _AddShoppingItemScreenState extends ConsumerState<AddShoppingItemScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _note = TextEditingController();
  ShoppingCategory? _category;

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? familyId = ref.watch(familyControllerProvider).activeFamilyId;
    final activeList = ref.watch(activeShoppingListProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('הוספת מוצר · ${activeList?.name ?? ''}'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            AppCard(
              child: Column(
                children: <Widget>[
                  AppTextField(
                    controller: _name,
                    label: 'שם המוצר',
                    icon: Icons.shopping_basket_rounded,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _quantity,
                    label: 'כמות',
                    icon: Icons.numbers_rounded,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _note,
                    label: 'הערה',
                    icon: Icons.notes_rounded,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<ShoppingCategory>(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'מחלקה'),
                    hint: const Text('זיהוי אוטומטי'),
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
                      setState(() {
                        _category = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppPrimaryButton(
              label: 'הוסף לרשימה',
              onPressed: familyId == null
                  ? null
                  : () async {
                      final bool success = await ref
                          .read(shoppingControllerProvider.notifier)
                          .addItem(
                            familyId: familyId,
                            name: _name.text,
                            quantity: _quantity.text,
                            note: _note.text,
                            category: _category ??
                                CategoryClassifier.classify(_name.text),
                          );
                      if (success && context.mounted) {
                        context.pop();
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
