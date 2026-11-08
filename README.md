# Wavely – Flutter Web Music Player

A responsive, fully working music player built with Flutter for the web (desktop / tablet / mobile).
Audio streams from royalty-free SoundHelix sample tracks.

## Concepts demonstrated
| Concept | Where |
|---|---|
| Widgets (Container, Row, Column, Stack, ListView, GridView, Card, buttons, Slider, chips…) | `lib/screens/*`, `lib/widgets/common_widgets.dart` |
| Responsive UI (MediaQuery, LayoutBuilder, NavigationBar / Rail / extended Rail, adaptive grids) | `app_shell.dart`, `theme/app_theme.dart` (`Responsive`), `now_playing_screen.dart` |
| Navigation (named routes, `onGenerateRoute`, arguments, custom transitions, Hero) | `router.dart` |
| Animations (AnimatedSwitcher, AnimatedContainer, Hero, RotationTransition, equaliser bars, custom page transitions) | `common_widgets.dart`, `now_playing_screen.dart`, `router.dart` |
| State management (Provider + ChangeNotifier, StatefulWidget, ValueNotifier) | `providers/player_provider.dart` |
| Themes & custom widgets (Material 3 light/dark theme, AlbumArt, SongTile, SongCard, MiniPlayer, SeekBar, PlayerControls) | `theme/app_theme.dart`, `widgets/` |
| Forms & validation (Add song, Create playlist, Feedback) | `add_song_screen.dart`, `playlist_screens.dart`, `settings_screen.dart` |

## Features
Play / pause / next / previous, seek, volume, shuffle, repeat (off/all/one), queue, favourites, recently played,
search + genre filter, list/grid toggle, playlists (create, add/remove songs, delete, play all), add your own song by URL,
dark/light theme, genre pages, feedback form.

## Run locally
```bash
flutter create --platforms web .   # generates the web/ folder (keeps existing lib/ and pubspec.yaml)
flutter pub get
flutter run -d chrome
```

## Deploy to GitHub Pages
1. Push this project to a GitHub repo (branch `main`).
2. Repo **Settings → Pages → Source: GitHub Actions**.
3. The included workflow (`.github/workflows/deploy.yml`) builds and publishes on every push.
   Your site: `https://<username>.github.io/<repo-name>/`

Manual alternative:
```bash
flutter build web --release --base-href "/<repo-name>/"
# publish the contents of build/web to the gh-pages branch
```

## Testing different screen sizes
Open Chrome DevTools (F12) → device toolbar, or resize the window:
- < 600 px: mobile (bottom navigation, compact mini player)
- 600–1000 px: tablet (navigation rail)
- ≥ 1000 px: desktop (extended rail, full-width mini player with volume, two-pane Now Playing)

## Note on audio
Browsers block autoplay, so music starts only after a click/tap (all play actions are user-driven).
