import 'package:property_management/helpers/database_helper.dart';
import '../models/payment_model.dart';

class PaymentService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<PaymentModel>> fetchPayments() async {
    try {
    return await _dbHelper.fetchPayments(); 
  } catch (e) {
    print('Error fetching properties: $e');
    throw e;
  }
  }
  Future<void> addPayment(PaymentModel payment) async {
    await _dbHelper.addPayment(payment);
  }

  Future<int> updatePayment(PaymentModel payment) async {
    final db = await _dbHelper.database;
    return await db.update(
      'payments',
      payment.toJson(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  Future<int> deletePayment(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<PaymentModel>> fetchPaymentsForTenant(int tenantId) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'tenantId = ?',
      whereArgs: [tenantId],
    );
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

}


