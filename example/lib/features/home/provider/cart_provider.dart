import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypal_integration/paypal_intregation.dart';

import '../model/items.dart';

/// Cart State
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  double get total =>
      state.fold(0, (sum, item) => sum + item.total);

  void addItem(CartItem item) {
    state = [...state, item];
  }

  void removeItem(CartItem item) {
    state = state.where((i) => i != item).toList();
  }

  void clear() {
    state = [];
  }
}

final cartProvider =
StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

/// Checkout States
sealed class CheckoutState {
  const CheckoutState();
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutReady extends CheckoutState {
  final String approvalUrl;
  final String executeUrl;
  const CheckoutReady({required this.approvalUrl, required this.executeUrl});
}

class CheckoutSuccess extends CheckoutState {
  final Map<String, dynamic> data;
  const CheckoutSuccess(this.data);
}

class CheckoutError extends CheckoutState {
  final String message;
  const CheckoutError(this.message);
}

/// Checkout Notifier
class CheckoutNotifier extends StateNotifier<CheckoutState> {
  CheckoutNotifier(this.ref, this.paypal) : super(CheckoutInitial());

  final Ref ref;
  final PaypalService paypal;

  Future<void> checkout() async {
    final items = ref.read(cartProvider);
    final total = ref.read(cartProvider.notifier).total;

    if (items.isEmpty) {
      state = CheckoutError("Cart is empty");
      return;
    }

    try {
      state = CheckoutLoading();

      final tokenRes = await paypal.getAccessToken();
      if (tokenRes['error'] == true) {
        state = CheckoutError(tokenRes['message']);
        return;
      }
      // final accessToken = tokenRes['token'];
      //
      // final transactions = [
      //   {
      //     "amount": {
      //       "total": total.toStringAsFixed(2),
      //       "currency": "USD",
      //       "details": {
      //         "subtotal": total.toStringAsFixed(2),
      //         "shipping": '0',
      //         "shipping_discount": 0
      //       }
      //     },
      //     "description": "Payment for items",
      //     "item_list": {
      //       "items": items.map((e) => e.toPaypalItem()).toList(),
      //     }
      //   }
      // ];
      //
      // final payment = await paypal.createPayment(
      //   accessToken: accessToken,
      //   intent: 'sale',
      //   transactions: transactions,
      //   returnUrl: "yourapp://success",
      //   cancelUrl: "yourapp://cancel",
      // );
      //
      // final approvalUrl = payment['approvalUrl'];
      // final executeUrl = payment['executeUrl'];
      //
      // if (approvalUrl == null || executeUrl == null) {
      //   state = CheckoutError("Missing approval or execute URL");
      //   return;
      // }
      //
      state = CheckoutReady(
        approvalUrl: 'approvalUrl',
        executeUrl: 'executeUrl',
      );
    } catch (e) {
      state = CheckoutError(e.toString());
    }
  }

  Future<void> execute(String accessToken, String executeUrl, String payerId) async {
    try {
      state = CheckoutLoading();
      final executed = await paypal.executePayment(
        accessToken: accessToken,
        executeUrl: executeUrl,
        payerId: payerId,
      );
      state = CheckoutSuccess(executed);
      ref.read(cartProvider.notifier).clear();
    } catch (e) {
      state = CheckoutError(e.toString());
    }
  }

  List<Map<String, dynamic>> transactionMap (){
    final items = ref.read(cartProvider);
    final total = ref.read(cartProvider.notifier).total;
    return [
      {
        "amount": {
          "total": total.toStringAsFixed(2),
          "currency": "USD",
          "details": {
            "subtotal": total.toStringAsFixed(2),
            "shipping": '0',
            "shipping_discount": 0
          }
        },
        "description": "Payment for items",
        "item_list": {
          "items": items.map((e) => e.toPaypalItem()).toList(),
        }
      }
    ];
  }
}



final checkoutProvider =
StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  final paypal = PaypalService(
    clientId: "AfDlfuKlj48GElNvFRld1LZIPGAhIbyCm0MLHuhlznh0nl_eX5YiEmJHAJPVzemw0waxHIRH4sdg1It1",
    secretKey: "EHkjluknVRt7RemM3BMP6q5WCB2xkOJ_LI4K7BBLCiGMyFOGDpR5zCVdTMXdJ9h5k2l2-zudQ8UjJnWp",
    sandboxMode: true,
  );
  return CheckoutNotifier(ref, paypal);
});

