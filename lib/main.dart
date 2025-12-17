import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';

import 'services/audio_handler_service.dart';
import 'services/storage_service.dart';

import 'providers/audio_provider.dart';
import 'providers/playlist_provider.dart';

import 'screens/main_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final handler = await AudioHandlerService.init();
  final storage = StorageService();

  runApp(
    MultiProvider(
      providers: [
        Provider<AudioHandler>.value(value: handler),
        Provider<StorageService>.value(value: storage),

        ChangeNotifierProvider(
          create: (_) => PlaylistProvider(storage)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => AudioProvider(handler: handler, storage: storage),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const MainNavigation(),
    );
  }
}
