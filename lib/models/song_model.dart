import 'package:on_audio_query/on_audio_query.dart';

class SongModelX {
  final int id;
  final String title;
  final String artist;
  final String? album;
  final String filePath;
  final Duration duration;

  // artwork uri (Android content://media/...)
  final Uri? artUri;

  const SongModelX({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.filePath,
    required this.duration,
    required this.artUri,
  });

  factory SongModelX.fromAudioQuery(SongModel song) {
    return SongModelX(
      id: song.id,
      title: song.title,
      artist: song.artist ?? 'Unknown Artist',
      album: song.album,
      filePath: song.data,
      duration: Duration(milliseconds: song.duration ?? 0),
      artUri: Uri.parse("content://media/external/audio/albumart/${song.albumId ?? 0}"),
    );
  }
}
