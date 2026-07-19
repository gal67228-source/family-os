import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/more/presentation/more_screen.dart';
import '../features/shopping/presentation/shopping_screen.dart';
import '../features/tasks/presentation/tasks_screen.dart';
import '../features/today/presentation/today_screen.dart';
import 'shell_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/today',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (
        BuildContext context,
        GoRouterState state,
        StatefulNavigationShell navigationShell,
      ) {
        return ShellScreen(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/today',
              builder: (BuildContext context, GoRouterState state) {
                return const TodayScreen();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/tasks',
              builder: (BuildContext context, GoRouterState state) {
                return const TasksScreen();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/shopping',
              builder: (BuildContext context, GoRouterState state) {
                return const ShoppingScreen();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/more',
              builder: (BuildContext context, GoRouterState state) {
                return const MoreScreen();
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
