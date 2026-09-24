import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/island/nova_island.dart';

import 'widgets/greeting_header.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/continue_listening_section.dart';
import 'widgets/collections_section.dart';
import 'widgets/recently_played_section.dart';
import 'widgets/album_section.dart';
import 'widgets/artists_section.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 1180,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                24,
                24,
                24,
                40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GreetingHeader(),

                  const SizedBox(height: 32),

                  const HomeSearchBar(),

                  const SizedBox(height: 32),

                  const NovaIsland(
                    title: "Continue Listening",
                    subtitle: "No song selected",
                  ),

                  const SizedBox(height: 48),

                  const ContinueListeningSection(),

                  const SizedBox(height: 48),

                  const CollectionsSection(),

                  const SizedBox(height: 48),

                  const RecentlyPlayedSection(),

                  const SizedBox(height: 48),

                  const AlbumsSection(),

                  const SizedBox(height: 48),

                  const ArtistsSection(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}