import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // KEYS
  static const _keyStoreName = 'storeName';
  static const _keyStoreLogoPath = 'storeLogoPath';
  static const _keyLanguage = 'language';
  static const _keyThemeDark = 'themeDark';

  static const _keyPrinterName = 'printerName';
  static const _keyPrinterMac = 'printerMac';
  static const _keyPrinterWidth = 'printerWidth';

  static const _keyLowStockThreshold = 'lowStockThreshold';

  // BACKUP KEYS
  static const _keyBackupFolder = 'backupFolder';
  static const _keyAutoBackup = 'autoBackup';
  static const _keyBackupFrequency = 'backupFrequency';
  static const _keyLastBackupDate = 'lastBackupDate';

  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();
  static SettingsService get instance => _instance;

  late SharedPreferences _prefs;

  // FIELDS
  String _storeName = '';
  String _storeLogoPath = '';
  String _language = 'en';
  bool _isDark = false;

  String _printerName = '';
  String _printerMac = '';
  int _printerWidth = 58;

  int _lowStockThreshold = 12;

  // BACKUP FIELDS
  String backupFolder = '';
  bool autoBackup = false;
  String backupFrequency = "Weekly";
  String lastBackupDate = "";

  // GETTERS
  String get storeName => _storeName;
  String get storeLogoPath => _storeLogoPath;
  String get language => _language;
  bool get isDark => _isDark;

  String get printerName => _printerName;
  String get printerMac => _printerMac;
  int get printerWidth => _printerWidth;

  int get lowStockThreshold => _lowStockThreshold;

  // LOAD SETTINGS
  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();

    _storeName = _prefs.getString(_keyStoreName) ?? '';
    _storeLogoPath = _prefs.getString(_keyStoreLogoPath) ?? '';
    _language = _prefs.getString(_keyLanguage) ?? 'en';
    _isDark = _prefs.getBool(_keyThemeDark) ?? false;

    _printerName = _prefs.getString(_keyPrinterName) ?? '';
    _printerMac = _prefs.getString(_keyPrinterMac) ?? '';
    _printerWidth = _prefs.getInt(_keyPrinterWidth) ?? 58;

    _lowStockThreshold = _prefs.getInt(_keyLowStockThreshold) ?? 12;

    backupFolder = _prefs.getString(_keyBackupFolder) ?? '';
    autoBackup = _prefs.getBool(_keyAutoBackup) ?? false;
    backupFrequency = _prefs.getString(_keyBackupFrequency) ?? "Weekly";
    lastBackupDate = _prefs.getString(_keyLastBackupDate) ?? "";
  }

  // STORE SETTINGS
  Future<void> setStoreName(String value) async {
    _storeName = value;
    await _prefs.setString(_keyStoreName, value);
  }

  Future<void> setStoreLogoPath(String originalPath) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final newPath = '${dir.path}/store_logo.png';

      final file = File(originalPath);
      if (await file.exists()) {
        await file.copy(newPath);
        _storeLogoPath = newPath;
        await _prefs.setString(_keyStoreLogoPath, newPath);
      }
    } catch (_) {}
  }

  // LANGUAGE & THEME
  Future<void> setLanguage(String value) async {
    _language = value;
    await _prefs.setString(_keyLanguage, value);
  }

  Future<void> setTheme(bool dark) async {
    _isDark = dark;
    await _prefs.setBool(_keyThemeDark, dark);
  }

  // PRINTER SETTINGS
  Future<void> setPrinter({
    required String name,
    required String mac,
  }) async {
    _printerName = name;
    _printerMac = mac;
    await _prefs.setString(_keyPrinterName, name);
    await _prefs.setString(_keyPrinterMac, mac);
  }

  Future<void> setPrinterWidth(int value) async {
    _printerWidth = value;
    await _prefs.setInt(_keyPrinterWidth, value);
  }

  Future<void> clearPrinter() async {
    _printerName = '';
    _printerMac = '';
    await _prefs.remove(_keyPrinterName);
    await _prefs.remove(_keyPrinterMac);
  }

  // LOW STOCK
  Future<void> setLowStockThreshold(int value) async {
    _lowStockThreshold = value;
    await _prefs.setInt(_keyLowStockThreshold, value);
  }

  // BACKUP SETTINGS
  Future<void> setBackupFolder(String path) async {
    backupFolder = path;
    await _prefs.setString(_keyBackupFolder, path);
  }

  Future<void> setAutoBackup(bool value) async {
    autoBackup = value;
    await _prefs.setBool(_keyAutoBackup, value);
  }

  Future<void> setBackupFrequency(String value) async {
    backupFrequency = value;
    await _prefs.setString(_keyBackupFrequency, value);
  }

  Future<void> setLastBackupDate(String date) async {
    lastBackupDate = date;
    await _prefs.setString(_keyLastBackupDate, date);
  }
}
