
import 'package:property_management/models/property_model.dart';
import '../helpers/database_helper.dart';

class PropertyService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<PropertyModel>> fetchProperties() async {
    // return await _dbHelper.fetchProperties();
    try {
    // Simulate fetching from a database
    return await _dbHelper.fetchProperties(); // Replace with your actual fetch code
  } catch (e) {
    print('Error fetching properties: $e');
    throw e;
  }
  }

  Future<void> addProperty(PropertyModel property) async {
    await _dbHelper.addProperty(property);
  }

  Future<void> updateProperty(PropertyModel property) async {
    await _dbHelper.updateProperty(property);
  }

  Future<void> deleteProperty(int id) async {
    await _dbHelper.deleteProperty(id);
  }
}