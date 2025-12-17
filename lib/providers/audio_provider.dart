import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';

import '../models/song_model.dart';
import '../services/storage_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioHandler handler;
  final StorageService storage;
bool get hasQueue => _queueSongs.isNotEmpty;

  AudioProvider({
    required this.handler,
    required this.storage,
  }) {
    _init();
  }

  List<SongModelX> _queueSongs = [];
  int _currentIndex = 0;

  bool _shuffle = false;
  int _repeatMode = 0; 
  double _volume = 1.0;

  Timer? _saveTimer;

  Stream<PlaybackState> get playbackStateStream => handler.playbackState;
  Stream<MediaItem?> get mediaItemStream => handler.mediaItem;
  Stream<Duration> get positionStream => AudioService.position;

  bool get isPlaying => handler.playbackState.value.playing;
  bool get shuffleEnabled => _shuffle;
  int get repeatMode => _repeatMode;
  double get volume => _volume;

  SongModelX? get currentSong {
    if (_queueSongs.isEmpty) return null;
    if (_currentIndex < 0 || _currentIndex >= _queueSongs.length) return null;
    return _queueSongs[_currentIndex];
  }

  Future<void> _init() async {
    _shuffle = await storage.loadShuffle();
    _repeatMode = await storage.loadRepeatMode();
    _volume = await storage.loadVolume();

    await handler.customAction('setShuffle', {'enabled': _shuffle});
    await handler.customAction('setRepeatModeInt', {'mode': _repeatMode});
    await handler.customAction('setVolume', {'v': _volume});

    handler.playbackState.listen((state) {
      final idx = state.queueIndex;
      if (idx != null && idx != _currentIndex) {
        _currentIndex = idx;
        notifyListeners();
      }
    });

    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final song = currentSong;
      if (song == null) return;

    final posMs = (await AudioService.position.first).inMilliseconds;

      await storage.saveLastSession(
        queueSongIds: _queueSongs.map((e) => e.id).toList(),
        index: _currentIndex,
        positionMs: posMs,
      );
    });
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }

  List<MediaItem> _toMediaItems(List<SongModelX> songs) {
    return songs.map((s) {
      return MediaItem(
        id: s.id.toString(),
        title: s.title,
        artist: s.artist,
        album: s.album,
        duration: s.duration,
        extras: {
          'filePath': s.filePath,
          'songId': s.id,
        },
      );
    }).toList();
  }

  Future<void> setPlaylistAndPlay(List<SongModelX> songs, int startIndex) async {
    if (songs.isEmpty) return;

    _queueSongs = songs;
    _currentIndex = startIndex.clamp(0, songs.length - 1);

    final items = _toMediaItems(songs);

    await handler.updateQueue(items);
    await handler.customAction('setPlaylist', {
      'items': items
          .map((e) => {
                'id': e.id,
                'title': e.title,
                'artist': e.artist,
                'album': e.album,
                'durationMs': e.duration?.inMilliseconds ?? 0,
                'extras': e.extras,
              })
          .toList(),
      'startIndex': _currentIndex,
      'startPositionMs': 0,
    });

    await play();
    notifyListeners();
  }

  Future<void> restoreLastSession(List<SongModelX> allSongs) async {
    if (allSongs.isEmpty) return;

    final queueIds = await storage.loadLastQueueSongIds();
    if (queueIds.isEmpty) return;

    final lastIndex = await storage.loadLastIndex();
    final posMs = await storage.loadLastPositionMs();

    final restored = <SongModelX>[];
    for (final id in queueIds) {
      final s = allSongs.where((e) => e.id == id).toList();
      if (s.isNotEmpty) restored.add(s.first);
    }

    if (restored.isEmpty) return;

    final safeIndex = lastIndex.clamp(0, restored.length - 1);

    _queueSongs = restored;
    _currentIndex = safeIndex;

    final items = _toMediaItems(restored);

    await handler.updateQueue(items);
    await handler.customAction('setPlaylist', {
      'items': items
          .map((e) => {
                'id': e.id,
                'title': e.title,
                'artist': e.artist,
                'album': e.album,
                'durationMs': e.duration?.inMilliseconds ?? 0,
                'extras': e.extras,
              })
          .toList(),
      'startIndex': safeIndex,
      'startPositionMs': posMs,
    });

    notifyListeners();
  }

  Future<void> play() => handler.play();
  Future<void> pause() => handler.pause();
  Future<void> stop() => handler.stop();
  Future<void> next() => handler.skipToNext();
  Future<void> previous() => handler.skipToPrevious();
  Future<void> seek(Duration d) => handler.seek(d);

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> toggleShuffle() async {
    _shuffle = !_shuffle;
    await handler.customAction('setShuffle', {'enabled': _shuffle});
    await storage.saveShuffle(_shuffle);
    notifyListeners();
  }

  Future<void> cycleRepeat() async {
    _repeatMode = (_repeatMode + 1) % 3;
    await handler.customAction('setRepeatModeInt', {'mode': _repeatMode});
    await storage.saveRepeatMode(_repeatMode);
    notifyListeners();
  }

  Future<void> setVolume(double v) async {
    _volume = v.clamp(0.0, 1.0);
    await handler.customAction('setVolume', {'v': _volume});
    await storage.saveVolume(_volume);
    notifyListeners();
  }
}
