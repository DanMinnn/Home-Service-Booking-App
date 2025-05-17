import 'package:home_service/modules/wallet/model/wallet.dart';

abstract class WalletState {
  const WalletState();
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletLoaded extends WalletState {
  final Wallet wallet;

  const WalletLoaded({required this.wallet});
}

class WalletError extends WalletState {
  final String message;

  const WalletError({required this.message});
}

class WalletRechargeSuccess extends WalletState {
  final String message;

  const WalletRechargeSuccess({required this.message});
}
