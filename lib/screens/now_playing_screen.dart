import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';
import '../widgets/album_art.dart';
import '../widgets/player_controls.dart';
import '../widgets/progress_bar.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<MediaItem?>(
          stream: audio.mediaItemStream,
          builder: (context, snapshot) {
            final item = snapshot.data;
            if (item == null) {
              return const Center(child: Text('No song playing', style: TextStyle(color: Colors.white)));
            }

            final songId = (item.extras?['songId'] as int?) ?? int.tryParse(item.id) ?? 0;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text('Now Playing', style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))],
                          ),
                          child: AlbumArt(songId: songId, size: 300, radius: 10),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          item.title,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(item.artist ?? 'Unknown Artist', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 18),
                        StreamBuilder<Duration>(
                          stream: audio.positionStream,
                          builder: (context, posSnap) {
                            final pos = posSnap.data ?? Duration.zero;
                            final dur = item.duration ?? Duration.zero;
                            return ProgressBar(
                              position: pos,
                              duration: dur,
                              onSeek: audio.seek,
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        PlayerControls(audio: audio),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(Icons.volume_down, color: Colors.grey),
                            Expanded(
                              child: Slider(
                                value: audio.volume.clamp(0.0, 1.0),
                                onChanged: (v) => audio.setVolume(v),
                                activeColor: AppColors.primary,
                                inactiveColor: Colors.grey.shade800,
                              ),
                            ),
                            const Icon(Icons.volume_up, color: Colors.grey),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
