  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) async {
    switch (name) {
      case 'setPlaylist':
        final startIndex = extras?['startIndex'] as int;
        final startPositionMs = extras?['startPositionMs'] as int;

        // queue là MediaItem list đã update từ UI
        final items = queue.value;

        _playlist.clear();
        await _playlist.addAll(
          items.map((m) {
            final fp = m.extras?['filePath'] as String?;
            return AudioSource.uri(Uri.file(fp ?? ''), tag: m);
          }).toList(),
        );

        await _player.setAudioSource(
          _playlist,
          initialIndex: startIndex,
          initialPosition: Duration(milliseconds: startPositionMs),
        );

        if (items.isNotEmpty) {
          mediaItem.add(items[startIndex]);
        }
        return null;

      case 'setShuffle':
        final enabled = extras?['enabled'] as bool;
        await setShuffle(enabled);
        return null;

      case 'setRepeatModeInt':
        final mode = extras?['mode'] as int;
        await setRepeatModeInt(mode);
        return null;

      case 'setVolume':
        final v = (extras?['v'] as num).toDouble();
        await setVolume(v);
        return null;

      default:
        return super.customAction(name, extras);
    }
  }
