import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';

import '../providers/audio_provider.dart';
import '../utils/constants.dart';
import '../screens/now_playing_screen.dart';
import 'album_art.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();

    return Material(
      color: AppColors.card,
      child: StreamBuilder<MediaItem?>(
        stream: audio.mediaItemStream,
        builder: (_, snap) {
          final item = snap.data;
          if (item == null) return const SizedBox.shrink();

          final songId = (item.extras?['songId'] as int?) ?? int.tryParse(item.id) ?? 0;

          return InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NowPlayingScreen())),
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  AlbumArt(songId: songId, size: 52, radius: 8),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(item.artist ?? 'Unknown Artist',
                            maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(audio.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                    onPressed: () => audio.togglePlayPause(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    onPressed: () => audio.next(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
