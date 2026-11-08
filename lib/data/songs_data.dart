import 'package:flutter/material.dart';
import '../models/models.dart';


/// Demo catalogue. Tracks are original synthesized loops bundled in assets/audio/.
final List<Song> sampleSongs = [
  Song(id: '1', title: 'Neon Skyline', artist: 'Aria Vale', album: 'Night Drive', genre: 'Synthwave', url: 'audio/track1.mp3', colors: const [Color(0xFF7F00FF), Color(0xFFE100FF)]),
  Song(id: '2', title: 'Golden Hour', artist: 'The Lanterns', album: 'Sunday Light', genre: 'Indie', url: 'audio/track2.mp3', colors: const [Color(0xFFFF8008), Color(0xFFFFC837)]),
  Song(id: '3', title: 'Ocean Static', artist: 'Mira Cole', album: 'Deep Blue', genre: 'Chill', url: 'audio/track3.mp3', colors: const [Color(0xFF0093E9), Color(0xFF80D0C7)]),
  Song(id: '4', title: 'Midnight Run', artist: 'Kairo', album: 'After Hours', genre: 'Electronic', url: 'audio/track4.mp3', colors: const [Color(0xFF232526), Color(0xFF6A11CB)]),
  Song(id: '5', title: 'Paper Planes', artist: 'Juno & Co', album: 'Small Wonders', genre: 'Indie', url: 'audio/track5.mp3', colors: const [Color(0xFFF857A6), Color(0xFFFF5858)]),
  Song(id: '6', title: 'Velvet Rain', artist: 'Sol Marin', album: 'Monsoon', genre: 'Chill', url: 'audio/track6.mp3', colors: const [Color(0xFF11998E), Color(0xFF38EF7D)]),
  Song(id: '7', title: 'Circuit Dreams', artist: 'Aria Vale', album: 'Night Drive', genre: 'Synthwave', url: 'audio/track7.mp3', colors: const [Color(0xFF396AFC), Color(0xFF2948FF)]),
  Song(id: '8', title: 'Pulse Theory', artist: 'Kairo', album: 'After Hours', genre: 'Electronic', url: 'audio/track8.mp3', colors: const [Color(0xFFEB3349), Color(0xFFF45C43)]),
];

const List<String> genreOptions = ['Synthwave', 'Indie', 'Chill', 'Electronic', 'Pop', 'Rock', 'Jazz', 'Classical', 'Other'];
