import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _repeatLabel(int m) => switch (m) { 0 => 'Off', 1 => 'All', _ => 'One' };

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: AppColors.card,
            child: ListTile(
              title: const Text('Shuffle', style: TextStyle(color: Colors.white)),
              trailing: Switch(
                value: audio.shuffleEnabled,
                onChanged: (_) => audio.toggleShuffle(),
              ),
            ),
          ),
          Card(
            color: AppColors.card,
            child: ListTile(
              title: const Text('Repeat mode', style: TextStyle(color: Colors.white)),
              subtitle: Text(_repeatLabel(audio.repeatMode), style: const TextStyle(color: Colors.grey)),
              trailing: IconButton(
                icon: const Icon(Icons.repeat, color: Colors.white),
                onPressed: () => audio.cycleRepeat(),
              ),
            ),
          ),
          Card(
            color: AppColors.card,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Volume', style: TextStyle(color: Colors.white)),
                  Slider(
                    value: audio.volume,
                    onChanged: (v) => audio.setVolume(v),
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.grey.shade800,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
