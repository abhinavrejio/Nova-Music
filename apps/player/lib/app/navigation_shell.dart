import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/player/widgets/mini_player.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: widget.child,
          ),

          const MiniPlayer(),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_music),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;

            case 1:
              context.go('/search');
              break;

            case 2:
              context.go('/library');
              break;

            case 3:
              context.go('/settings');
              break;
          }

          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}