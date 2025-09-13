import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypal_integration/paypal_integration.dart';

/// This file contains the implementation of the transaction history feature using Riverpod.
/// It defines a [TransactionHistoryNotifier] class that manages the state of the transaction history,
/// and a [transactionHistoryProvider] that provides an instance of the notifier to the UI.
import '../models/transaction_history_model.dart';
import '../state/transaction_state.dart';

class TransactionHistoryNotifier
    extends StateNotifier<TransactionHistoryState> {
  TransactionHistoryNotifier(this.paypalService)
    : super(TransactionHistoryState());

  final PaypalService paypalService;

  /// Fetches the transaction history from the PayPal API and updates the state.
  /// It handles loading and error states, and parses the API response into a [TransactionHistoryResponse] object.
  Future<void> fetchTransactions() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tokenRes = await paypalService.getAccessToken();
      final accessToken = tokenRes['token'];

      String formatForPaypal(DateTime dt) {
        return '${dt.toUtc().toIso8601String().split('.').first}Z';
      }

      final startDate = formatForPaypal(
        DateTime.now().subtract(const Duration(days: 30)),
      );
      final endDate = formatForPaypal(DateTime.now());

      final result = await paypalService.listTransactions(
        accessToken: accessToken,
        startDate: startDate,
        endDate: endDate,
        fields: 'all',
        pageSize: 40,
        page: 1,
      );

      final response = TransactionHistoryResponse.fromJson(result);

      state = state.copyWith(isLoading: false, data: response);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

/// A Riverpod provider that creates and provides an instance of [TransactionHistoryNotifier].
/// It initializes the [PaypalService] with the necessary credentials and sandbox mode setting.
final transactionHistoryProvider =
    StateNotifierProvider<TransactionHistoryNotifier, TransactionHistoryState>(
      (ref) => TransactionHistoryNotifier(
        PaypalService(
          clientId:
              "AfDlfuKlj48GElNvFRld1LZIPGAhIbyCm0MLHuhlznh0nl_eX5YiEmJHAJPVzemw0waxHIRH4sdg1It1",
          secretKey:
              "EHkjluknVRt7RemM3BMP6q5WCB2xkOJ_LI4K7BBLCiGMyFOGDpR5zCVdTMXdJ9h5k2l2-zudQ8UjJnWp",
          sandboxMode: true,
        ),
      ),
    );
