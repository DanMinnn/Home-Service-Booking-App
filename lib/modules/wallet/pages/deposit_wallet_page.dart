import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/common/widgets/stateless/show_snack_bar.dart';
import 'package:home_service/modules/authentication/widgets/custom_text_field.dart';
import 'package:home_service/modules/wallet/repo/wallet_repo.dart';
import 'package:home_service/providers/log_provider.dart';
import 'package:home_service/services/navigation_service.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:intl/intl.dart';

import '../../../common/widgets/stateless/basic_app_bar.dart';
import '../../../themes/app_assets.dart';
import '../../../themes/styles_text.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';

class DepositWalletPage extends StatefulWidget {
  const DepositWalletPage({super.key});

  @override
  State<DepositWalletPage> createState() => _DepositWalletPageState();
}

class _DepositWalletPageState extends State<DepositWalletPage> {
  final NavigationService navigationService = NavigationService();
  final LogProvider logger = const LogProvider(":::DEPOSIT-WALLET-PAGE:::");
  final TextEditingController _amount = TextEditingController();
  int _userId = 0;
  double _currentBalance = 0.0;
  int? selectAmount;
  String money = '';
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _amount.addListener(_updateAfterDeposit);
  }

  @override
  void dispose() {
    super.dispose();
    _amount.removeListener(_updateAfterDeposit);
    _amount.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _userId = args['userId'] as int;
      _currentBalance = args['balance'] as double;
    }
  }

  // Method to update values when text field changes
  void _updateAfterDeposit() {
    if (_amount.text.isNotEmpty) {
      // Clear selected amount when user types in custom amount
      setState(() {
        selectAmount = null;
        _validateAmount(_amount.text);
      });
    }
  }

  // Validate the amount entered
  void _validateAmount(String value) {
    if (value.isEmpty) {
      _errorText = null;
      return;
    }

    try {
      final amount = int.parse(value.replaceAll(',', ''));
      if (amount < 10000) {
        _errorText = 'Minimum deposit is 10,000đ';
      } else if (amount > 10000000) {
        _errorText = 'Maximum deposit is 10,000,000đ';
      } else {
        _errorText = null;
      }
    } catch (e) {
      _errorText = 'Please enter a valid amount';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BasicAppBar(
              isLeading: false,
              isTrailing: false,
              leading: GestureDetector(
                onTap: () {
                  navigationService.goBack(true);
                },
                child: Image.asset(AppAssetIcons.arrowLeft),
              ),
              title: 'Deposit',
            ),
            _buildBodyDeposit(),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyDeposit() {
    List<String> errorMessages = [];

    if (_errorText != null) {
      errorMessages.add(_errorText!);
    }
    return BlocProvider(
      create: (context) => WalletBloc(WalletRepo()),
      child: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SELECT AMOUNT TO DEPOSIT',
                  style: AppTextStyles.bodyMediumMedium.copyWith(
                    color: AppColors.darkBlue,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildDepositItem('200,000đ', 0),
                      const SizedBox(width: 8),
                      _buildDepositItem('300,000đ', 1),
                      const SizedBox(width: 8),
                      _buildDepositItem('500,000đ', 2),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _amount,
                  hintText: 'Enter amount',
                  prefixIcon: null,
                  onChanged: (value) {
                    setState(() {
                      _validateAmount(value);
                    });
                  },
                  label: 'OR ENTER AMOUNT',
                  keyboardType: TextInputType.number,
                  onUnfocused: () {},
                  errorMessages: errorMessages,
                ),
                const SizedBox(height: 20),
                _buildTextBeforeAfterDeposit(),
                const SizedBox(height: 100),
                _buildDepositButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDepositItem(String amount, int index) {
    bool isSelected = selectAmount == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectAmount = isSelected ? null : index;
          money = isSelected ? '' : amount;
          // Clear the text field when selecting a preset amount
          _amount.clear();
          _errorText = null;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkBlue : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.darkBlue,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Center(
            child: Text(
              amount,
              style: AppTextStyles.bodyMediumRegular.copyWith(
                color: isSelected ? AppColors.white : AppColors.darkBlue,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextBeforeAfterDeposit() {
    // Calculate the deposit amount
    int depositAmount = 0;
    if (_amount.text.isNotEmpty) {
      try {
        depositAmount = int.parse(_amount.text.replaceAll(',', ''));
      } catch (e) {
        depositAmount = 0;
      }
    } else if (money.isNotEmpty) {
      depositAmount = _convertToDouble(money);
    }

    // Calculate the new balance
    double newBalance = _currentBalance + depositAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildItem(
          'Current Balance',
          '${_formatCurrency(_currentBalance)}đ',
        ),
        const SizedBox(height: 8),
        _buildItem(
          'After Deposit',
          '${_formatCurrency(newBalance)}đ',
        ),
      ],
    );
  }

  Widget _buildItem(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyMediumMedium.copyWith(
            color: AppColors.darkBlue,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMediumMedium.copyWith(
            color: AppColors.darkBlue,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildDepositButton(BuildContext context) {
    bool isButtonEnabled = (_amount.text.isNotEmpty && _errorText == null) ||
        (selectAmount != null && money.isNotEmpty);

    return GestureDetector(
      onTap: isButtonEnabled
          ? () {
              // Handle deposit action
              double depositAmount = _amount.text.isNotEmpty
                  ? _convertToDouble(_amount.text).toDouble()
                  : _convertToDouble(money).toDouble();

              logger.log("Deposit amount: $depositAmount");

              // Add your API call or state update here
              setState(() {
                _currentBalance += depositAmount;
              });

              context.read<WalletBloc>().add(
                    WalletRecharge(
                      userId: _userId,
                      amount: depositAmount,
                    ),
                  );

              // Show success message
              ShowSnackBar.showSuccess(
                  context, 'Successfully deposited', 'Well done!');
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: isButtonEnabled
              ? AppColors.green
              : AppColors.darkBlue.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              'DEPOSIT',
              style: AppTextStyles.bodyMediumSemiBold.copyWith(
                color: AppColors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _convertToDouble(String amount) {
    if (amount.isEmpty) return 0;

    try {
      // Remove the 'đ' symbol and commas
      String cleanedAmount = amount.replaceAll('đ', '').replaceAll(',', '');
      // Convert to int
      return int.parse(cleanedAmount);
    } catch (e) {
      logger.log("Error converting amount to int: $amount");
      return 0;
    }
  }

  String _formatCurrency(double amount) {
    try {
      final formatter = NumberFormat('#,###');
      return formatter.format(amount);
    } on FormatException {
      logger.log("Error formatting amount: $amount");
      return amount.toString(); // Return the original amount as a string
    }
  }
}
