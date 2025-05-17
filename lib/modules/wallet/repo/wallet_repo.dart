import 'package:home_service/modules/wallet/model/wallet.dart';
import 'package:home_service/providers/log_provider.dart';

import '../../../providers/api_provider.dart';

class WalletRepo {
  final LogProvider logger = const LogProvider(":::WALLET-REPO:::");
  final _apiProvider = ApiProvider();

  Future<Wallet> getWallet(int userId) async {
    try {
      final response = await _apiProvider.get(
        '/wallet/user/$userId',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        final wallet = Wallet.fromJson(data);
        return wallet;
      } else {
        logger.log("Failed to load wallet data: ${response.statusCode}");
        throw Exception("Failed to load wallet data");
      }
    } catch (e) {
      logger.log("Error fetching wallet data: $e");
      throw e;
    }
  }

  Future<String> rechargeWallet(int userId, double amount) async {
    try {
      final response = await _apiProvider.post(
        '/wallet/recharge/',
        data: {
          'userId': userId,
          'amount': amount,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return "Recharge successful";
      } else {
        logger.log("Failed to recharge wallet: ${response.statusCode}");
        throw Exception("Failed to recharge wallet");
      }
    } catch (e) {
      logger.log("Error recharging wallet: $e");
      rethrow;
    }
  }
}
