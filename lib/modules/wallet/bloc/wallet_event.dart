abstract class WalletEvent {
  const WalletEvent();
}

class WalletFetch extends WalletEvent {
  final int userId;
  const WalletFetch({required this.userId});
}

class WalletRecharge extends WalletEvent {
  final int userId;
  final double amount;
  const WalletRecharge({required this.userId, required this.amount});
}
