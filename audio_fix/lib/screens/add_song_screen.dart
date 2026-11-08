import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/songs_data.dart';
import '../models/models.dart';
import '../providers/player_provider.dart';

/// Form with validation – add a new song (by URL) to the library.
class AddSongScreen extends StatefulWidget {
  const AddSongScreen({super.key});

  @override
  State<AddSongScreen> createState() => _AddSongScreenState();
}

class _AddSongScreenState extends State<AddSongScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _artist = TextEditingController();
  final _album = TextEditingController();
  final _url = TextEditingController();
  String _genre = genreOptions.first;
  int _colorIndex = 0;

  static const _palettes = [
    [Color(0xFF7F00FF), Color(0xFFE100FF)],
    [Color(0xFFFF8008), Color(0xFFFFC837)],
    [Color(0xFF0093E9), Color(0xFF80D0C7)],
    [Color(0xFF11998E), Color(0xFF38EF7D)],
    [Color(0xFFEB3349), Color(0xFFF45C43)],
  ];

  @override
  void dispose() {
    for (final c in [_title, _artist, _album, _url]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<PlayerProvider>().addSong(Song(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: _title.text.trim(),
          artist: _artist.text.trim(),
          album: _album.text.trim().isEmpty ? 'Single' : _album.text.trim(),
          genre: _genre,
          url: _url.text.trim(),
          colors: _palettes[_colorIndex],
        ));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"${_title.text.trim()}" added to your library')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a song')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  TextFormField(
                    controller: _title,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Title *', prefixIcon: Icon(Icons.music_note)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _artist,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Artist *', prefixIcon: Icon(Icons.person)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Artist is required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _album,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Album (optional)', prefixIcon: Icon(Icons.album)),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _genre,
                    decoration: const InputDecoration(labelText: 'Genre', prefixIcon: Icon(Icons.category)),
                    items: [for (final g in genreOptions) DropdownMenuItem(value: g, child: Text(g))],
                    onChanged: (v) => setState(() => _genre = v ?? _genre),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _url,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(labelText: 'Audio URL (mp3) *', helperText: 'Server must allow cross-origin (CORS) requests', prefixIcon: Icon(Icons.link)),
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return 'Audio URL is required';
                      final uri = Uri.tryParse(t);
                      if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https') || uri.host.isEmpty) return 'Enter a valid http(s) URL';
                      if (!RegExp(r'\.(mp3|wav|ogg|m4a|aac)(\?.*)?$', caseSensitive: false).hasMatch(t)) return 'URL must point to an audio file (.mp3, .wav, .ogg…)';
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  Align(alignment: Alignment.centerLeft, child: Text('Cover colour', style: Theme.of(context).textTheme.titleSmall)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (int i = 0; i < _palettes.length; i++)
                        GestureDetector(
                          onTap: () => setState(() => _colorIndex = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 12),
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: _palettes[i]),
                              border: Border.all(color: _colorIndex == i ? Theme.of(context).colorScheme.onSurface : Colors.transparent, width: 3),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Save song'))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
