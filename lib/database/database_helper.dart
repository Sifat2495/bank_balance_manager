import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/card_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cards.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
        onConfigure: _onConfigure,
      );
    } catch (e) {
      throw Exception('Failed to initialize database: $e');
    }
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE cards (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      type TEXT NOT NULL,
      balance REAL NOT NULL,
      logo TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      card_id INTEGER NOT NULL,
      type TEXT NOT NULL,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      balance_after REAL NOT NULL,
      FOREIGN KEY (card_id) REFERENCES cards (id)
        ON DELETE CASCADE
    )
  ''');
  }

  Future<List<Map<String, dynamic>>> getTransactionsForCard(int cardId) async {
    try {
      final db = await database;
      return await db.query(
        'transactions',
        where: 'card_id = ?',
        whereArgs: [cardId],
        orderBy: 'date DESC',
      );
    } catch (e) {
      throw Exception('Failed to get transactions for card: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    try {
      final db = await database;
      return await db.rawQuery('''
      SELECT transactions.*, cards.name as card_name
      FROM transactions
      JOIN cards ON transactions.card_id = cards.id
      ORDER BY transactions.date DESC
    ''');
    } catch (e) {
      throw Exception('Failed to get all transactions: $e');
    }
  }

  Future<CardModel> insertCard(CardModel card) async {
    try {
      final db = await database;
      final id = await db.insert('cards', card.toMap());
      return CardModel(
        id: id,
        name: card.name,
        type: card.type,
        balance: card.balance,
        logo: card.logo,
      );
    } catch (e) {
      throw Exception('Failed to insert card: $e');
    }
  }

  Future<List<CardModel>> getAllCards() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('cards');
      return List.generate(maps.length, (i) => CardModel.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to get cards: $e');
    }
  }

  Future<void> updateCardBalance(int id, double newBalance) async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        await txn.update(
          'cards',
          {'balance': newBalance},
          where: 'id = ?',
          whereArgs: [id],
        );
      });
    } catch (e) {
      throw Exception('Failed to update card balance: $e');
    }
  }

  Future<void> deleteCard(int id) async {
    try {
      final db = await database;
      await db.delete('cards', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Failed to delete card: $e');
    }
  }

  Future<void> recordTransaction(int cardId, String type, double amount, double balanceAfter) async {
    try {
      final db = await database;
      await db.insert('transactions', {
        'card_id': cardId,
        'type': type,
        'amount': amount,
        'date': DateTime.now().toIso8601String(),
        'balance_after': balanceAfter,
      });
    } catch (e) {
      throw Exception('Failed to record transaction: $e');
    }
  }
}