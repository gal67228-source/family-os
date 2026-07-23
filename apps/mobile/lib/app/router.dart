import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/calendar/presentation/calendar_screen.dart';
import '../features/calendar/presentation/edit_calendar_event_screen.dart';
import '../features/families/presentation/create_family_screen.dart';
import '../features/families/presentation/family_setup_screen.dart';
import '../features/families/presentation/invite_family_screen.dart';
import '../features/families/presentation/join_family_screen.dart';
import '../features/families/presentation/manage_family_screen.dart';
import '../features/families/presentation/switch_family_screen.dart';
import '../features/more/presentation/more_screen.dart';
import '../features/shopping/presentation/add_shopping_item_screen.dart';
import '../features/shopping/presentation/archived_shopping_lists_screen.dart';
import '../features/shopping/presentation/edit_shopping_item_screen.dart';
import '../features/shopping/presentation/recurring_products_screen.dart';
import '../features/shopping/presentation/store_mode_screen.dart';
import '../features/shopping/presentation/voice_shopping_screen.dart';
import '../features/shopping/presentation/shopping_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/tasks/presentation/create_task_screen.dart';
import '../features/tasks/presentation/tasks_screen.dart';
import '../features/today/presentation/today_screen.dart';
import 'shell_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: <RouteBase>[
    GoRoute(
      path: '/splash',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterScreen();
      },
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (BuildContext context, GoRouterState state) {
        return const ForgotPasswordScreen();
      },
    ),
    GoRoute(
      path: '/family/setup',
      builder: (BuildContext context, GoRouterState state) {
        return const FamilySetupScreen();
      },
    ),
    GoRoute(
      path: '/family/create',
      builder: (BuildContext context, GoRouterState state) {
        return const CreateFamilyScreen();
      },
    ),
    GoRoute(
      path: '/family/join',
      builder: (BuildContext context, GoRouterState state) {
        return const JoinFamilyScreen();
      },
    ),
    GoRoute(
      path: '/family/invite',
      builder: (BuildContext context, GoRouterState state) {
        return const InviteFamilyScreen();
      },
    ),
    GoRoute(
      path: '/family/manage',
      builder: (BuildContext context, GoRouterState state) {
        return const ManageFamilyScreen();
      },
    ),
    GoRoute(
      path: '/family/switch',
      builder: (BuildContext context, GoRouterState state) {
        return const SwitchFamilyScreen();
      },
    ),
    GoRoute(
      path: '/tasks/new',
      builder: (BuildContext context, GoRouterState state) {
        return const CreateTaskScreen();
      },
    ),
    GoRoute(
      path: '/shopping/add',
      builder: (BuildContext context, GoRouterState state) {
        return const AddShoppingItemScreen();
      },
    ),
    GoRoute(
      path: '/shopping/store',
      builder: (BuildContext context, GoRouterState state) {
        return const StoreModeScreen();
      },
    ),
    GoRoute(
      path: '/shopping/recurring',
      builder: (BuildContext context, GoRouterState state) {
        return const RecurringProductsScreen();
      },
    ),
    GoRoute(
      path: '/shopping/voice',
      builder: (BuildContext context, GoRouterState state) {
        return const VoiceShoppingScreen();
      },
    ),
    GoRoute(
      path: '/shopping/edit/:itemId',
      builder: (BuildContext context, GoRouterState state) {
        return EditShoppingItemScreen(
          itemId: state.pathParameters['itemId'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/shopping/archive',
      builder: (BuildContext context, GoRouterState state) {
        return const ArchivedShoppingListsScreen();
      },
    ),
    GoRoute(
      path: '/calendar/new',
      builder: (BuildContext context, GoRouterState state) {
        final String? rawDate = state.uri.queryParameters['date'];
        return EditCalendarEventScreen(
          initialDate: DateTime.tryParse(rawDate ?? ''),
        );
      },
    ),
    GoRoute(
      path: '/calendar/edit/:eventId',
      builder: (BuildContext context, GoRouterState state) {
        return EditCalendarEventScreen(
          eventId: state.pathParameters['eventId'],
        );
      },
    ),
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
              path: '/calendar',
              builder: (BuildContext context, GoRouterState state) {
                return const CalendarScreen();
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
