import 'package:flutter/material.dart';
import 'screens/add_song_screen.dart';
import 'screens/app_shell.dart';
import 'screens/home_screen.dart';
import 'screens/now_playing_screen.dart';
import 'screens/playlist_screens.dart';

/// Named routes with custom page transitions.
class AppRouter {
  static const home = '/';
  static const nowPlaying = '/now-playing';
  static const playlist = '/playlist';
  static const createPlaylist = '/create-playlist';
  static const addSong = '/add-song';
  static const genre = '/genre';

  static Route<dynamic> generate(RouteSettings s) {
    switch (s.name) {
      case nowPlaying:
        return _slideUp(const NowPlayingScreen(), s);
      case playlist:
        return _fade(PlaylistDetailScreen(playlistId: s.arguments as String), s);
      case createPlaylist:
        return _fade(const CreatePlaylistScreen(), s);
      case addSong:
        return _fade(const AddSongScreen(), s);
      case genre:
        return _fade(GenreScreen(genre: s.arguments as String), s);
      case home:
      default:
        return MaterialPageRoute(builder: (_) => const AppShell(), settings: s);
    }
  }

  static PageRouteBuilder _slideUp(Widget page, RouteSettings s) => PageRouteBuilder(
        settings: s,
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );

  static PageRouteBuilder _fade(Widget page, RouteSettings s) => PageRouteBuilder(
        settings: s,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(position: Tween(begin: const Offset(0.04, 0), end: Offset.zero).animate(anim), child: child),
        ),
      );
}
