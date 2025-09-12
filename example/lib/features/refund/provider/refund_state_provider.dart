import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypal_integration/paypal_intregation.dart';

import '../states/refund_state.dart';

final refundProvider =
StateNotifierProvider<RefundNotifier, RefundState>((ref) {
  final paypal = PaypalService(
    clientId: "AfDlfuKlj48GElNvFRld1LZIPGAhIbyCm0MLHuhlznh0nl_eX5YiEmJHAJPVzemw0waxHIRH4sdg1It1",
    secretKey: "EHkjluknVRt7RemM3BMP6q5WCB2xkOJ_LI4K7BBLCiGMyFOGDpR5zCVdTMXdJ9h5k2l2-zudQ8UjJnWp",
    sandboxMode: true,
  );
  return RefundNotifier(paypal);
});

class RefundNotifier extends StateNotifier<RefundState> {
  final PaypalService _paypal;

  RefundNotifier(this._paypal) : super(const RefundState());

  Future<void> refundTransaction({
    required String accessToken,
    required String captureId,
    String? value,
    String? currencyCode,
    String? noteToPayer,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final accessToken = await _paypal.getAccessToken();
      final token = accessToken['token'];

      final result = await _paypal.refundCapture(
        accessToken: '$token',
        captureId: captureId,
        value: value,
        currencyCode: currencyCode,
        noteToPayer: noteToPayer,
      );

      state = state.copyWith(isLoading: false, data: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
