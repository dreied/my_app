import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import '../utils/pin_hash.dart';

class ManagerDao {
  static Future<void> savePin(String pin) async {
    final db = await AppDatabase.instance.database;

    final hashed = PinHash.hashPin(pin);

    await db.delete('manager'); // only one manager
    await db.insert(
      'manager',
      {'pin': hashed},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<bool> verifyPin(String pin) async {
    final db = await AppDatabase.instance.database;

    final result = await db.query('manager', limit: 1);
    if (result.isEmpty) return false;

    final storedHash = result.first['pin'] as String;
    return PinHash.verify(pin, storedHash);
  }

  static Future<bool> hasPin() async {
    final db = await AppDatabase.instance.database;
    final result = await db.query('manager', limit: 1);
    return result.isNotEmpty;
  }
}
