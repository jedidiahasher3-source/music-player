import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'playlist_screens.dart';
import 'settings_screen.dart';

/// Responsive scaffold: bottom bar (mobile), rail (tablet), extended rail (desktop).
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _pages = <Widget>[HomeScreen(), LibraryScreen(), PlaylistsScreen(), FavoritesScreen(), SettingsScreen()];
  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.library_music_outlined, Icons.library_music_rounded, 'Library'),
    (Icons.queue_music_outlined, Icons.queue_music_rounded, 'Playlists'),
    (Icons.favorite_border, Icons.favorite, 'Favourites'),
    (Icons.settings_outlined, Icons.settings, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final mobile = w < Responsive.mobile;
    final extended = w >= Responsive.desktop;

    final content = Expanded(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(anim), child: child),
        ),
        child: KeyedSubtree(key: ValueKey(_index), child: _pages[_index]),
      ),
    );

    return Scaffold(
      bottomNavigationBar: mobile
          ? NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [for (final it in _items) NavigationDestination(icon: Icon(it.$1), selectedIcon: Icon(it.$2), label: it.$3)],
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  if (!mobile)
                    NavigationRail(
                      extended: extended,
                      minExtendedWidth: 210,
                      selectedIndex: _index,
                      onDestinationSelected: (i) => setState(() => _index = i),
                      leading: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.graphic_eq_rounded, color: Theme.of(context).colorScheme.primary, size: 30),
                            if (extended) const Padding(padding: EdgeInsets.only(left: 8), child: Text('Wavely', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
                          ],
                        ),
                      ),
                      destinations: [for (final it in _items) NavigationRailDestination(icon: Icon(it.$1), selectedIcon: Icon(it.$2), label: Text(it.$3))],
                    ),
                  content,
                ],
              ),
            ),
            const MiniPlayer(),
          ],
        ),
      ),
    );
  }
}
