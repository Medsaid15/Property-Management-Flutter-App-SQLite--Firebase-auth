class TenantModel {
  final int id;
  final String name;
  final String contact;
  final String section;
  TenantModel({
    required this.id,
    required this.name,
    required this.contact,
    required this.section,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'section': section,
    };
  }
  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'],
      name: json['name'],
      contact: json['contact'],
      section: json['section'], 
    );
  }
}