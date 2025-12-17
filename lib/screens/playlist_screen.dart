import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/playlist_provider.dart';
import '../utils/constants.dart';
import 'playlist_detail_screen.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  Future<void> _create(BuildContext context) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Create playlist', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'Playlist name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create')),
        ],
      ),
    );

    if (ok == true) {
      final name = ctrl.text.trim();
      if (name.isNotEmpty) {
        await context.read<PlaylistProvider>().createPlaylist(name);
      }
    }
  }

  Future<void> _rename(BuildContext context, String id, String oldName) async {
    final ctrl = TextEditingController(text: oldName);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Rename playlist', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );

    if (ok == true) {
      final name = ctrl.text.trim();
      if (name.isNotEmpty) {
        await context.read<PlaylistProvider>().renamePlaylist(id, name);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<PlaylistProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Playlists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _create(context),
          ),
        ],
      ),
      body: pp.playlists.isEmpty
          ? const Center(child: Text('No playlists', style: TextStyle(color: Colors.white)))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 100),
              itemCount: pp.playlists.length,
              itemBuilder: (_, i) {
                final p = pp.playlists[i];
                return Card(
                  color: AppColors.card,
                  child: ListTile(
                    title: Text(p.name, style: const TextStyle(color: Colors.white)),
                    subtitle: Text('${p.songIds.length} songs', style: const TextStyle(color: Colors.grey)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PlaylistDetailScreen(playlistId: p.id)),
                      );
                    },
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'rename') await _rename(context, p.id, p.name);
                        if (v == 'delete') await context.read<PlaylistProvider>().deletePlaylist(p.id);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'rename', child: Text('Rename')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
