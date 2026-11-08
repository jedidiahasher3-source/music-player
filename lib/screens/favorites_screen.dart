import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    final favs = p.favoriteSongs;
    final pad = Responsive.hPad(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(pad, 24, pad, 8),
          child: Row(
            children: [
              Expanded(child: Text('Favourites', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800))),
              if (favs.isNotEmpty)
                FilledButton.icon(onPressed: () => p.play(favs.first, queue: favs), icon: const Icon(Icons.play_arrow_rounded), label: const Text('Play all')),
            ],
          ),
        ),
        Expanded(
          child: favs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 12),
                      const Text('Tap the heart on any song to save it here'),
                    ],
                  ),
                )
              : ListView.builder(itemCount: favs.length, itemBuilder: (_, i) => SongTile(song: favs[i], queue: favs)),
        ),
      ],
    );
  }
}
