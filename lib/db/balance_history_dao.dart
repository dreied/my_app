import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';

class BalanceHistoryDao {
  Future<Database> get _db async => await AppDatabase.instance.database;

  Future<void> addHistory({
  required int customerId,
  required double change,
  required double newBalance,
  required String note,
  Database? txn,
}) async {
  final db = txn ?? await AppDatabase.instance.database;

  await db.insert('balance_history', {
    'customer_id': customerId,
    'change': change,
    'new_balance': newBalance,
    'note': note,
    'datetime': DateTime.now().toIso8601String(),
  });
}


  Future<List<Map<String, dynamic>>> getHistory(int customerId) async {
  final db = await _db;

  return await db.query(
    'balance_history',
    where: 'customer_id = ?',
    whereArgs: [customerId],
    orderBy: 'datetime DESC',
  );
}

}
