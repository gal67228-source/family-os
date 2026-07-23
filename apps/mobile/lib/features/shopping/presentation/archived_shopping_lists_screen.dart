import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../application/shopping_controller.dart';
import '../domain/shopping_list.dart';

class ArchivedShoppingListsScreen extends ConsumerWidget {
  const ArchivedShoppingListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ShoppingList> archived =
        ref.watch(archivedFamilyShoppingListsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('רשימות בארכיון')),
        body: archived.isEmpty
            ? const EmptyState(
                icon: Icons.archive_outlined,
                title: 'הארכיון ריק',
                message: 'רשימות שתועברנה לארכיון יופיעו כאן.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: archived.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (BuildContext context, int index) {
                  final ShoppingList list = archived[index];
                  return AppCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      leading: const Icon(Icons.archive_rounded),
                      title: Text(
                        list.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      trailing: FilledButton.tonalIcon(
                        onPressed: () => ref
                            .read(shoppingControllerProvider.notifier)
                            .restoreList(list.id),
                        icon: const Icon(Icons.unarchive_rounded),
                        label: const Text('שחזר'),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
