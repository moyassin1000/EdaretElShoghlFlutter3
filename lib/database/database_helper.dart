import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/work_record.dart';

class ReportSummary {
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final int count;

  const ReportSummary({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.count,
  });

  factory ReportSummary.empty() => const ReportSummary(
        totalRevenue: 0,
        totalExpenses: 0,
        netProfit: 0,
        count: 0,
      );
}

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _dbName = 'edaret_el_shoghl.db';
  static const int _dbVersion = 1;
  static const String tableName = 'work_records';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        title TEXT NOT NULL,
        revenue REAL NOT NULL DEFAULT 0,
        fuel REAL NOT NULL DEFAULT 0,
        garage REAL NOT NULL DEFAULT 0,
        maintenance REAL NOT NULL DEFAULT 0,
        other_expenses REAL NOT NULL DEFAULT 0,
        total_expenses REAL NOT NULL DEFAULT 0,
        net_profit REAL NOT NULL DEFAULT 0,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_work_records_date ON $tableName(date)');
    await db.execute('CREATE INDEX idx_work_records_title ON $tableName(title)');
  }

  Future<int> insertRecord(WorkRecord record) async {
    final db = await database;
    return db.insert(tableName, record.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<WorkRecord>> getRecords() async {
    final db = await database;
    final rows = await db.query(tableName, orderBy: 'date DESC, id DESC');
    return rows.map(WorkRecord.fromMap).toList();
  }

  Future<WorkRecord?> getRecordById(int id) async {
    final db = await database;
    final rows = await db.query(tableName, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return WorkRecord.fromMap(rows.first);
  }

  Future<int> updateRecord(WorkRecord record) async {
    if (record.id == null) return 0;
    final db = await database;
    return db.update(
      tableName,
      record.copyWith(updatedAt: DateTime.now().toIso8601String()).toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteRecord(int id) async {
    final db = await database;
    return db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearAll() async {
    final db = await database;
    return db.delete(tableName);
  }

  Future<List<WorkRecord>> searchRecords(String query) async {
    final db = await database;
    final q = '%${query.trim()}%';
    final rows = await db.query(
      tableName,
      where: 'title LIKE ? OR notes LIKE ? OR date LIKE ?',
      whereArgs: [q, q, q],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(WorkRecord.fromMap).toList();
  }

  Future<List<WorkRecord>> filterRecords({String? startDate, String? endDate}) async {
    final db = await database;
    String? where;
    List<Object?> args = [];
    if (startDate != null && endDate != null) {
      where = 'date BETWEEN ? AND ?';
      args = [startDate, endDate];
    } else if (startDate != null) {
      where = 'date >= ?';
      args = [startDate];
    } else if (endDate != null) {
      where = 'date <= ?';
      args = [endDate];
    }
    final rows = await db.query(tableName, where: where, whereArgs: args, orderBy: 'date DESC, id DESC');
    return rows.map(WorkRecord.fromMap).toList();
  }

  Future<ReportSummary> getSummary({String? startDate, String? endDate}) async {
    final db = await database;
    String where = '';
    List<Object?> args = [];
    if (startDate != null && endDate != null) {
      where = 'WHERE date BETWEEN ? AND ?';
      args = [startDate, endDate];
    } else if (startDate != null) {
      where = 'WHERE date >= ?';
      args = [startDate];
    } else if (endDate != null) {
      where = 'WHERE date <= ?';
      args = [endDate];
    }
    final rows = await db.rawQuery('''
      SELECT
        COALESCE(SUM(revenue), 0) AS total_revenue,
        COALESCE(SUM(total_expenses), 0) AS total_expenses,
        COALESCE(SUM(net_profit), 0) AS net_profit,
        COUNT(*) AS count
      FROM $tableName
      $where
    ''', args);
    if (rows.isEmpty) return ReportSummary.empty();
    final r = rows.first;
    return ReportSummary(
      totalRevenue: ((r['total_revenue'] as num?) ?? 0).toDouble(),
      totalExpenses: ((r['total_expenses'] as num?) ?? 0).toDouble(),
      netProfit: ((r['net_profit'] as num?) ?? 0).toDouble(),
      count: ((r['count'] as num?) ?? 0).toInt(),
    );
  }

  Future<WorkRecord?> getLastRecord() async {
    final db = await database;
    final rows = await db.query(tableName, orderBy: 'created_at DESC, id DESC', limit: 1);
    if (rows.isEmpty) return null;
    return WorkRecord.fromMap(rows.first);
  }

  Future<String> backupDatabase() async {
    final dbPath = await getDatabasesPath();
    final sourcePath = p.join(dbPath, _dbName);
    final dir = await getApplicationDocumentsDirectory();
    final backupPath = p.join(dir.path, 'backup_${DateTime.now().millisecondsSinceEpoch}_$_dbName');
    final source = File(sourcePath);
    if (!await source.exists()) {
      await database;
    }
    await File(sourcePath).copy(backupPath);
    return backupPath;
  }

  Future<void> restoreDatabase(String backupPath) async {
    await _database?.close();
    _database = null;
    final dbPath = await getDatabasesPath();
    final targetPath = p.join(dbPath, _dbName);
    await File(backupPath).copy(targetPath);
    _database = await _initDatabase();
  }
}
