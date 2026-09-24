import 'package:go_router/go_router.dart';

import '../../navigation_shell.dart';

import '../../../features/home/home_page.dart';
import '../../../features/search/search_page.dart';
import '../../../features/library/library_page.dart';
import '../../../features/player/queue_page.dart';
import '../../../features/settings/settings_page.dart';
import '../../../features/library/pages/songs_page.dart';

import '../../../features/settings/customization/home_customization_page.dart';
import '../../../features/settings/customization/library_customization_page.dart';
import '../../../features/settings/customization/search_customization_page.dart';
import '../../../features/settings/customization/player_customization_page.dart';
import '../../../features/settings/customization/sidebar_customization_page.dart';
import '../../../features/settings/customization/theme_customization_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const NavigationShell(
        child: HomePage(),
      ),
    ),

    GoRoute(
      path: '/search',
      builder: (context, state) => const NavigationShell(
        child: SearchPage(),
      ),
    ),

    GoRoute(
      path: '/library',
      builder: (context, state) => const NavigationShell(
        child: LibraryPage(),
      ),
    ),

    GoRoute(
      path: '/settings',
      builder: (context, state) => const NavigationShell(
        child: SettingsPage(),
      ),
    ),

    GoRoute(
      path: '/queue',
      builder: (context, state) => const QueuePage(),
    ),

    GoRoute(
      path: '/songs',
      builder: (context, state) => const SongsPage(),
    ),

    GoRoute(
      path: '/settings/customization/home',
      builder: (context, state) => const HomeCustomizationPage(),
    ),

    GoRoute(
      path: '/settings/customization/library',
      builder: (context, state) => const LibraryCustomizationPage(),
    ),

    GoRoute(
      path: '/settings/customization/search',
      builder: (context, state) => const SearchCustomizationPage(),
    ),

    GoRoute(
      path: '/settings/customization/player',
      builder: (context, state) => const PlayerCustomizationPage(),
    ),

    GoRoute(
      path: '/settings/customization/sidebar',
      builder: (context, state) => const SidebarCustomizationPage(),
    ),

    GoRoute(
      path: '/settings/customization/theme',
      builder: (context, state) => const ThemeCustomizationPage(),
    ),
  ],
);