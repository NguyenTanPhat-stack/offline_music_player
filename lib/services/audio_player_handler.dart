import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();


  final ConcatenatingAudioSource _playlist =
      ConcatenatingAudioSource(children: []);

  AudioPlayerHandler() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());


    _player.playbackEventStream.listen(_broadcastState);

  
    _player.currentIndexStream.listen((index) {
      final q = queue.value;
      if (index == null || index < 0 || index >= q.length) return;
      mediaItem.add(q[index]);
    });


    _player.durationStream.listen((d) {
      final item = mediaItem.valueOrNull;
      if (item == null || d == null) return;
      mediaItem.add(item.copyWith(duration: d));
    });
  }

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;

    final processingState = switch (_player.processingState) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
    };

    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          playing ? MediaControl.pause : MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.setShuffleMode,
          MediaAction.setRepeatMode,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: processingState,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _player.currentIndex,
      ),
    );
  }

  @override
  Future<void> updateQueue(List<MediaItem> newQueue) async {
    queue.add(newQueue);

    await _playlist.clear();
    await _playlist.addAll(
      newQueue.map((m) {
        final path = (m.extras?['filePath'] as String?) ?? '';
        return AudioSource.uri(
          Uri.file(path),
          tag: m,
        );
      }).toList(),
    );
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    final newQueue = [...queue.value, mediaItem];
    await updateQueue(newQueue);
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    final newQueue = [...queue.value]..remove(mediaItem);
    await updateQueue(newQueue);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    await _player.seek(Duration.zero, index: index);
    mediaItem.add(queue.value[index]);
  }

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) async {
    switch (name) {
      case 'setPlaylist':
        final startIndex = extras?['startIndex'] as int? ?? 0;
        final startPositionMs = extras?['startPositionMs'] as int? ?? 0;

        await _player.setAudioSource(
          _playlist,
          initialIndex: startIndex,
          initialPosition: Duration(milliseconds: startPositionMs),
        );

       
        final q = queue.value;
        if (q.isNotEmpty && startIndex >= 0 && startIndex < q.length) {
          mediaItem.add(q[startIndex]);
        }
        return true;

      case 'setShuffle':
        final enabled = extras?['enabled'] as bool? ?? false;
        await _player.setShuffleModeEnabled(enabled);
        if (enabled) await _player.shuffle();
        return true;

      case 'setRepeatModeInt':
        final mode = extras?['mode'] as int? ?? 0; 
        final loop = switch (mode) {
          2 => LoopMode.one,
          1 => LoopMode.all,
          _ => LoopMode.off,
        };
        await _player.setLoopMode(loop);
        return true;

      case 'setVolume':
        final v = (extras?['v'] as num?)?.toDouble() ?? 1.0;
        await _player.setVolume(v);
        return true;
    }
    return super.customAction(name, extras);
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }
}
