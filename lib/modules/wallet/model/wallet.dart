import 'package:home_service/modules/wallet/model/transaction.dart';

class Wallet {
  final int id;
  final int userId;
  final double balance;
  final List<Transaction> transactions;

  Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    this.transactions = const [],
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['walletId'] as int,
      userId: json['userId'] as int,
      balance: (json['balance'] as num).toDouble(),
      transactions: (json['transactions'] as List<dynamic>)
          .map((transaction) =>
              Transaction.fromJson(transaction as Map<String, dynamic>))
          .toList(),
    );
  }
}
