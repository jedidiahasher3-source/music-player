import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    final pad = Responsive.hPad(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create-playlist'),
        icon: const Icon(Icons.playlist_add),
        label: const Text('New playlist'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, 24, pad, 12),
              child: Text('Playlists', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            ),
          ),
          if (p.playlists.isEmpty)
            const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('No playlists yet – create your first one!')))
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(pad, 4, pad, 100),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 260, mainAxisExtent: 220, crossAxisSpacing: 16, mainAxisSpacing: 16),
                itemCount: p.playlists.length,
                itemBuilder: (_, i) => _PlaylistCard(playlist: p.playlists[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  const _PlaylistCard({required this.playlist});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    final cs = Theme.of(context).colorScheme;
    final songs = p.playlistSongs(playlist);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/playlist', arguments: playlist.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _Mosaic(songs: songs)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(playlist.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  Text('${songs.length} songs', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Mosaic extends StatelessWidget {
  final List<Song> songs;
  const _Mosaic({required this.songs});

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return Container(width: double.infinity, color: Theme.of(context).colorScheme.surfaceContainerHighest, child: const Icon(Icons.queue_music_rounded, size: 44));
    }
    final shown = songs.take(4).toList();
    return Row(
      children: [
        for (final s in shown)
          Expanded(child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: s.colors, begin: Alignment.topCenter, end: Alignment.bottomCenter)))),
      ],
    );
  }
}

class PlaylistDetailScreen extends StatelessWidget {
  final String playlistId;
  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    final pl = p.playlistById(playlistId);
    if (pl == null) return const Scaffold(body: Center(child: Text('Playlist not found')));
    final songs = p.playlistSongs(pl);
    final pad = Responsive.hPad(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(pl.name),
        actions: [
          IconButton(
            tooltip: 'Delete playlist',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete playlist?'),
                  content: Text('"${pl.name}" will be removed. Your songs stay in the library.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                p.deletePlaylist(pl.id);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _pickSongs(context, pl.id),
        icon: const Icon(Icons.library_add),
        label: const Text('Add songs'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 90),
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(pad, 8, pad, 8),
                  child: Row(
                    children: [
                      Expanded(child: Text(pl.description.isEmpty ? '${songs.length} songs' : pl.description, style: Theme.of(context).textTheme.bodyMedium)),
                      FilledButton.icon(
                        onPressed: songs.isEmpty ? null : () => p.play(songs.first, queue: songs),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play all'),
                      ),
                    ],
                  ),
                ),
                if (songs.isEmpty) const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('This playlist is empty. Add some songs!'))),
                for (final s in songs)
                  Dismissible(
                    key: ValueKey('${pl.id}-${s.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 24), color: Colors.red.withOpacity(0.7), child: const Icon(Icons.remove_circle_outline, color: Colors.white)),
                    onDismissed: (_) => p.togglePlaylistSong(pl.id, s.id),
                    child: SongTile(song: s, queue: songs),
                  ),
              ],
            ),
          ),
          const MiniPlayer(),
        ],
      ),
    );
  }

  void _pickSongs(BuildContext context, String playlistId) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => Consumer<PlayerProvider>(
        builder: (_, p, __) {
          final pl = p.playlistById(playlistId)!;
          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.7),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final s in p.songs)
                    CheckboxListTile(
                      value: pl.songIds.contains(s.id),
                      secondary: AlbumArt(song: s, size: 40, radius: 8),
                      title: Text(s.title),
                      subtitle: Text(s.artist),
                      onChanged: (_) => p.togglePlaylistSong(pl.id, s.id),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Form with validation – create a new playlist.
class CreatePlaylistScreen extends StatefulWidget {
  const CreatePlaylistScreen({super.key});

  @override
  State<CreatePlaylistScreen> createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<PlayerProvider>().createPlaylist(_name.text, _desc.text);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Playlist "${_name.text.trim()}" created')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.read<PlayerProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('New playlist')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    maxLength: 30,
                    decoration: const InputDecoration(labelText: 'Playlist name', prefixIcon: Icon(Icons.queue_music)),
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return 'Please enter a name';
                      if (t.length < 3) return 'Name must be at least 3 characters';
                      if (p.playlistNameTaken(t)) return 'A playlist with this name already exists';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _desc,
                    maxLines: 3,
                    maxLength: 100,
                    decoration: const InputDecoration(labelText: 'Description (optional)', prefixIcon: Icon(Icons.notes)),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _submit, icon: const Icon(Icons.check), label: const Text('Create playlist'))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
