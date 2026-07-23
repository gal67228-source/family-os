import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../application/shopping_controller.dart';
import '../domain/shopping_category.dart';
import '../domain/shopping_item.dart';

class ShoppingScreen extends ConsumerWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ShoppingState state = ref.watch(shoppingControllerProvider);
    final List<ShoppingItem> items =
        ref.watch(activeFamilyShoppingItemsProvider);
    final int checkedCount =
        items.where((ShoppingItem item) => item.isChecked).length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('קניות'),
          actions: <Widget>[
            IconButton(
              tooltip: 'הוספה קולית',
              onPressed: () => context.push('/shopping/voice'),
              icon: const Icon(Icons.mic_rounded),
            ),
            IconButton(
              tooltip: 'מוצרים קבועים',
              onPressed: () => context.push('/shopping/recurring'),
              icon: const Icon(Icons.repeat_rounded),
            ),
            IconButton(
              tooltip: 'מצב קנייה',
              onPressed:
                  items.isEmpty ? null : () => context.push('/shopping/store'),
              icon: const Icon(Icons.storefront_rounded),
            ),
          ],
        ),
        body: state.isLoading
            ? const LoadingView(message: 'טוען רשימת קניות...')
            : items.isEmpty
                ? EmptyState(
                    icon: Icons.shopping_cart_outlined,
                    title: 'רשימת הקניות ריקה',
                    message: 'הוסף מוצרים או טען מוצרים קבועים לרשימה.',
                    action: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: <Widget>[
                        FilledButton.icon(
                          onPressed: () => context.push('/shopping/add'),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('הוסף מוצר'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/shopping/voice'),
                          icon: const Icon(Icons.mic_rounded),
                          label: const Text('הכתבה קולית'),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                    children: <Widget>[
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.shopping_cart_rounded,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${items.length - checkedCount} פריטים נותרו',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                Text('$checkedCount/${items.length}'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: items.isEmpty
                                  ? 0
                                  : checkedCount / items.length,
                              minHeight: 7,
                              borderRadius: BorderRadius.circular(99),
                              backgroundColor: const Color(0xFFE4EAF4),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.secondary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        context.push('/shopping/store'),
                                    icon: const Icon(
                                      Icons.storefront_rounded,
                                    ),
                                    label: const Text('מצב קנייה'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: () =>
                                        context.push('/shopping/add'),
                                    icon: const Icon(Icons.add_rounded),
                                    label: const Text('הוסף מוצר'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      for (final ShoppingCategory category
                          in ShoppingCategory.values)
                        if (items.any(
                          (ShoppingItem item) => item.category == category,
                        )) ...<Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, top: 6),
                            child: Text(
                              category.label,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          AppCard(
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: <Widget>[
                                for (final ShoppingItem item in items.where(
                                  (ShoppingItem value) =>
                                      value.category == category,
                                ))
                                  ListTile(
                                    leading: Checkbox(
                                      value: item.isChecked,
                                      activeColor: AppColors.secondary,
                                      onChanged: (_) => ref
                                          .read(
                                            shoppingControllerProvider.notifier,
                                          )
                                          .toggleItem(item.id),
                                    ),
                                    title: Text(
                                      item.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        decoration: item.isChecked
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    subtitle: [
                                      item.quantity,
                                      item.note,
                                    ].where((String value) {
                                      return value.isNotEmpty;
                                    }).isEmpty
                                        ? null
                                        : Text(
                                            <String>[
                                              item.quantity,
                                              item.note,
                                            ]
                                                .where(
                                                  (String value) =>
                                                      value.isNotEmpty,
                                                )
                                                .join(' · '),
                                          ),
                                    trailing: IconButton(
                                      tooltip: 'מחיקה',
                                      onPressed: () => ref
                                          .read(
                                            shoppingControllerProvider.notifier,
                                          )
                                          .deleteItem(item.id),
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                    ],
                  ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/shopping/voice'),
          icon: const Icon(Icons.mic_rounded),
          label: const Text('הוסף בקול'),
        ),
      ),
    );
  }
}
