import 'dart:io';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../generated/app_localizations.dart';

class BackupService {
  static const String dbName = "pos.db";

  static Future<String> getDatabasePath() async {
    final dbDir = await getDatabasesPath();
    return "$dbDir/$dbName";
  }

  /// Create backup into the user-chosen folder
  static Future<String> createBackupToFolder(
      String folderPath, AppLocalizations t) async {
    final dbPath = await getDatabasePath();

    if (!File(dbPath).existsSync()) {
      throw Exception(t.backupDatabaseNotFound);
    }

    // Request permissions
    if (Platform.isAndroid) {
      if (!await Permission.manageExternalStorage.isGranted &&
          !await Permission.storage.isGranted) {
        await Permission.manageExternalStorage.request();
        await Permission.storage.request();
      }
    }

    Directory targetDir;
    if (await Permission.manageExternalStorage.isGranted ||
        await Permission.storage.isGranted) {
      targetDir = Directory(folderPath);
    } else {
      // Fallback to app-specific external dir
      targetDir = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      if (targetDir == null) {
        throw Exception(t.backupPermissionDenied);
      }
    }

    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }

    final timestamp = DateFormat("yyyyMMdd_HHmmss").format(DateTime.now());
    final backupPath = "${targetDir.path}/backup_$timestamp.db";

    await File(dbPath).copy(backupPath);
    return backupPath;
  }

  /// Restore backup
  static Future<void> restoreBackup(
      String backupFilePath, AppLocalizations t) async {
    final dbPath = await getDatabasePath();

    if (!File(backupFilePath).existsSync()) {
      throw Exception(t.backupFileNotFound);
    }

    await File(backupFilePath).copy(dbPath);
  }

  /// List backups in folder
  static Future<List<FileSystemEntity>> listBackupsInFolder(
      String folder) async {
    final dir = Directory(folder);
    if (!dir.existsSync()) return [];
    return dir
        .listSync()
        .where((f) => f.path.toLowerCase().endsWith(".db"))
        .toList();
  }

  /// Get backup size
  static Future<String> getBackupSize(String folderPath) async {
    final dir = Directory(folderPath);
    if (!dir.existsSync()) return "0 KB";

    int totalBytes = 0;
    for (var file in dir.listSync()) {
      if (file is File && file.path.endsWith(".db")) {
        totalBytes += await file.length();
      }
    }

    double kb = totalBytes / 1024;
    double mb = kb / 1024;

    return mb >= 1
        ? "${mb.toStringAsFixed(2)} MB"
        : "${kb.toStringAsFixed(2)} KB";
  }

  /// Daily backup check
  static Future<bool> shouldRunDailyBackup(String lastDate) async {
    if (lastDate.isEmpty) return true;
    final last = DateTime.tryParse(lastDate);
    if (last == null) return true;
    final now = DateTime.now();
    return now.year != last.year ||
        now.month != last.month ||
        now.day != last.day;
  }
}
