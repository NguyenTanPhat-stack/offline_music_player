import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../utils/constants.dart';
import 'album_art.dart';

class SongTile extends StatelessWidget {
  final SongModelX song;
  final VoidCallback onTap;
  final VoidCallback onMore;
  final IconData moreIcon;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    required this.onMore,
    this.moreIcon = Icons.playlist_add,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      child: ListTile(
        onTap: onTap,
        leading: AlbumArt(songId: song.id, size: 46, radius: 8),
        title: Text(song.title, style: const TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(song.artist, style: const TextStyle(color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: IconButton(
          icon: Icon(moreIcon, color: Colors.white),
          onPressed: onMore,
        ),
      ),
    );
  }
}
