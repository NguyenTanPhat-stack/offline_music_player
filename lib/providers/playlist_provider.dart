import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../services/storage_service.dart';

class PlaylistProvider extends ChangeNotifier {
  final StorageService storage;

  PlaylistProvider(this.storage);

  List<PlaylistModelX> _playlists = [];
  bool _loaded = false;

  List<PlaylistModelX> get playlists => _playlists;

  PlaylistModelX? getById(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Map playlistId -> List<SongModelX> theo list allSongs hiện có
  List<SongModelX> songsOfPlaylist({
    required String playlistId,
    required List<SongModelX> allSongs,
  }) {
    final p = getById(playlistId);
    if (p == null) return const [];

    final mapById = {for (final s in allSongs) s.id: s};
    final result = <SongModelX>[];
    for (final id in p.songIds) {
      final s = mapById[id];
      if (s != null) result.add(s);
    }
    return result;
  }

  Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;
    _playlists = await storage.loadPlaylists();
    _loaded = true;
    notifyListeners();
  }

  Future<void> createPlaylist(String name) async {
    final n = name.trim();
    if (n.isEmpty) return;

    final now = DateTime.now();
    final p = PlaylistModelX(
      id: now.microsecondsSinceEpoch.toString(),
      name: n,
      songIds: const [],
      createdAt: now,
      updatedAt: now,
    );

    _playlists = [p, ..._playlists];
    await storage.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> renamePlaylist(String id, String newName) async {
    final n = newName.trim();
    if (n.isEmpty) return;

    final now = DateTime.now();
    _playlists = _playlists.map((p) {
      if (p.id != id) return p;
      return p.copyWith(name: n, updatedAt: now);
    }).toList();

    await storage.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> deletePlaylist(String id) async {
    _playlists = _playlists.where((p) => p.id != id).toList();
    await storage.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> addSong(String playlistId, int songId) async {
    final now = DateTime.now();
    _playlists = _playlists.map((p) {
      if (p.id != playlistId) return p;
      if (p.songIds.contains(songId)) return p; // tránh trùng
      return p.copyWith(
        songIds: [...p.songIds, songId],
        updatedAt: now,
      );
    }).toList();

    await storage.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> removeSong(String playlistId, int songId) async {
    final now = DateTime.now();
    _playlists = _playlists.map((p) {
      if (p.id != playlistId) return p;
      return p.copyWith(
        songIds: p.songIds.where((x) => x != songId).toList(),
        updatedAt: now,
      );
    }).toList();

    await storage.savePlaylists(_playlists);
    notifyListeners();
  }

  /// Optional: đổi thứ tự bài trong playlist (kéo thả)
  Future<void> reorderSong(String playlistId, int oldIndex, int newIndex) async {
    final now = DateTime.now();
    _playlists = _playlists.map((p) {
      if (p.id != playlistId) return p;

      final list = [...p.songIds];
      if (oldIndex < 0 || oldIndex >= list.length) return p;
      if (newIndex < 0 || newIndex >= list.length) return p;

      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);

      return p.copyWith(songIds: list, updatedAt: now);
    }).toList();

    await storage.savePlaylists(_playlists);
    notifyListeners();
  }
}
