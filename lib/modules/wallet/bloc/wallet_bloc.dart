import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/modules/wallet/bloc/wallet_event.dart';
import 'package:home_service/modules/wallet/bloc/wallet_state.dart';
import 'package:home_service/modules/wallet/repo/wallet_repo.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepo _walletRepo;

  WalletBloc(this._walletRepo) : super(const WalletInitial()) {
    on<WalletFetch>(_onFetchWallet);
    on<WalletRecharge>(_onRechargeWallet);
  }

  Future<void> _onFetchWallet(
      WalletFetch event, Emitter<WalletState> emit) async {
    emit(const WalletLoading());
    try {
      final wallet = await _walletRepo.getWallet(event.userId);
      emit(WalletLoaded(wallet: wallet));
    } catch (e) {
      emit(WalletError(message: e.toString()));
    }
  }

  Future<void> _onRechargeWallet(
      WalletRecharge event, Emitter<WalletState> emit) async {
    emit(const WalletLoading());
    try {
      final message =
          await _walletRepo.rechargeWallet(event.userId, event.amount);
      emit(WalletRechargeSuccess(message: message));
    } catch (e) {
      emit(WalletError(message: e.toString()));
    }
  }
}
