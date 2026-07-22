import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/families/presentation/create_family_screen.dart';
import '../features/families/presentation/family_setup_screen.dart';
import '../features/families/presentation/invite_family_screen.dart';
import '../features/families/presentation/join_family_screen.dart';
import '../features/families/presentation/manage_family_screen.dart';
import '../features/families/presentation/switch_family_screen.dart';
import '../features/more/presentation/more_screen.dart';
import '../features/shopping/presentation/shopping_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
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
