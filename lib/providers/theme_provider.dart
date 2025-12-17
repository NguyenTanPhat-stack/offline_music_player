import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService storage;
  bool _dark = true;

  ThemeProvider(this.storage);

  bool get isDark => _dark;

  Future<void> init() async {
    _dark = await storage.loadThemeDark();
    notifyListeners();
  }

  Future<void> toggle() async {
    _dark = !_dark;
    await storage.saveThemeDark(_dark);
    notifyListeners();
  }

  ThemeMode get themeMode => _dark ? ThemeMode.dark : ThemeMode.light;
}
