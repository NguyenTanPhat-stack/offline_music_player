import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../utils/constants.dart';

class AlbumArt extends StatelessWidget {
  final int songId;
  final double size;
  final double radius;

  const AlbumArt({
    super.key,
    required this.songId,
    required this.size,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: QueryArtworkWidget(
        id: songId,
        type: ArtworkType.AUDIO,
        artworkFit: BoxFit.cover,
        nullArtworkWidget: Container(
          width: size,
          height: size,
          color: AppColors.card,
          child: const Icon(Icons.music_note, color: Colors.white),
        ),
      ),
    );
  }
}
