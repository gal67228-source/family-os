import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/design/app_colors.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  void _openQuickAdd(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext context) {
        return const Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'הוספה מהירה',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 20),
                  Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    alignment: WrapAlignment.center,
                    children: <Widget>[
                      _QuickAction(
                        icon: Icons.check_circle_rounded,
                        label: 'משימה',
                        color: AppColors.secondary,
                      ),
                      _QuickAction(
                        icon: Icons.shopping_cart_rounded,
                        label: 'מוצר',
                        color: AppColors.primary,
                      ),
                      _QuickAction(
                        icon: Icons.calendar_month_rounded,
                        label: 'אירוע',
                        color: AppColors.accent,
                      ),
                      _QuickAction(
                        icon: Icons.description_rounded,
                        label: 'מסמך',
                        color: Color(0xFF8B5CF6),
                      ),
                      _QuickAction(
                        icon: Icons.mic_rounded,
                        label: 'בקול',
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      extendBody: true,
      floatingActionButton: navigationShell.currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => _openQuickAdd(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.add_rounded,
                size: 30,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNavigation(
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

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.currentIndex,
    required this.onSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 72,
      color: Theme.of(context).colorScheme.surface,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _NavItem(
            index: 0,
            currentIndex: currentIndex,
            icon: Icons.home_rounded,
            label: 'היום',
            onSelected: onSelected,
          ),
          _NavItem(
            index: 1,
            currentIndex: currentIndex,
            icon: Icons.check_box_rounded,
            label: 'משימות',
            onSelected: onSelected,
          ),
          const SizedBox(width: 48),
          _NavItem(
            index: 2,
            currentIndex: currentIndex,
            icon: Icons.shopping_cart_rounded,
            label: 'קניות',
            onSelected: onSelected,
          ),
          _NavItem(
            index: 3,
            currentIndex: currentIndex,
            icon: Icons.calendar_month_rounded,
            label: 'יומן',
            onSelected: onSelected,
          ),
          _NavItem(
            index: 4,
            currentIndex: currentIndex,
            icon: Icons.menu_rounded,
            label: 'עוד',
            onSelected: onSelected,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
    required this.onSelected,
  });

  final int index;
  final int currentIndex;
  final IconData icon;
  final String label;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final bool selected = index == currentIndex;
    final Color color = selected ? AppColors.primary : const Color(0xFF6B7280);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onSelected(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                color: color,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(height: 7),
          Text(label),
        ],
      ),
    );
  }
}
