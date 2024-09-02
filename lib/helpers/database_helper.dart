import 'dart:async';
import 'package:path/path.dart';
import 'package:property_management/models/payment_model.dart';
import 'package:property_management/models/property_model.dart';
import 'package:property_management/models/tenant_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'property_management.db');
    print('Initializing database at: $path'); // Debugging line

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('Creating tables...'); // Debugging line
    await db.execute('''
          CREATE TABLE properties (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            address TEXT,
            type TEXT,
            units INTEGER,
            rentalCost REAL,
            tenantId INTEGER,
            FOREIGN KEY (tenantId) REFERENCES tenants(id)
          )
        ''');

    await db.execute('''
          CREATE TABLE tenants (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            contact TEXT,
            section TEXT,
            propertyId INTEGER,
            FOREIGN KEY(propertyId) REFERENCES properties(id)
          )
        ''');
    // Create the payments table
    await db.execute('''
        CREATE TABLE payments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL,
          date TEXT,
          isSettled INTEGER,
          tenantId INTEGER NULL,
          tenantName TEXT,
          FOREIGN KEY(tenantId) REFERENCES tenants(id)
        )
      ''');
    print('Tables created successfully.'); // Debugging line
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      print(
          'Upgrading database from version $oldVersion to $newVersion'); // Debugging line

      // Handle future upgrades, for example:
      // if (oldVersion < 2) {
      //   await db.execute('ALTER TABLE properties ADD COLUMN newColumn TEXT');
      // }
    }
  }

  Future<void> close() async {
    final db = await _database;
    if (db != null) {
      await db.close();
      print('Database closed'); // Debugging line
    }
  }

  // Property Methods
  Future<int> addProperty(PropertyModel property) async {
    final db = await database;
    final result = await db.insert(
      'properties',
      property.toJson()..remove('id'), // Avoid inserting an id
    );
    print('Added property with id: $result'); // Debugging line
    return result;
  }

  Future<List<PropertyModel>> fetchProperties() async {
    final db = await database;
    final maps = await db.query('properties');

    print('Fetched properties: ${maps.length}'); // Debugging line

    return List.generate(maps.length, (i) {
      return PropertyModel.fromJson(maps[i]);
    });
  }

  Future<int> updateProperty(PropertyModel property) async {
    final db = await database;
    final result = await db.update(
      'properties',
      property.toJson(),
      where: 'id = ?',
      whereArgs: [property.id],
    );
    print(
        'Updated property with id: ${property.id}, result: $result'); // Debugging line
    return result;
    // return await db.update(
    //   'properties',
    //   property.toJson(),
    //   where: 'id = ?',
    //   whereArgs: [property.id],
    // );
  }

  Future<int> deleteProperty(int id) async {
    final db = await database;
    final result = await db.delete(
      'properties',
      where: 'id = ?',
      whereArgs: [id],
    );
    print('Deleted property with id: $id, result: $result'); // Debugging line
    return result;
  }

  // Tenant Methods
  Future<int> addTenant(TenantModel tenant) async {
    final db = await database;
    final result = await db.insert(
      'tenants',
      tenant.toJson()..remove('id'), // Avoid inserting an id
    );
    print('Added tenant with id: $result'); // Debugging line
    return result;
  }

  Future<List<TenantModel>> fetchTenants() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tenants');
    print('Fetched tenants: ${maps.length}'); // Debugging line

    return List.generate(maps.length, (i) {
      return TenantModel(
        id: maps[i]['id'],
        name: maps[i]['name'],
        contact: maps[i]['contact'],
        section: maps[i]['section'],
      );
    });
  }

  Future<TenantModel?> getTenantById(int id) async {
    final db = await database;
    final maps = await db.query(
      'tenants',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      print('Fetched tenant with id: $id'); // Debugging line
      return TenantModel.fromJson(maps.first);
    } else {
      print('No tenant found with id: $id'); // Debugging line
      return null;
    }
  }

  Future<int> updateTenant(TenantModel tenant) async {
    final db = await database;
    final result = await db.update(
      'tenants',
      tenant.toJson(),
      where: 'id = ?',
      whereArgs: [tenant.id],
    );
    print(
        'Updated tenant with id: ${tenant.id}, result: $result'); // Debugging line
    return result;
  }

  // Future<int> deleteTenant(int id) async {
  //   final db = await database;
  //   final result = await db.delete(
  //     'tenants',
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  //   print('Deleted tenant with id: $id, result: $result'); // Debugging line
  //   return result;
  // }

  Future<int> deleteTenant(int id) async {
  final db = await database;

  // Start a transaction to ensure all operations complete successfully or rollback on failure
  return await db.transaction((txn) async {
    // Check if the tenant exists
    final tenant = await txn.query(
      'tenants',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (tenant.isNotEmpty) {
      // Update related payments to set tenantId to NULL
      await txn.update(
        'payments',
        {'tenantId': null}, // Set tenantId to NULL
        where: 'tenantId = ?',
        whereArgs: [id],
      );

      // Delete the tenant
      final result = await txn.delete(
        'tenants',
        where: 'id = ?',
        whereArgs: [id],
      );

      print('Deleted tenant with id: $id, result: $result');
      return result;
    } else {
      print('No tenant found with id: $id');
      return 0;
    }
  });
}

// Payment Methods
  // Future<int> addPayment(PaymentModel payment) async {
  //   final db = await database;
  //   final result = await db.insert(
  //     'payments',
  //     payment.toJson()..remove('id'), // Avoid inserting an id
  //   );
  //   print('Added payment with id: $result');
  //   return result;
  // }
  Future<int> addPayment(PaymentModel payment) async {
  final db = await database;

  // Check if tenantId is valid or allow NULL
  if (payment.tenantId == null || payment.tenantId == 0) {
    final result = await db.insert(
      'payments',
      payment.toJson()..remove('id'), // Avoid inserting an id
    );
    print('Added payment with id: $result');
    return result;
  } else {
    final tenant = await db.query(
      'tenants',
      where: 'id = ?',
      whereArgs: [payment.tenantId],
    );

    if (tenant.isNotEmpty) {
      final result = await db.insert(
        'payments',
        payment.toJson()..remove('id'), // Avoid inserting an id
      );
      print('Added payment with id: $result');
      return result;
    } else {
      print('Invalid tenantId: ${payment.tenantId}');
      // Optionally handle this case (e.g., show an error message)
      return 0;
    }
  }
}

  Future<List<PaymentModel>> fetchPayments() async {
    final db = await database;

    // Fetch payments with the corresponding tenant name
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT payments.id, payments.amount, payments.date, payments.isSettled, payments.tenantId, tenants.name AS tenantName
    FROM payments
    LEFT JOIN tenants ON payments.tenantId = tenants.id
  ''');

    print('Fetched payments: ${maps.length}'); // Debugging line

    return List.generate(maps.length, (i) {
      return PaymentModel(
        id: maps[i]['id'],
        amount: maps[i]['amount'],
        date: maps[i]['date'],
        isSettled: maps[i]['isSettled'] == 1, // Convert int to bool
        tenantId: maps[i]['tenantId'],
        tenantName: maps[i]['tenantName'],
      );
    });
  }

  Future<int> updatePayment(PaymentModel payment) async {
    final db = await database;
    final result = await db.update(
      'payments',
      payment.toJson(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
    print(
        'Updated payment with id: ${payment.id}, result: $result'); // Debugging line
    return result;
  }

  Future<int> deletePayment(int id) async {
    final db = await database;
    final result = await db.delete(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
    );
    print('Deleted payment with id: $id, result: $result'); // Debugging line
    return result;
  }
}
