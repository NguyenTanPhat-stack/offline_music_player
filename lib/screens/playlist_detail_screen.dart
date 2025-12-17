import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/playlist_provider.dart';
import '../providers/audio_provider.dart';
import '../services/music_library_service.dart';
import '../models/song_model.dart';
import '../utils/constants.dart';
import '../widgets/song_tile.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;
  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final _lib = MusicLibraryService();
  List<SongModelX> _allSongs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final songs = await _lib.getAllSongs();
    if (!mounted) return;
    setState(() {
      _allSongs = songs;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<PlaylistProvider>();
    final audio = context.read<AudioProvider>();
    final p = pp.playlists.firstWhere((x) => x.id == widget.playlistId);

    final playlistSongs = _allSongs.where((s) => p.songIds.contains(s.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(p.name),
        actions: [
          if (playlistSongs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () => audio.setPlaylistAndPlay(playlistSongs, 0),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : playlistSongs.isEmpty
              ? const Center(child: Text('Playlist empty', style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 110),
                  itemCount: playlistSongs.length,
                  itemBuilder: (_, i) {
                    final s = playlistSongs[i];
                    return SongTile(
                      song: s,
                      onTap: () => audio.setPlaylistAndPlay(playlistSongs, i),
                      onMore: () async => pp.removeSong(p.id, s.id),
                      moreIcon: Icons.remove_circle_outline,
                    );
                  },
                ),
    );
  }
}
