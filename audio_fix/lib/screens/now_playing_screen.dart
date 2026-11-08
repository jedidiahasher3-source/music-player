import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../widgets/common_widgets.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(vsync: this, duration: const Duration(seconds: 18));

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  void _syncSpin(bool playing) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (playing && !_spin.isAnimating) _spin.repeat();
      if (!playing && _spin.isAnimating) _spin.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    final song = p.current;
    if (song == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Nothing playing')));
    }
    _syncSpin(p.isPlaying);
    final cs = Theme.of(context).colorScheme;
    final wide = MediaQuery.sizeOf(context).width >= 850;
    final artSize = min(MediaQuery.sizeOf(context).width * (wide ? 0.28 : 0.72), 340.0);

    final player = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Hero(
          tag: 'art',
          child: RotationTransition(
            turns: _spin,
            child: AnimatedScale(
              scale: p.isPlaying ? 1 : 0.92,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              child: AlbumArt(song: song, size: artSize, circular: true),
            ),
          ),
        ),
        const SizedBox(height: 28),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: Column(
            key: ValueKey(song.id),
            children: [
              Text(song.title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('${song.artist} • ${song.album}', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Visualizer(active: p.isPlaying, color: cs.primary, height: 34, bars: 9),
        const SizedBox(height: 8),
        const SeekBar(),
        const PlayerControls(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Favourite',
              icon: Icon(p.isFavorite(song.id) ? Icons.favorite : Icons.favorite_border, color: p.isFavorite(song.id) ? Colors.pinkAccent : null),
              onPressed: () => p.toggleFavorite(song.id),
            ),
            IconButton(tooltip: 'Add to playlist', icon: const Icon(Icons.playlist_add), onPressed: () => showAddToPlaylistSheet(context, song)),
            const SizedBox(width: 12),
            const Icon(Icons.volume_down_rounded),
            SizedBox(width: 160, child: Slider(value: p.volume, onChanged: p.setVolume)),
            const Icon(Icons.volume_up_rounded),
          ],
        ),
      ],
    );

    final upNext = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), child: Text('Up next', style: Theme.of(context).textTheme.titleLarge)),
        Expanded(
          child: ListView(
            children: [for (final s in p.queue) SongTile(song: s, queue: p.queue)],
          ),
        ),
      ],
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32), onPressed: () => Navigator.pop(context)),
        title: const Text('Now playing'),
        centerTitle: true,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [song.colors.first.withOpacity(0.55), Theme.of(context).scaffoldBackgroundColor],
          ),
        ),
        child: SafeArea(
          child: wide
              ? Row(
                  children: [
                    Expanded(flex: 3, child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: player))),
                    Expanded(flex: 2, child: upNext),
                  ],
                )
              : Center(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24), child: player)),
        ),
      ),
    );
  }
}
