import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../families/application/family_controller.dart';
import '../application/shopping_controller.dart';
import '../domain/shopping_category.dart';
import '../domain/shopping_item.dart';
import '../domain/shopping_list.dart';

class ShoppingScreen extends ConsumerStatefulWidget {
  const ShoppingScreen({super.key});

  @override
  ConsumerState<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends ConsumerState<ShoppingScreen> {
  bool _prepared = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prepared) return;
    _prepared = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final String? familyId =
          ref.read(familyControllerProvider).activeFamilyId;
      if (familyId != null) {
        await ref
            .read(shoppingControllerProvider.notifier)
            .ensureFamilyReady(familyId);
      }
    });
  }

  Future<void> _createList(String familyId) async {
    final TextEditingController controller = TextEditingController();
    final String? name = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('רשימה חדשה'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'שם הרשימה',
            hintText: 'לדוגמה: פארם',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('ביטול'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('צור'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null) {
      await ref
          .read(shoppingControllerProvider.notifier)
          .createList(familyId, name);
    }
  }

  Future<void> _manageList(
    String familyId,
    ShoppingList list,
    int listCount,
  ) async {
    final String? action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('שנה שם'),
              onTap: () => Navigator.pop(context, 'rename'),
            ),
            ListTile(
              enabled: listCount > 1,
              leading: const Icon(Icons.delete_outline_rounded),
              title: const Text('מחק רשימה'),
              subtitle: listCount <= 1
                  ? const Text('חייבת להישאר לפחות רשימה אחת')
                  : null,
              onTap:
                  listCount > 1 ? () => Navigator.pop(context, 'delete') : null,
            ),
          ],
        ),
      ),
    );

    if (!mounted) return;
    if (action == 'rename') {
      final TextEditingController controller =
          TextEditingController(text: list.name);
      final String? name = await showDialog<String>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('שינוי שם'),
          content: TextField(controller: controller, autofocus: true),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('ביטול'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: const Text('שמור'),
            ),
          ],
        ),
      );
      controller.dispose();
      if (name != null) {
        await ref
            .read(shoppingControllerProvider.notifier)
            .renameList(list.id, name);
      }
    } else if (action == 'delete') {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('למחוק את הרשימה?'),
          content: const Text(
            'כל המוצרים והמוצרים הקבועים ברשימה יימחקו.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('ביטול'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('מחק'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await ref
            .read(shoppingControllerProvider.notifier)
            .deleteList(familyId, list.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ShoppingState state = ref.watch(shoppingControllerProvider);
    final String? familyId = ref.watch(familyControllerProvider).activeFamilyId;
    final List<ShoppingList> lists =
        ref.watch(activeFamilyShoppingListsProvider);
    final ShoppingList? activeList = ref.watch(activeShoppingListProvider);
    final List<ShoppingItem> items =
        ref.watch(activeFamilyShoppingItemsProvider);
    final int checkedCount =
        items.where((ShoppingItem item) => item.isChecked).length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(activeList?.name ?? 'קניות'),
          actions: <Widget>[
            IconButton(
              tooltip: 'מוצרים קבועים',
              onPressed: () => context.push('/shopping/recurring'),
              icon: const Icon(Icons.repeat_rounded),
            ),
            IconButton(
              tooltip: 'רשימה חדשה',
              onPressed: familyId == null ? null : () => _createList(familyId),
              icon: const Icon(Icons.playlist_add_rounded),
            ),
          ],
        ),
        body: state.isLoading || activeList == null
            ? const LoadingView(message: 'טוען רשימות קניות...')
            : Column(
                children: <Widget>[
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      scrollDirection: Axis.horizontal,
                      itemCount: lists.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (BuildContext context, int index) {
                        final ShoppingList list = lists[index];
                        final bool selected = list.id == activeList.id;
                        return InputChip(
                          label: Text(list.name),
                          selected: selected,
                          onSelected: (_) => ref
                              .read(shoppingControllerProvider.notifier)
                              .selectList(list.id),
                          onPressed: () => ref
                              .read(shoppingControllerProvider.notifier)
                              .selectList(list.id),
                          onDeleted: selected && familyId != null
                              ? () => _manageList(
                                    familyId,
                                    list,
                                    lists.length,
                                  )
                              : null,
                          deleteIcon: const Icon(Icons.more_horiz_rounded),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: items.isEmpty
                        ? EmptyState(
                            icon: Icons.shopping_cart_outlined,
                            title: 'הרשימה ריקה',
                            message: 'אפשר להוסיף מוצר ידנית או בקול.',
                            action: Row(
                              children: <Widget>[
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: () =>
                                        context.push('/shopping/add'),
                                    icon: const Icon(Icons.add_rounded),
                                    label: const Text('הוסף מוצר'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: FilledButton.tonalIcon(
                                    onPressed: () =>
                                        context.push('/shopping/voice'),
                                    icon: const Icon(Icons.mic_rounded),
                                    label: const Text('הוסף בקול'),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              4,
                              16,
                              36,
                            ),
                            children: <Widget>[
                              AppCard(
                                child: Column(
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
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                        ),
                                        Text('$checkedCount/${items.length}'),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    LinearProgressIndicator(
                                      value: checkedCount / items.length,
                                      minHeight: 7,
                                      borderRadius: BorderRadius.circular(99),
                                      backgroundColor: const Color(0xFFE4EAF4),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        AppColors.secondary,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () =>
                                            context.push('/shopping/store'),
                                        icon: const Icon(
                                          Icons.storefront_rounded,
                                        ),
                                        label: const Text('מצב קנייה'),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: FilledButton.icon(
                                            onPressed: () =>
                                                context.push('/shopping/add'),
                                            icon: const Icon(Icons.add_rounded),
                                            label: const Text('הוסף מוצר'),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: FilledButton.tonalIcon(
                                            onPressed: () =>
                                                context.push('/shopping/voice'),
                                            icon: const Icon(Icons.mic_rounded),
                                            label: const Text('הוסף בקול'),
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
                                if (items.any((ShoppingItem item) =>
                                    item.category == category)) ...<Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 8,
                                      top: 6,
                                    ),
                                    child: Text(
                                      category.label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                  AppCard(
                                    padding: EdgeInsets.zero,
                                    child: Column(
                                      children: <Widget>[
                                        for (final ShoppingItem item
                                            in items.where(
                                          (ShoppingItem value) =>
                                              value.category == category,
                                        ))
                                          ListTile(
                                            onTap: () => context.push(
                                              '/shopping/edit/${item.id}',
                                            ),
                                            leading: Checkbox(
                                              value: item.isChecked,
                                              activeColor: AppColors.secondary,
                                              onChanged: (_) => ref
                                                  .read(
                                                    shoppingControllerProvider
                                                        .notifier,
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
                                            subtitle: <String>[
                                              item.quantity,
                                              item.note,
                                            ]
                                                    .where((String value) =>
                                                        value.isNotEmpty)
                                                    .isEmpty
                                                ? null
                                                : Text(<String>[
                                                    item.quantity,
                                                    item.note,
                                                  ]
                                                    .where((String value) =>
                                                        value.isNotEmpty)
                                                    .join(' · ')),
                                            trailing: IconButton(
                                              tooltip: 'מחיקה',
                                              onPressed: () => ref
                                                  .read(
                                                    shoppingControllerProvider
                                                        .notifier,
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
                  ),
                ],
              ),
      ),
    );
  }
}
