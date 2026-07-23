import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../families/application/family_controller.dart';
import '../application/shopping_controller.dart';
import '../domain/category_classifier.dart';
import '../domain/recurring_product.dart';
import '../domain/shopping_category.dart';

class RecurringProductsScreen extends ConsumerStatefulWidget {
  const RecurringProductsScreen({super.key});

  @override
  ConsumerState<RecurringProductsScreen> createState() =>
      _RecurringProductsScreenState();
}

class _RecurringProductsScreenState
    extends ConsumerState<RecurringProductsScreen> {
  String _listName(List<dynamic> lists, String listId) {
    for (final dynamic list in lists) {
      if (list.id == listId) return list.name as String;
    }
    return 'רשימה';
  }

  final TextEditingController _name = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  RecurrenceCadence _cadence = RecurrenceCadence.weekly;

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? familyId = ref.watch(familyControllerProvider).activeFamilyId;
    final List<RecurringProduct> products =
        ref.watch(activeFamilyRecurringProductsProvider);
    final lists = ref.watch(activeFamilyShoppingListsProvider);
    String? targetListId = ref.watch(activeShoppingListProvider)?.id;
    final int dueCount =
        products.where((RecurringProduct product) => product.isDue).length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('מוצרים קבועים')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: <Widget>[
            AppCard(
              child: Column(
                children: <Widget>[
                  AppTextField(
                    controller: _name,
                    label: 'שם מוצר קבוע',
                    icon: Icons.repeat_rounded,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _quantity,
                    label: 'כמות',
                    icon: Icons.numbers_rounded,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: targetListId,
                    decoration: const InputDecoration(labelText: 'רשימת יעד'),
                    items: lists
                        .map(
                          (list) => DropdownMenuItem<String>(
                            value: list.id,
                            child: Text(list.name),
                          ),
                        )
                        .toList(),
                    onChanged: (String? value) {
                      targetListId = value;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<RecurrenceCadence>(
                    initialValue: _cadence,
                    decoration: const InputDecoration(labelText: 'תדירות'),
                    items: RecurrenceCadence.values
                        .map(
                          (RecurrenceCadence cadence) =>
                              DropdownMenuItem<RecurrenceCadence>(
                            value: cadence,
                            child: Text(cadence.label),
                          ),
                        )
                        .toList(),
                    onChanged: (RecurrenceCadence? value) {
                      if (value != null) {
                        setState(() {
                          _cadence = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: familyId == null
                          ? null
                          : () async {
                              final bool success = await ref
                                  .read(
                                    shoppingControllerProvider.notifier,
                                  )
                                  .addRecurringProduct(
                                    familyId: familyId,
                                    name: _name.text,
                                    quantity: _quantity.text,
                                    category: CategoryClassifier.classify(
                                      _name.text,
                                    ),
                                    cadence: _cadence,
                                    listId: targetListId,
                                    autoAdd: true,
                                  );
                              if (success) {
                                _name.clear();
                                _quantity.clear();
                              }
                            },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('הוסף מוצר קבוע'),
                    ),
                  ),
                ],
              ),
            ),
            if (products.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              AppCard(
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.autorenew_rounded),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        dueCount == 0
                            ? 'כל המוצרים הקבועים מעודכנים'
                            : '$dueCount מוצרים יתווספו אוטומטית '
                                'בפתיחת מסך הקניות',
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            for (final RecurringProduct product in products)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: product.isDue
                            ? AppColors.softOrange
                            : AppColors.softGreen,
                        child: Icon(
                          product.isDue
                              ? Icons.schedule_rounded
                              : Icons.check_rounded,
                          color: product.isDue
                              ? AppColors.accent
                              : AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${product.quantity.isEmpty ? 'ללא כמות' : product.quantity} · '
                              '${product.category.label} · '
                              '${product.cadence.label} · '
                              '${_listName(lists, product.listId)}',
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => ref
                            .read(shoppingControllerProvider.notifier)
                            .deleteRecurringProduct(product.id),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
