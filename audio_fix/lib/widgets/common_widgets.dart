import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';

/// Gradient "cover art" generated from the song's colours.
class AlbumArt extends StatelessWidget {
  final Song song;
  final double size;
  final bool circular;
  final double radius;
  const AlbumArt({super.key, required this.song, required this.size, this.circular = false, this.radius = 14});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.circular(radius),
        gradient: LinearGradient(colors: song.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: song.colors.first.withOpacity(0.4), blurRadius: size / 5, offset: Offset(0, size / 14))],
      ),
      child: Icon(Icons.music_note_rounded, color: Colors.white.withOpacity(0.9), size: size * 0.42),
    );
  }
}

/// Animated equaliser bars.
class Visualizer extends StatefulWidget {
  final bool active;
  final Color color;
  final double height;
  final int bars;
  const Visualizer({super.key, required this.active, required this.color, this.height = 22, this.bars = 4});

  @override
  State<Visualizer> createState() => _VisualizerState();
}

class _VisualizerState extends State<Visualizer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.bars, (i) {
          final f = widget.active ? 0.2 + 0.8 * sin(_c.value * 2 * pi + i * 0.9).abs() : 0.15;
          return Container(
            width: widget.height / 6,
            height: widget.height * f,
            margin: EdgeInsets.symmetric(horizontal: widget.height / 24),
            decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(2)),
          );
        }),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(Responsive.hPad(context), 24, Responsive.hPad(context), 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700))),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Reusable list row for a song.
class SongTile extends StatelessWidget {
  final Song song;
  final List<Song> queue;
  const SongTile({super.key, required this.song, required this.queue});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    final cs = Theme.of(context).colorScheme;
    final isCurrent = p.current?.id == song.id;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.hPad(context) - 8, vertical: 2),
      child: Material(
        color: isCurrent ? cs.primary.withOpacity(0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          onTap: () => p.play(song, queue: queue),
          leading: AlbumArt(song: song, size: 48, radius: 10),
          title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w600, color: isCurrent ? cs.primary : null)),
          subtitle: Text('${song.artist} • ${song.album}', maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCurrent) Padding(padding: const EdgeInsets.only(right: 8), child: Visualizer(active: p.isPlaying, color: cs.primary, height: 18)),
              IconButton(
                tooltip: 'Favourite',
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                  child: Icon(p.isFavorite(song.id) ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(p.isFavorite(song.id)), color: p.isFavorite(song.id) ? Colors.pinkAccent : null),
                ),
                onPressed: () => p.toggleFavorite(song.id),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'playlist') showAddToPlaylistSheet(context, song);
                  if (v == 'delete') {
                    p.removeSong(song.id);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removed "${song.title}"')));
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'playlist', child: ListTile(leading: Icon(Icons.playlist_add), title: Text('Add to playlist'), contentPadding: EdgeInsets.zero)),
                  PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Remove song'), contentPadding: EdgeInsets.zero)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Square card used in grids and horizontal carousels.
class SongCard extends StatelessWidget {
  final Song song;
  final List<Song> queue;
  final double width;
  const SongCard({super.key, required this.song, required this.queue, this.width = 150});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    final isCurrent = p.current?.id == song.id;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => p.play(song, queue: queue),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  LayoutBuilder(builder: (_, c) => AlbumArt(song: song, size: min(c.maxWidth, c.maxHeight), radius: 16)),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle, border: isCurrent ? Border.all(color: Colors.white, width: 1.5) : null),
                      child: Icon(isCurrent && p.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet listing playlists with checkboxes.
void showAddToPlaylistSheet(BuildContext context, Song song) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => Consumer<PlayerProvider>(
      builder: (_, p, __) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add "${song.title}" to…', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 8),
              Flexible(
                child: p.playlists.isEmpty
                    ? const Padding(padding: EdgeInsets.all(24), child: Text('No playlists yet. Create one first.'))
                    : ListView(
                        shrinkWrap: true,
                        children: [
                          for (final pl in p.playlists)
                            CheckboxListTile(
                              value: pl.songIds.contains(song.id),
                              title: Text(pl.name),
                              subtitle: Text('${pl.songIds.length} songs'),
                              onChanged: (_) => p.togglePlaylistSong(pl.id, song.id),
                            ),
                        ],
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('New playlist'),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, '/create-playlist');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Shuffle / prev / play / next / repeat row, reused by mini and full player.
class PlayerControls extends StatelessWidget {
  final bool compact;
  const PlayerControls({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    final cs = Theme.of(context).colorScheme;
    final big = compact ? 40.0 : 64.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!compact)
          IconButton(
            tooltip: 'Shuffle',
            icon: Icon(Icons.shuffle_rounded, color: p.shuffle ? cs.primary : null),
            onPressed: p.toggleShuffle,
          ),
        IconButton(iconSize: compact ? 26 : 36, tooltip: 'Previous', icon: const Icon(Icons.skip_previous_rounded), onPressed: p.previous),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: p.togglePlay,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: big,
            height: big,
            decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primary, boxShadow: [BoxShadow(color: cs.primary.withOpacity(0.45), blurRadius: p.isPlaying ? 22 : 8)]),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: Icon(p.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, key: ValueKey(p.isPlaying), color: cs.onPrimary, size: big * 0.6),
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(iconSize: compact ? 26 : 36, tooltip: 'Next', icon: const Icon(Icons.skip_next_rounded), onPressed: p.next),
        if (!compact)
          IconButton(
            tooltip: 'Repeat',
            icon: Icon(p.repeat == RepeatSetting.one ? Icons.repeat_one_rounded : Icons.repeat_rounded, color: p.repeat != RepeatSetting.off ? cs.primary : null),
            onPressed: p.cycleRepeat,
          ),
      ],
    );
  }
}

/// Seek bar bound to the provider's position notifier.
class SeekBar extends StatelessWidget {
  const SeekBar({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.read<PlayerProvider>();
    final total = context.select<PlayerProvider, Duration>((x) => x.duration);
    return ValueListenableBuilder<Duration>(
      valueListenable: p.position,
      builder: (_, pos, __) {
        final max = total.inMilliseconds.toDouble();
        final val = pos.inMilliseconds.toDouble().clamp(0, max > 0 ? max : 1).toDouble();
        return Column(
          children: [
            Slider(
              value: val,
              max: max > 0 ? max : 1,
              onChanged: max > 0 ? (v) => p.seek(Duration(milliseconds: v.toInt())) : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(formatDuration(pos)), Text(formatDuration(total))],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Persistent mini player shown under every tab. Tap to open full screen.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    final cs = Theme.of(context).colorScheme;
    final song = p.current;
    final mobile = Responsive.isMobile(context);
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: song == null
          ? const SizedBox(width: double.infinity)
          : GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/now-playing'),
              child: Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cs.primary.withOpacity(0.25)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Hero(tag: 'art', child: AlbumArt(song: song, size: 46, radius: 10)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        if (!mobile) ...[
                          const SizedBox(width: 12),
                          SizedBox(width: 280, child: const SeekBar()),
                          const Icon(Icons.volume_up_rounded, size: 20),
                          SizedBox(width: 110, child: Slider(value: p.volume, onChanged: p.setVolume)),
                        ],
                        PlayerControls(compact: true),
                      ],
                    ),
                    if (mobile)
                      ValueListenableBuilder<Duration>(
                        valueListenable: p.position,
                        builder: (_, pos, __) => Padding(
                          padding: const EdgeInsets.only(top: 6, bottom: 2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              minHeight: 3,
                              value: p.duration.inMilliseconds == 0 ? 0 : (pos.inMilliseconds / p.duration.inMilliseconds).clamp(0.0, 1.0),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
