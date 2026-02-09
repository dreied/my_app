import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyStoreName = 'storeName';
  static const _keyStoreLogoPath = 'storeLogoPath';
  static const _keyLanguage = 'language';

  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  String _storeName = '';
  String _storeLogoPath = '';
  String _language = 'en';

  String get storeName => _storeName;
  String get storeLogoPath => _storeLogoPath;
  String get language => _language;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _storeName = prefs.getString(_keyStoreName) ?? '';
    _storeLogoPath = prefs.getString(_keyStoreLogoPath) ?? '';
    _language = prefs.getString(_keyLanguage) ?? 'en';
  }

  Future<void> setStoreName(String value) async {
    _storeName = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStoreName, value);
  }

  Future<void> setStoreLogoPath(String originalPath) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final newPath = '${dir.path}/store_logo.png';

      final file = File(originalPath);
      if (await file.exists()) {
        await file.copy(newPath);
        _storeLogoPath = newPath;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyStoreLogoPath, newPath);
      }
    } catch (_) {}
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, value);
  }
}
