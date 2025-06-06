import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/modules/wallet/repo/wallet_repo.dart';
import 'package:home_service/routes/route_name.dart';
import 'package:home_service/services/navigation_service.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:home_service/themes/styles_text.dart';
import 'package:intl/intl.dart';

import '../../../common/widgets/stateless/basic_app_bar.dart';
import '../../../themes/app_assets.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final NavigationService navigationService = NavigationService();
  int _userId = 0;
  int _displayedTransactions = 5; // Initial number of transactions to display
  bool _hasMoreTransactions = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _userId = args['userId'] as int;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BasicAppBar(
                isLeading: false,
                isTrailing: false,
                leading: GestureDetector(
                  onTap: () {
                    navigationService.goBack();
                  },
                  child: Image.asset(AppAssetIcons.arrowLeft),
                ),
                title: 'Wallet',
              ),
              _buildBodyWallet(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyWallet() {
    return BlocProvider(
      create: (context) =>
          WalletBloc(WalletRepo())..add(WalletFetch(userId: _userId)),
      child: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WalletError) {
            return Center(
              child: Text(
                'Something went wrong',
                style: AppTextStyles.bodyMediumRegular
                    .copyWith(color: AppColors.red),
              ),
            );
          } else if (state is WalletLoaded) {
            final wallet = state.wallet;
            // Calculate if there are more transactions to show
            _hasMoreTransactions =
                wallet.transactions.length > _displayedTransactions;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account balance section
                  Text('WALLET ACCOUNT',
                      style: AppTextStyles.bodyMediumBold
                          .copyWith(color: AppColors.black)),
                  const SizedBox(height: 16),

                  // Balance row with arrow
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Balance',
                          style: AppTextStyles.bodyMediumRegular
                              .copyWith(color: AppColors.black)),
                      Row(
                        children: [
                          Text('${_formatCurrency(wallet.balance)}đ',
                              style: AppTextStyles.bodyMediumSemiBold
                                  .copyWith(color: AppColors.green)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Deposit button
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final result = await navigationService
                              .navigateTo(RouteName.depositWallet, arguments: {
                            'userId': _userId,
                            'balance': wallet.balance,
                          });

                          if (result == true) {
                            setState(() {
                              BlocProvider.of<WalletBloc>(context)
                                  .add(WalletFetch(userId: _userId));
                            });
                          }
                        },
                        child: Text('Deposit',
                            style: AppTextStyles.bodyMediumRegular
                                .copyWith(color: AppColors.green)),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward,
                          size: 16, color: AppColors.green),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent transactions header
                  Text('RECENT TRANSACTIONS',
                      style: AppTextStyles.bodyMediumBold
                          .copyWith(color: AppColors.black)),
                  const SizedBox(height: 16),

                  // Transactions list
                  wallet.transactions.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Text(
                              'No transactions available',
                              style: AppTextStyles.bodyMediumRegular
                                  .copyWith(color: AppColors.subTitle),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemBuilder: (_, index) {
                            return _buildTransactionItem(
                              title: wallet.transactions[index].description,
                              date:
                                  _formatDate(wallet.transactions[index].date),
                              amount: wallet.transactions[index].amount,
                              isPositive: wallet.transactions[index].type
                                      .toLowerCase() ==
                                  'deposit',
                            );
                          },
                          itemCount: _hasMoreTransactions
                              ? _displayedTransactions
                              : wallet.transactions.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                        ),

                  // See more button - only show if there are more transactions
                  if (_hasMoreTransactions)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          // Increase the number of displayed transactions
                          _displayedTransactions += 5;
                        });
                      },
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Read more',
                            style: AppTextStyles.bodyMediumRegular
                                .copyWith(color: AppColors.green),
                          ),
                        ),
                      ),
                    ),

                  // Show a message when all transactions have been loaded
                  if (!_hasMoreTransactions && wallet.transactions.isNotEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'No more transactions to show',
                          style: AppTextStyles.bodySmallRegular
                              .copyWith(color: AppColors.subTitle),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required String date,
    required double amount,
    required bool isPositive,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMediumRegular.copyWith(
                      color: AppColors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: AppTextStyles.bodySmallRegular.copyWith(
                      color: AppColors.subTitle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${isPositive ? '+' : '-'}${_formatCurrency(amount)}đ',
              style: AppTextStyles.bodyMediumSemiBold.copyWith(
                color: isPositive ? AppColors.green : AppColors.darkBlue,
              ),
            ),
          ],
        ),
        const Divider(height: 24, thickness: 0.5, color: AppColors.darkBlue20),
      ],
    );
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat('#,###');
    return formatter.format(value);
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(date);
  }
}
