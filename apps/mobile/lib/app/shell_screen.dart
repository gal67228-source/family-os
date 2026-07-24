import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/design/app_colors.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _FamilyNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onSelected: (int index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class _FamilyNavigationBar extends StatelessWidget {
  const _FamilyNavigationBar({
    required this.currentIndex,
    required this.onSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;

  static const List<_NavigationItem> _items = <_NavigationItem>[
    _NavigationItem(
      icon: Icons.home_rounded,
      label: 'בית',
      color: AppColors.primary,
    ),
    _NavigationItem(
      icon: Icons.calendar_month_rounded,
      label: 'יומן',
      color: Color(0xFF7C3AED),
    ),
    _NavigationItem(
      icon: Icons.shopping_cart_rounded,
      label: 'קניות',
      color: AppColors.secondary,
    ),
    _NavigationItem(
      icon: Icons.task_alt_rounded,
      label: 'משימות',
      color: Color(0xFFF59E0B),
    ),
    _NavigationItem(
      icon: Icons.grid_view_rounded,
      label: 'עוד',
      color: Color(0xFF64748B),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8 + bottomInset),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.55),
          ),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: List<Widget>.generate(_items.length, (int index) {
          final _NavigationItem item = _items[index];
          final bool selected = index == currentIndex;

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: selected
                      ? item.color.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      item.icon,
                      color: selected ? item.color : AppColors.textSecondary,
                      size: selected ? 25 : 23,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color:
                                selected ? item.color : AppColors.textSecondary,
                            fontWeight:
                                selected ? FontWeight.w900 : FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;
}
