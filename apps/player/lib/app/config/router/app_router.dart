import 'package:go_router/go_router.dart';

import '../../navigation_shell.dart';

import '../../../features/home/home_page.dart';
import '../../../features/search/search_page.dart';
import '../../../features/library/library_page.dart';
import '../../../features/player/queue_page.dart';
import '../../../features/settings/settings_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          const NavigationShell(
            child: HomePage(),
          ),
    ),

    GoRoute(
      path: '/search',
      builder: (context, state) =>
          const NavigationShell(
            child: SearchPage(),
          ),
    ),

    GoRoute(
      path: '/library',
      builder: (context, state) =>
          const NavigationShell(
            child: LibraryPage(),
          ),
    ),

    GoRoute(
      path: '/settings',
      builder: (context, state) =>
          const NavigationShell(
            child: SettingsPage(),
          ),
    ),

    GoRoute(
      path: '/queue',
      builder: (context, state) => const QueuePage(),
    ),
  ],
);