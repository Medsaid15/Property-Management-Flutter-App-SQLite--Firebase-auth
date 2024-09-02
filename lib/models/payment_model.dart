class PaymentModel {
  final int? id;
  final double amount;
  final String date;
  final bool isSettled;
  final int tenantId; 
  final String tenantName; 

  PaymentModel({
    this.id,
    required this.amount,
    required this.date,
    required this.isSettled,
    required this.tenantId,
    required this.tenantName, 
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date,
      'isSettled': isSettled ? 1 : 0,
      'tenantId': tenantId,
      'tenantName': tenantName, // Include tenantName
    };
  }
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      amount: json['amount'],
      date: json['date'],
      isSettled: json['isSettled'] == 1,
      tenantId: json['tenantId'],
      tenantName: json['tenantName'], // Parse tenantName
    );
  }
}

