import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypal_integration/paypal_intregation.dart';
import '../../../models/transaction_history_model.dart';
import '../state/transaction_state.dart';

class TransactionHistoryNotifier extends StateNotifier<TransactionHistoryState> {
  TransactionHistoryNotifier(this.paypalService)
      : super(TransactionHistoryState());

  final PaypalService paypalService;

  Future<void> fetchTransactions() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tokenRes = await paypalService.getAccessToken();
      final accessToken = tokenRes['token'];

      String formatForPaypal(DateTime dt) {
        return '${dt.toUtc().toIso8601String().split('.').first}Z';
      }

      final startDate = formatForPaypal(DateTime.now().subtract(const Duration(days: 30)));
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

final transactionHistoryProvider =
StateNotifierProvider<TransactionHistoryNotifier, TransactionHistoryState>(
      (ref) => TransactionHistoryNotifier(
    PaypalService(
      clientId: "AfDlfuKlj48GElNvFRld1LZIPGAhIbyCm0MLHuhlznh0nl_eX5YiEmJHAJPVzemw0waxHIRH4sdg1It1",
      secretKey: "EHkjluknVRt7RemM3BMP6q5WCB2xkOJ_LI4K7BBLCiGMyFOGDpR5zCVdTMXdJ9h5k2l2-zudQ8UjJnWp",
      sandboxMode: true,
    ),
  ),
);
