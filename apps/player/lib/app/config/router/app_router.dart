import 'package:go_router/go_router.dart';

import '../../navigation_shell.dart';

import '../../../features/home/home_page.dart';
import '../../../features/search/search_page.dart';
import '../../../features/library/library_page.dart';
import '../../../features/library/pages/songs_page.dart';
import '../../../features/player/queue_page.dart';
import '../../../features/settings/settings_page.dart';

import '../../../features/settings/personalization/home_personalization_page.dart';
import '../../../features/settings/personalization/library_personalization_page.dart';
import '../../../features/settings/personalization/search_personalization_page.dart';
import '../../../features/settings/personalization/player_personalization_page.dart';
import '../../../features/settings/personalization/sidebar_personalization_page.dart';

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
      path: '/settings/personalization/home',
      builder: (context, state) => const HomePersonalizationPage(),
    ),

    GoRoute(
      path: '/settings/personalization/library',
      builder: (context, state) => const LibraryPersonalizationPage(),
    ),

    GoRoute(
      path: '/settings/personalization/search',
      builder: (context, state) => const SearchPersonalizationPage(),
    ),

    GoRoute(
      path: '/settings/personalization/player',
      builder: (context, state) => const PlayerPersonalizationPage(),
    ),

    GoRoute(
      path: '/settings/personalization/sidebar',
      builder: (context, state) => const SidebarPersonalizationPage(),
    ),

  ],
);
