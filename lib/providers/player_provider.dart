import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../data/songs_data.dart';
import '../models/models.dart';

enum RepeatSetting { off, all, one }

/// Central app state (Provider / ChangeNotifier): library, playlists,
/// favourites, theme and the audio engine.
class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  final List<Song> songs = List.of(sampleSongs);
  final List<Playlist> playlists = [
    Playlist(id: 'p1', name: 'Chill Vibes', description: 'Easy listening for late nights', songIds: ['3', '6', '2']),
    Playlist(id: 'p2', name: 'Workout Mix', description: 'High energy beats', songIds: ['4', '8', '7']),
  ];
  final Set<String> favorites = {};
  final List<Song> recent = [];

  /// Position updates tick often, so they live in their own notifier
  /// to avoid rebuilding the whole widget tree.
  final ValueNotifier<Duration> position = ValueNotifier(Duration.zero);

  Song? current;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  bool shuffle = false;
  RepeatSetting repeat = RepeatSetting.off;
  double volume = 0.8;
  ThemeMode themeMode = ThemeMode.dark;
  List<Song> _queue = [];

  PlayerProvider() {
    _player.setVolume(volume);
    _player.onPlayerStateChanged.listen((s) {
      isPlaying = s == PlayerState.playing;
      notifyListeners();
    });
    _player.onPositionChanged.listen((p) => position.value = p);
    _player.onDurationChanged.listen((d) {
      duration = d;
      notifyListeners();
    });
    _player.onPlayerComplete.listen((_) => _onComplete());
  }

  List<Song> get queue => List.unmodifiable(_queue);
  bool isFavorite(String id) => favorites.contains(id);
  Song? songById(String id) {
    for (final s in songs) {
      if (s.id == id) return s;
    }
    return null;
  }

  List<Song> get favoriteSongs => songs.where((s) => favorites.contains(s.id)).toList();
  List<String> get genres => songs.map((s) => s.genre).toSet().toList()..sort();

  // ---------------- playback ----------------
  Future<void> play(Song song, {List<Song>? queue}) async {
    _queue = queue ?? songs;
    current = song;
    position.value = Duration.zero;
    duration = Duration.zero;
    recent.removeWhere((s) => s.id == song.id);
    recent.insert(0, song);
    if (recent.length > 8) recent.removeLast();
    notifyListeners();
    try {
      await _player.stop();
      final Source src = song.url.startsWith('http')
          ? UrlSource(song.url)
          : AssetSource(song.url); // bundled file, e.g. 'audio/track1.mp3'
      await _player.play(src);
    } catch (_) {
      isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> togglePlay() async {
    if (current == null) {
      if (songs.isNotEmpty) await play(songs.first);
      return;
    }
    if (isPlaying) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  Future<void> next() async {
    if (_queue.isEmpty || current == null) return;
    final i = _queue.indexWhere((s) => s.id == current!.id);
    int n;
    if (shuffle && _queue.length > 1) {
      do {
        n = Random().nextInt(_queue.length);
      } while (n == i);
    } else {
      n = (i + 1) % _queue.length;
    }
    await play(_queue[n], queue: _queue);
  }

  Future<void> previous() async {
    if (_queue.isEmpty || current == null) return;
    if (position.value.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    final i = _queue.indexWhere((s) => s.id == current!.id);
    final p = (i - 1 + _queue.length) % _queue.length;
    await play(_queue[p], queue: _queue);
  }

  Future<void> _onComplete() async {
    if (repeat == RepeatSetting.one && current != null) {
      await play(current!, queue: _queue);
      return;
    }
    final i = _queue.indexWhere((s) => s.id == current?.id);
    final isLast = i == _queue.length - 1;
    if (repeat == RepeatSetting.off && isLast && !shuffle) {
      isPlaying = false;
      position.value = Duration.zero;
      notifyListeners();
      return;
    }
    await next();
  }

  Future<void> seek(Duration d) async {
    position.value = d;
    await _player.seek(d);
  }

  Future<void> setVolume(double v) async {
    volume = v;
    await _player.setVolume(v);
    notifyListeners();
  }

  void toggleShuffle() {
    shuffle = !shuffle;
    notifyListeners();
  }

  void cycleRepeat() {
    repeat = RepeatSetting.values[(repeat.index + 1) % RepeatSetting.values.length];
    notifyListeners();
  }

  // ---------------- library ----------------
  void toggleFavorite(String id) {
    favorites.contains(id) ? favorites.remove(id) : favorites.add(id);
    notifyListeners();
  }

  void addSong(Song s) {
    songs.add(s);
    notifyListeners();
  }

  void removeSong(String id) {
    songs.removeWhere((s) => s.id == id);
    favorites.remove(id);
    for (final p in playlists) {
      p.songIds.remove(id);
    }
    recent.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // ---------------- playlists ----------------
  bool playlistNameTaken(String name) =>
      playlists.any((p) => p.name.toLowerCase() == name.trim().toLowerCase());

  void createPlaylist(String name, String description) {
    playlists.add(Playlist(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      description: description.trim(),
    ));
    notifyListeners();
  }

  void deletePlaylist(String id) {
    playlists.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Playlist? playlistById(String id) {
    for (final p in playlists) {
      if (p.id == id) return p;
    }
    return null;
  }

  List<Song> playlistSongs(Playlist p) =>
      p.songIds.map(songById).whereType<Song>().toList();

  void togglePlaylistSong(String playlistId, String songId) {
    final p = playlistById(playlistId);
    if (p == null) return;
    p.songIds.contains(songId) ? p.songIds.remove(songId) : p.songIds.add(songId);
    notifyListeners();
  }

  // ---------------- theme ----------------
  void setDark(bool dark) {
    themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    position.dispose();
    super.dispose();
  }
}
