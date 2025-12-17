import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../services/music_library_service.dart';
import '../services/permission_service.dart';
import '../utils/constants.dart';
import '../widgets/song_tile.dart';

class AllSongsScreen extends StatefulWidget {
  const AllSongsScreen({super.key});

  @override
  State<AllSongsScreen> createState() => _AllSongsScreenState();
}

class _AllSongsScreenState extends State<AllSongsScreen> {
  final _permission = PermissionService();
  final _library = MusicLibraryService();

  bool _loading = true;
  bool _granted = false;

  SortBy _sortBy = SortBy.title;
  List<SongModelX> _songs = [];
  List<SongModelX> _filtered = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final granted = await _permission.requestMusicPermissions();
    if (!mounted) return;

    _granted = granted;

    if (_granted) {
      await _loadSongs(restore: true);
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _loadSongs({bool restore = false}) async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final songs = await _library.getAllSongs(sortBy: _sortBy);
      if (!mounted) return;

      setState(() {
        _songs = songs;
        _applyFilter(); // dùng _query hiện tại
      });

      // restore session sau khi UI đã có list (tránh đứng)
      if (restore && _songs.isNotEmpty) {
        try {
          await context.read<AudioProvider>().restoreLastSession(_songs);
        } catch (_) {}
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      _filtered = List.of(_songs);
      return;
    }
    _filtered = _songs.where((s) {
      return s.title.toLowerCase().contains(q) ||
          s.artist.toLowerCase().contains(q) ||
          (s.album?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<void> _showAddToPlaylist(SongModelX song) async {
    final pp = context.read<PlaylistProvider>();
    if (pp.playlists.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có playlist. Tạo playlist trước nha.')),
      );
      return;
    }

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.card,
      builder: (sheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Add to playlist',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              ...pp.playlists.map((p) {
                return ListTile(
                  title: Text(p.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text('${p.songIds.length} songs', style: const TextStyle(color: Colors.grey)),
                  onTap: () => Navigator.pop(sheetCtx, p.id),
                );
              }),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      await pp.addSong(selected, song.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã thêm "${song.title}" vào playlist')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final audio = context.read<AudioProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('My Music'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<SortBy>(
              value: _sortBy,
              dropdownColor: AppColors.card,
              icon: const Icon(Icons.sort, color: Colors.white),
              items: const [
                DropdownMenuItem(value: SortBy.title, child: Text('Title')),
                DropdownMenuItem(value: SortBy.artist, child: Text('Artist')),
                DropdownMenuItem(value: SortBy.album, child: Text('Album')),
                DropdownMenuItem(value: SortBy.dateAdded, child: Text('Date Added')),
              ],
              onChanged: (v) async {
                if (v == null) return;
                setState(() => _sortBy = v);
                await _loadSongs(restore: false); // đổi sort thì không cần restore session
              },
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search song / artist / album...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) {
                  setState(() {
                    _query = v;
                    _applyFilter();
                  });
                },
              ),
            ),
            Expanded(
              child: !_granted
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Cần quyền truy cập nhạc/storage.\nBạn vào Settings cấp quyền rồi mở lại app.',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : _loading
                      ? const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        )
                      : _filtered.isEmpty
                          ? const Center(
                              child: Text('No music found', style: TextStyle(color: Colors.white)),
                            )
                          : RefreshIndicator(
                              onRefresh: () => _loadSongs(restore: false),
                              child: ListView.builder(
                                padding: const EdgeInsets.only(bottom: 110),
                                itemCount: _filtered.length,
                                itemBuilder: (context, i) {
                                  final s = _filtered[i];
                                  return SongTile(
                                    song: s,
                                    onTap: () => audio.setPlaylistAndPlay(_filtered, i),
                                    onMore: () => _showAddToPlaylist(s),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
