import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();
  int _rating = 0;
  bool _ratingError = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    super.dispose();
  }

  void _send() {
    final valid = _formKey.currentState!.validate();
    setState(() => _ratingError = _rating == 0);
    if (!valid || _rating == 0) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thanks ${_name.text.trim()}! Feedback sent ($_rating★).')));
    _formKey.currentState!.reset();
    _name.clear();
    _email.clear();
    _message.clear();
    setState(() => _rating = 0);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    final pad = Responsive.hPad(context);
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: EdgeInsets.all(pad),
          children: [
            Text('Settings', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: cs.surfaceContainerHigh,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Icon(p.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
                    title: const Text('Dark mode'),
                    value: p.themeMode == ThemeMode.dark,
                    onChanged: p.setDark,
                  ),
                  ListTile(
                    leading: const Icon(Icons.volume_up),
                    title: const Text('Default volume'),
                    subtitle: Slider(value: p.volume, onChanged: p.setVolume),
                  ),
                  ListTile(
                    leading: const Icon(Icons.shuffle),
                    title: const Text('Shuffle'),
                    trailing: Switch(value: p.shuffle, onChanged: (_) => p.toggleShuffle()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Send feedback', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Your name', prefixIcon: Icon(Icons.person_outline)),
                    validator: (v) => (v == null || v.trim().length < 2) ? 'Enter your name (min 2 characters)' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return 'Email is required';
                      if (!RegExp(r'^[\w\.\-+]+@([\w\-]+\.)+[A-Za-z]{2,}$').hasMatch(t)) return 'Enter a valid email address';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _message,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Message', alignLabelWithHint: true, prefixIcon: Icon(Icons.chat_bubble_outline)),
                    validator: (v) => (v == null || v.trim().length < 10) ? 'Message must be at least 10 characters' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Rating:'),
                      const SizedBox(width: 8),
                      for (int i = 1; i <= 5; i++)
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(i <= _rating ? Icons.star_rounded : Icons.star_border_rounded, color: Colors.amber),
                          onPressed: () => setState(() {
                            _rating = i;
                            _ratingError = false;
                          }),
                        ),
                    ],
                  ),
                  if (_ratingError) Align(alignment: Alignment.centerLeft, child: Text('Please choose a rating', style: TextStyle(color: cs.error, fontSize: 12))),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _send, icon: const Icon(Icons.send), label: const Text('Submit feedback'))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Center(child: Text('Wavely v1.0 • Flutter Web Music Player')),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}
