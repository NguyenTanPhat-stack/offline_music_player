import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  const ProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${two(m)}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final maxMs = duration.inMilliseconds <= 0 ? 1 : duration.inMilliseconds;
    final posMs = position.inMilliseconds.clamp(0, maxMs);

    return Column(
      children: [
        Slider(
          value: posMs.toDouble(),
          min: 0,
          max: maxMs.toDouble(),
          onChanged: (v) => onSeek(Duration(milliseconds: v.toInt())),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_fmt(Duration(milliseconds: posMs)), style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(_fmt(duration), style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
