import 'package:property_management/helpers/database_helper.dart';
import 'package:property_management/models/tenant_model.dart';

class TenantService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Fetches all tenants from the database
  Future<List<TenantModel>> fetchTenants() async {
  //   try {
  //   // Simulate fetching from a database
  //   return await _dbHelper.fetchTenants(); // Replace with your actual fetch code
  // } catch (e) {
  //   print('Error fetching properties: $e');
  //   throw e;
  // }
  final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('tenants');
    return List.generate(maps.length, (i) {
      return TenantModel.fromJson(maps[i]);
    });
  }

// Fetch a single tenant by ID
  Future<TenantModel?> getTenantById(int? id) async {
    if (id == null) return null;
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('tenants', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return TenantModel.fromJson(maps.first);
    } else {
      return null;
    }
  }

  /// Adds a new tenant to the database
  Future<void> addTenant(TenantModel tenant) async {
    // final db = await _dbHelper.database;
    // return await db.insert('tenants', tenant.toJson());
     await _dbHelper.addTenant(tenant);
  }

  /// Updates an existing tenant in the database
  Future<int> updateTenant(TenantModel tenant) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tenants',
      tenant.toJson(),
      where: 'id = ?',
      whereArgs: [tenant.id],
    );
  }

  /// Deletes a tenant from the database by ID
  Future<int> deleteTenant(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'tenants',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
