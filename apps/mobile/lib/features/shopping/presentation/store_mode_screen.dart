import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/app_colors.dart';
import '../../families/application/family_controller.dart';
import '../application/shopping_controller.dart';
import '../domain/shopping_category.dart';
import '../domain/shopping_item.dart';

class StoreModeScreen extends ConsumerWidget {
  const StoreModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? familyId = ref.watch(familyControllerProvider).activeFamilyId;
    final List<ShoppingItem> items =
        ref.watch(activeFamilyShoppingItemsProvider);
    final int checked =
        items.where((ShoppingItem item) => item.isChecked).length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('מצב קנייה בסופר'),
          actions: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  '$checked/${items.length}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            LinearProgressIndicator(
              value: items.isEmpty ? 0 : checked / items.length,
              minHeight: 8,
              backgroundColor: const Color(0xFFE4EAF4),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.secondary,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                children: <Widget>[
                  for (final ShoppingCategory category
                      in ShoppingCategory.values)
                    if (items.any(
                      (ShoppingItem item) =>
                          item.category == category && !item.isChecked,
                    )) ...<Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          category.label,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      for (final ShoppingItem item in items.where(
                        (ShoppingItem value) =>
                            value.category == category && !value.isChecked,
                      ))
                        Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => ref
                                .read(
                                  shoppingControllerProvider.notifier,
                                )
                                .toggleItem(item.id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 20,
                              ),
                              child: Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.circle_outlined,
                                    size: 30,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (item.quantity.isNotEmpty)
                                    Text(
                                      item.quantity,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  if (items.isNotEmpty &&
                      items.every(
                        (ShoppingItem item) => item.isChecked,
                      ))
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.celebration_rounded,
                            size: 64,
                            color: AppColors.secondary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'כל המוצרים סומנו!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton.icon(
              onPressed: familyId == null || checked == 0
                  ? null
                  : () async {
                      await ref
                          .read(shoppingControllerProvider.notifier)
                          .clearChecked(familyId);
                      if (context.mounted) {
                        context.go('/shopping');
                      }
                    },
              icon: const Icon(Icons.done_all_rounded),
              label: Text(
                checked == 0
                    ? 'סמן מוצרים כדי לסיים'
                    : 'סיום קנייה וניקוי $checked מסומנים',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
