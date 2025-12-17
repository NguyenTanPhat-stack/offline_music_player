import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist_model.dart';

class StorageService {
  static const _kPlaylists = 'playlists';

  static const _kShuffle = 'shuffle_enabled';
  static const _kRepeat = 'repeat_mode'; // 0 off, 1 all, 2 one
  static const _kVolume = 'volume';
  static const _kThemeDark = 'theme_dark';

  static const _kLastQueue = 'last_queue_song_ids';
  static const _kLastIndex = 'last_index';
  static const _kLastPositionMs = 'last_position_ms';
  static const _kLastSongId = 'last_song_id';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  // ---------- PLAYLISTS ----------
  Future<List<PlaylistModelX>> loadPlaylists() async {
    final prefs = await _prefs;
    final s = prefs.getString(_kPlaylists);
    if (s == null || s.isEmpty) return [];

    try {
      final decoded = jsonDecode(s);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .map(PlaylistModelX.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePlaylists(List<PlaylistModelX> playlists) async {
    final prefs = await _prefs;
    final s = jsonEncode(playlists.map((e) => e.toJson()).toList());
    await prefs.setString(_kPlaylists, s);
  }

  // ---------- SETTINGS ----------
  Future<bool> loadShuffle() async {
    final prefs = await _prefs;
    return prefs.getBool(_kShuffle) ?? false;
  }

  Future<void> saveShuffle(bool v) async {
    final prefs = await _prefs;
    await prefs.setBool(_kShuffle, v);
  }

  Future<int> loadRepeatMode() async {
    final prefs = await _prefs;
    final m = prefs.getInt(_kRepeat) ?? 0;
    if (m < 0 || m > 2) return 0;
    return m;
  }

  Future<void> saveRepeatMode(int mode) async {
    final prefs = await _prefs;
    final m = mode.clamp(0, 2);
    await prefs.setInt(_kRepeat, m);
  }

  Future<double> loadVolume() async {
    final prefs = await _prefs;
    final v = prefs.getDouble(_kVolume) ?? 1.0;
    if (v.isNaN) return 1.0;
    return v.clamp(0.0, 1.0);
  }

  Future<void> saveVolume(double v) async {
    final prefs = await _prefs;
    await prefs.setDouble(_kVolume, v.clamp(0.0, 1.0));
  }

  Future<bool> loadThemeDark() async {
    final prefs = await _prefs;
    return prefs.getBool(_kThemeDark) ?? true;
  }

  Future<void> saveThemeDark(bool v) async {
    final prefs = await _prefs;
    await prefs.setBool(_kThemeDark, v);
  }

  // ---------- LAST PLAYBACK ----------
  Future<void> saveLastSession({
    required List<int> queueSongIds,
    required int index,
    required int positionMs,
    int? songId,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(_kLastQueue, jsonEncode(queueSongIds));
    await prefs.setInt(_kLastIndex, index);
    await prefs.setInt(_kLastPositionMs, positionMs);
    if (songId != null) {
      await prefs.setInt(_kLastSongId, songId);
    }
  }

  Future<void> clearLastSession() async {
    final prefs = await _prefs;
    await prefs.remove(_kLastQueue);
    await prefs.remove(_kLastIndex);
    await prefs.remove(_kLastPositionMs);
    await prefs.remove(_kLastSongId);
  }

  Future<List<int>> loadLastQueueSongIds() async {
    final prefs = await _prefs;
    final s = prefs.getString(_kLastQueue);
    if (s == null || s.isEmpty) return [];

    try {
      final decoded = jsonDecode(s);
      if (decoded is! List) return [];
      return decoded.map((e) => (e is int) ? e : int.tryParse(e.toString()) ?? 0).where((x) => x > 0).toList();
    } catch (_) {
      return [];
    }
  }

  Future<int> loadLastIndex() async {
    final prefs = await _prefs;
    final v = prefs.getInt(_kLastIndex) ?? 0;
    return v < 0 ? 0 : v;
  }

  Future<int> loadLastPositionMs() async {
    final prefs = await _prefs;
    final v = prefs.getInt(_kLastPositionMs) ?? 0;
    return v < 0 ? 0 : v;
  }

  Future<int?> loadLastSongId() async {
    final prefs = await _prefs;
    final v = prefs.getInt(_kLastSongId);
    if (v == null || v <= 0) return null;
    return v;
  }
}
