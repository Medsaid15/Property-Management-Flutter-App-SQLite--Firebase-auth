
class PropertyModel {
  final int? id;
  final String name;
  final String address;
  final String type;
  final int units;
  final double rentalCost;
  int? tenantId; // ID of the linked tenant

  PropertyModel({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.units,
    required this.rentalCost,
    this.tenantId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'type': type,
      'units': units,
      'rentalCost': rentalCost,
      'tenantId': tenantId,
    };
  }

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      type: json['type'],
      units: json['units'],
      rentalCost: json['rentalCost'],
      tenantId: json['tenantId'],
    );
  }
}