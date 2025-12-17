import 'package:flutter/material.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';

class PlayerControls extends StatelessWidget {
  final AudioProvider audio;
  const PlayerControls({super.key, required this.audio});

  IconData _repeatIcon(int m) => switch (m) {
        0 => Icons.repeat,
        1 => Icons.repeat,
        _ => Icons.repeat_one,
      };

  Color _repeatColor(int m) => m == 0 ? Colors.grey : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: Icon(Icons.shuffle, color: audio.shuffleEnabled ? AppColors.primary : Colors.grey),
          onPressed: () => audio.toggleShuffle(),
        ),
        IconButton(
          icon: const Icon(Icons.skip_previous, color: Colors.white, size: 34),
          onPressed: () => audio.previous(),
        ),
        Container(
          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
          child: IconButton(
            icon: Icon(audio.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 34),
            onPressed: () => audio.togglePlayPause(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.white, size: 34),
          onPressed: () => audio.next(),
        ),
        IconButton(
          icon: Icon(_repeatIcon(audio.repeatMode), color: _repeatColor(audio.repeatMode)),
          onPressed: () => audio.cycleRepeat(),
        ),
      ],
    );
  }
}
