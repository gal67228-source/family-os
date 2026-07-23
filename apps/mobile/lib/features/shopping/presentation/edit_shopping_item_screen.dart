import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/shopping_controller.dart';
import '../domain/shopping_category.dart';
import '../domain/shopping_item.dart';

class EditShoppingItemScreen extends ConsumerStatefulWidget {
  const EditShoppingItemScreen({
    required this.itemId,
    super.key,
  });

  final String itemId;

  @override
  ConsumerState<EditShoppingItemScreen> createState() =>
      _EditShoppingItemScreenState();
}

class _EditShoppingItemScreenState
    extends ConsumerState<EditShoppingItemScreen> {
  late final TextEditingController _name;
  late final TextEditingController _quantity;
  late final TextEditingController _note;
  ShoppingCategory? _category;
  bool _initialized = false;

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    _note.dispose();
    super.dispose();
  }

  void _initialize(ShoppingItem item) {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _name = TextEditingController(text: item.name);
    _quantity = TextEditingController(text: item.quantity);
    _note = TextEditingController(text: item.note);
    _category = item.category;
  }

  @override
  Widget build(BuildContext context) {
    final List<ShoppingItem> items =
        ref.watch(activeFamilyShoppingItemsProvider);
    final ShoppingItem? item = items.cast<ShoppingItem?>().firstWhere(
          (ShoppingItem? value) => value?.id == widget.itemId,
          orElse: () => null,
        );

    if (item == null) {
      return const Scaffold(
        body: Center(child: Text('המוצר לא נמצא')),
      );
    }

    _initialize(item);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('עריכת מוצר')),
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
                        setState(() {
                          _category = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppPrimaryButton(
              label: 'שמור שינויים',
              onPressed: () async {
                await ref.read(shoppingControllerProvider.notifier).updateItem(
                      itemId: item.id,
                      name: _name.text,
                      quantity: _quantity.text,
                      note: _note.text,
                      category: _category ?? item.category,
                    );
                if (context.mounted) {
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
