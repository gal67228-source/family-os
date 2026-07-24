import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../calendar/application/calendar_controller.dart';
import '../../shopping/application/shopping_controller.dart';
import '../../tasks/application/task_controller.dart';
import 'notification_service.dart';

class NotificationCoordinator extends ConsumerStatefulWidget {
  const NotificationCoordinator({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<NotificationCoordinator> createState() =>
      _NotificationCoordinatorState();
}

class _NotificationCoordinatorState
    extends ConsumerState<NotificationCoordinator> {
  String _lastSignature = '';

  @override
  Widget build(BuildContext context) {
    final CalendarState calendar = ref.watch(calendarControllerProvider);
    final TaskState tasks = ref.watch(taskControllerProvider);
    final ShoppingState shopping = ref.watch(shoppingControllerProvider);

    final String signature = <Object>[
      calendar.isLoading,
      calendar.events.length,
      for (final event in calendar.events)
        '${event.id}:${event.start}:${event.reminder.name}',
      tasks.isLoading,
      tasks.tasks.length,
      for (final task in tasks.tasks)
        '${task.id}:${task.dueDate}:${task.isCompleted}',
      shopping.isLoading,
      shopping.recurringProducts.length,
      shopping.items.length,
      for (final product in shopping.recurringProducts)
        '${product.id}:${product.lastAddedAt}',
    ].join('|');

    if (!calendar.isLoading &&
        !tasks.isLoading &&
        !shopping.isLoading &&
        signature != _lastSignature) {
      _lastSignature = signature;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await NotificationService.instance
              .initialize()
              .timeout(const Duration(seconds: 4));

          await NotificationService.instance.sync(
            events: calendar.events,
            tasks: tasks.tasks,
            recurringProducts: shopping.recurringProducts,
            shoppingItems: shopping.items,
          );
        } catch (_) {
          // Notifications must never block or crash the application UI.
        }
      });
    }

    return widget.child;
  }
}
