import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    final pad = Responsive.hPad(context);
    final featured = p.current ?? (p.songs.isNotEmpty ? p.songs.first : null);
    final wide = !Responsive.isMobile(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(pad, 28, pad, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting(), style: Theme.of(context).textTheme.bodyLarge),
                Text('What do you want to hear?', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
        if (featured != null) SliverToBoxAdapter(child: _FeaturedCard(song: featured, queue: p.songs)),
        const SliverToBoxAdapter(child: SectionHeader('Trending now')),
        SliverToBoxAdapter(
          child: SizedBox(
            height: wide ? 230 : 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: pad),
              itemCount: p.songs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (_, i) => SongCard(song: p.songs[i], queue: p.songs, width: wide ? 170 : 140),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SectionHeader('Browse by genre')),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final g in p.genres)
                  _GenreTile(
                    genre: g,
                    song: p.songs.firstWhere((s) => s.genre == g),
                    onTap: () => Navigator.pushNamed(context, '/genre', arguments: g),
                  ),
              ],
            ),
          ),
        ),
        if (p.recent.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SectionHeader('Recently played')),
          SliverList.builder(itemCount: p.recent.length.clamp(0, 4), itemBuilder: (_, i) => SongTile(song: p.recent[i], queue: p.recent)),
        ],
        const SliverToBoxAdapter(child: SectionHeader('All songs')),
        SliverList.builder(itemCount: p.songs.length, itemBuilder: (_, i) => SongTile(song: p.songs[i], queue: p.songs)),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Song song;
  final List<Song> queue;
  const _FeaturedCard({required this.song, required this.queue});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    final pad = Responsive.hPad(context);
    final mobile = Responsive.isMobile(context);
    final playing = p.current?.id == song.id && p.isPlaying;
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 12, pad, 0),
      child: Container(
        padding: EdgeInsets.all(mobile ? 18 : 28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(colors: song.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: song.colors.first.withOpacity(0.35), blurRadius: 30, offset: const Offset(0, 12))],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Icon(Icons.graphic_eq_rounded, size: mobile ? 120 : 190, color: Colors.white.withOpacity(0.12)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(20)),
                  child: Text(p.current == null ? 'FEATURED' : 'NOW PLAYING', style: const TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
                ),
                SizedBox(height: mobile ? 28 : 48),
                Text(song.title, style: TextStyle(color: Colors.white, fontSize: mobile ? 26 : 38, fontWeight: FontWeight.w800)),
                Text('${song.artist} • ${song.album}', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87),
                      onPressed: () => p.current?.id == song.id ? p.togglePlay() : p.play(song, queue: queue),
                      icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                      label: Text(playing ? 'Pause' : 'Play'),
                    ),
                    const SizedBox(width: 12),
                    if (p.current != null)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white70), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        onPressed: () => Navigator.pushNamed(context, '/now-playing'),
                        child: const Text('Open player'),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GenreTile extends StatelessWidget {
  final String genre;
  final Song song;
  final VoidCallback onTap;
  const _GenreTile({required this.genre, required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        width: 150,
        height: 80,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(colors: song.colors)),
        child: Stack(
          children: [
            Positioned(right: -6, bottom: -6, child: Transform.rotate(angle: 0.4, child: Icon(Icons.album_rounded, size: 50, color: Colors.white.withOpacity(0.35)))),
            Text(genre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

/// Songs of a single genre (opened through the named route '/genre').
class GenreScreen extends StatelessWidget {
  final String genre;
  const GenreScreen({super.key, required this.genre});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    final list = p.songs.where((s) => s.genre == genre).toList();
    return Scaffold(
      appBar: AppBar(title: Text(genre)),
      body: Column(
        children: [
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('No songs in this genre'))
                : ListView.builder(itemCount: list.length, itemBuilder: (_, i) => SongTile(song: list[i], queue: list)),
          ),
          const MiniPlayer(),
        ],
      ),
    );
  }
}
