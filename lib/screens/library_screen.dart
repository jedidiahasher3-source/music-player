import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _query = '';
  String? _genre;
  bool _grid = false;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    final pad = Responsive.hPad(context);
    final q = _query.toLowerCase();
    final list = p.songs.where((s) {
      final match = s.title.toLowerCase().contains(q) || s.artist.toLowerCase().contains(q) || s.album.toLowerCase().contains(q);
      return match && (_genre == null || s.genre == _genre);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add-song'),
        icon: const Icon(Icons.add),
        label: const Text('Add song'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 24, pad, 8),
            child: Row(
              children: [
                Expanded(child: Text('Your library', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800))),
                IconButton.filledTonal(
                  tooltip: _grid ? 'List view' : 'Grid view',
                  icon: Icon(_grid ? Icons.view_list_rounded : Icons.grid_view_rounded),
                  onPressed: () => setState(() => _grid = !_grid),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(hintText: 'Search songs, artists, albums', prefixIcon: Icon(Icons.search)),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: pad, vertical: 10),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(label: const Text('All'), selected: _genre == null, onSelected: (_) => setState(() => _genre = null)),
                ),
                for (final g in p.genres)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(label: Text(g), selected: _genre == g, onSelected: (_) => setState(() => _genre = _genre == g ? null : g)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('No songs match your search'))
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _grid
                        ? GridView.builder(
                            key: const ValueKey('grid'),
                            padding: EdgeInsets.fromLTRB(pad, 8, pad, 90),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200, mainAxisExtent: 240, crossAxisSpacing: 16, mainAxisSpacing: 16),
                            itemCount: list.length,
                            itemBuilder: (_, i) => SongCard(song: list[i], queue: list, width: double.infinity),
                          )
                        : ListView.builder(
                            key: const ValueKey('list'),
                            padding: const EdgeInsets.only(bottom: 90),
                            itemCount: list.length,
                            itemBuilder: (_, i) => SongTile(song: list[i], queue: list),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
