import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/db_helper.dart';
import '../models/asset_model.dart';
import '../models/employee_model.dart';
import '../models/assignment_model.dart';
import '../models/asset_history_model.dart';

class AssetRepository {
  final DBHelper _dbHelper = DBHelper();
  final _uuid = const Uuid();

  // ---------------- ASSETS ----------------

  /// Generates an auto Asset ID like AST-0001
  Future<String> generateAssetId() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM assets');
    final count = (result.first['count'] as int? ?? 0) + 1;
    return 'AST-${count.toString().padLeft(4, '0')}';
  }

  Future<void> addAsset(AssetModel asset) async {
    final db = await _dbHelper.database;
    await db.insert('assets', asset.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    await _addHistory(
      assetId: asset.assetId,
      action: 'Created',
      details: 'Asset "${asset.assetName}" added to inventory.',
    );
  }

  Future<void> updateAsset(AssetModel asset) async {
    final db = await _dbHelper.database;
    await db.update(
      'assets',
      asset.toMap(),
      where: 'assetId = ?',
      whereArgs: [asset.assetId],
    );

    await _addHistory(
      assetId: asset.assetId,
      action: 'Updated',
      details: 'Asset details updated.',
    );
  }

  Future<List<AssetModel>> getAllAssets() async {
    final db = await _dbHelper.database;
    final maps = await db.query('assets', orderBy: 'assetId ASC');
    return maps.map((m) => AssetModel.fromMap(m)).toList();
  }

  Future<List<AssetModel>> getAvailableAssets() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'assets',
      where: 'status = ?',
      whereArgs: ['Available'],
      orderBy: 'assetId ASC',
    );
    return maps.map((m) => AssetModel.fromMap(m)).toList();
  }

  Future<AssetModel?> getAssetById(String assetId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'assets',
      where: 'assetId = ?',
      whereArgs: [assetId],
    );
    if (maps.isEmpty) return null;
    return AssetModel.fromMap(maps.first);
  }

  Future<void> updateAssetStatus(String assetId, String status) async {
    final db = await _dbHelper.database;
    await db.update(
      'assets',
      {'status': status},
      where: 'assetId = ?',
      whereArgs: [assetId],
    );
  }

  // ---------------- EMPLOYEES ----------------

  /// Generates an auto Employee ID like EMP-0001
  Future<String> generateEmployeeId() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM employees');
    final count = (result.first['count'] as int? ?? 0) + 1;
    return 'EMP-${count.toString().padLeft(4, '0')}';
  }

  Future<void> addEmployee(EmployeeModel employee) async {
    final db = await _dbHelper.database;
    await db.insert('employees', employee.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateEmployee(EmployeeModel employee) async {
    final db = await _dbHelper.database;
    await db.update(
      'employees',
      employee.toMap(),
      where: 'employeeId = ?',
      whereArgs: [employee.employeeId],
    );
  }

  Future<bool> deleteEmployee(String employeeId) async {
    final db = await _dbHelper.database;

    // Prevent deletion if employee has active assignments
    final active = await getActiveAssignmentsForEmployee(employeeId);
    if (active.isNotEmpty) return false;

    await db.delete(
      'employees',
      where: 'employeeId = ?',
      whereArgs: [employeeId],
    );
    return true;
  }

  Future<List<EmployeeModel>> getAllEmployees() async {
    final db = await _dbHelper.database;
    final maps = await db.query('employees', orderBy: 'employeeName ASC');
    return maps.map((m) => EmployeeModel.fromMap(m)).toList();
  }

  // ---------------- ASSIGNMENTS ----------------

  Future<void> assignAsset(AssignmentModel assignment) async {
    final db = await _dbHelper.database;

    await db.insert('assignments', assignment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    await updateAssetStatus(assignment.assetId, 'Assigned');

    await _addHistory(
      assetId: assignment.assetId,
      action: 'Assigned',
      details:
          'Assigned to ${assignment.employeeName} (${assignment.department}) on ${assignment.assignedDate}.',
    );
  }

  Future<void> returnAsset({
    required String assignmentId,
    required String assetId,
    required String returnedDate,
    String? remarks,
  }) async {
    final db = await _dbHelper.database;

    await db.update(
      'assignments',
      {
        'returnedDate': returnedDate,
        'status': 'Returned',
        if (remarks != null) 'remarks': remarks,
      },
      where: 'assignmentId = ?',
      whereArgs: [assignmentId],
    );

    await updateAssetStatus(assetId, 'Available');

    await _addHistory(
      assetId: assetId,
      action: 'Returned',
      details: 'Asset returned on $returnedDate.'
          '${remarks != null && remarks.isNotEmpty ? ' Remarks: $remarks' : ''}',
    );
  }

  Future<List<AssignmentModel>> getActiveAssignmentsForEmployee(
      String employeeId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'assignments',
      where: 'employeeId = ? AND status = ?',
      whereArgs: [employeeId, 'Active'],
    );
    return maps.map((m) => AssignmentModel.fromMap(m)).toList();
  }

  Future<List<AssignmentModel>> getActiveAssignments() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'assignments',
      where: 'status = ?',
      whereArgs: ['Active'],
      orderBy: 'assignedDate DESC',
    );
    return maps.map((m) => AssignmentModel.fromMap(m)).toList();
  }

  Future<AssignmentModel?> getActiveAssignmentForAsset(String assetId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'assignments',
      where: 'assetId = ? AND status = ?',
      whereArgs: [assetId, 'Active'],
    );
    if (maps.isEmpty) return null;
    return AssignmentModel.fromMap(maps.first);
  }

  Future<List<AssignmentModel>> getAllAssignments() async {
    final db = await _dbHelper.database;
    final maps = await db.query('assignments', orderBy: 'assignedDate DESC');
    return maps.map((m) => AssignmentModel.fromMap(m)).toList();
  }

  // ---------------- ASSET HISTORY ----------------

  Future<void> _addHistory({
    required String assetId,
    required String action,
    String? details,
  }) async {
    final db = await _dbHelper.database;
    final history = AssetHistoryModel(
      historyId: _uuid.v4(),
      assetId: assetId,
      action: action,
      details: details,
      timestamp: DateTime.now().toIso8601String(),
    );
    await db.insert('asset_history', history.toMap());
  }

  Future<List<AssetHistoryModel>> getHistoryForAsset(String assetId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'asset_history',
      where: 'assetId = ?',
      whereArgs: [assetId],
      orderBy: 'timestamp DESC',
    );
    return maps.map((m) => AssetHistoryModel.fromMap(m)).toList();
  }

  Future<List<AssetHistoryModel>> getAllHistory() async {
    final db = await _dbHelper.database;
    final maps = await db.query('asset_history', orderBy: 'timestamp DESC');
    return maps.map((m) => AssetHistoryModel.fromMap(m)).toList();
  }

  // ---------------- DASHBOARD STATS ----------------

  Future<Map<String, int>> getDashboardStats() async {
    final db = await _dbHelper.database;
    final total = await db.rawQuery('SELECT COUNT(*) as c FROM assets');
    final available = await db.rawQuery(
        "SELECT COUNT(*) as c FROM assets WHERE status = 'Available'");
    final assigned = await db.rawQuery(
        "SELECT COUNT(*) as c FROM assets WHERE status = 'Assigned'");
    final maintenance = await db.rawQuery(
        "SELECT COUNT(*) as c FROM assets WHERE status = 'Under Maintenance'");
    final retired = await db.rawQuery(
        "SELECT COUNT(*) as c FROM assets WHERE status = 'Retired'");

    return {
      'total': (total.first['c'] as int?) ?? 0,
      'available': (available.first['c'] as int?) ?? 0,
      'assigned': (assigned.first['c'] as int?) ?? 0,
      'maintenance': (maintenance.first['c'] as int?) ?? 0,
      'retired': (retired.first['c'] as int?) ?? 0,
    };
  }
}
