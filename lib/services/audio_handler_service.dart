import 'package:audio_service/audio_service.dart';
import 'audio_player_handler.dart';

class AudioHandlerService {
  static Future<AudioHandler> init() async {
    return AudioService.init(
      builder: () => AudioPlayerHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.offline_music_player.channel.audio',
        androidNotificationChannelName: 'Music Playback',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: false,
      ),
    );
  }
}
