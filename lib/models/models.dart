import 'package:flutter/material.dart';

class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String genre;
  final String url;
  final List<Color> colors;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.genre,
    required this.url,
    required this.colors,
  });
}

class Playlist {
  final String id;
  String name;
  String description;
  final List<String> songIds;

  Playlist({
    required this.id,
    required this.name,
    this.description = '',
    List<String>? songIds,
  }) : songIds = songIds ?? [];
}
