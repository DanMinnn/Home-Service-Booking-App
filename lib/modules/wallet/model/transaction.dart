class Transaction {
  final String transactionId;
  final double amount;
  final String description;
  final String type;
  final DateTime date;

  Transaction({
    required this.transactionId,
    required this.amount,
    required this.description,
    required this.type,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transactionId'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      type: json['type'] as String,
      date: DateTime.parse(json['createdAt'] as String),
    );
  }
}
