import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypal_integration/paypal_intregation.dart';

import '../model/items.dart';

/// Notifier for managing the shopping cart state.
///
/// This notifier extends `StateNotifier` to manage a list of `CartItem` objects.
/// It provides methods to add items, remove items, clear the cart, and calculate the total price.
class CartNotifier extends StateNotifier<List<CartItem>> {
  /// Initializes the cart with an empty list of items.
  CartNotifier() : super([]);

  /// Calculates the total price of all items in the cart.
  double get total => state.fold(0, (sum, item) => sum + item.total);

  /// Adds an item to the cart.
  ///
  /// If the item already exists in the cart, its quantity is incremented.
  /// Otherwise, the new item is added to the cart.
  void addItem(CartItem item) {
    state = [...state, item];
  }

  /// Removes an item from the cart.
  void removeItem(CartItem item) {
    state = state.where((i) => i != item).toList();
  }

  /// Clears all items from the cart.
  void clear() {
    state = [];
  }
}

/// Provider for the `CartNotifier`.
///
/// This provider creates an instance of `CartNotifier` and makes it available
/// to the rest of the application for managing the shopping cart.
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

/// Checkout States
///
/// Represents the different states of the checkout process.
sealed class CheckoutState {
  const CheckoutState();
}

/// Initial state of the checkout process.
class CheckoutInitial extends CheckoutState {}

/// State indicating that the checkout process is loading.
class CheckoutLoading extends CheckoutState {}

/// State indicating that the checkout process is ready to proceed with payment.
///
/// Contains the `approvalUrl` and `executeUrl` required for PayPal payment.
class CheckoutReady extends CheckoutState {
  /// The URL to redirect the user to for approving the payment.
  final String approvalUrl;

  /// The URL to execute the payment after user approval.
  final String executeUrl;
  const CheckoutReady({required this.approvalUrl, required this.executeUrl});
}

class CheckoutSuccess extends CheckoutState {
  final Map<String, dynamic> data;
  const CheckoutSuccess(this.data);
}

/// State indicating that an error occurred during the checkout process.
///
/// Contains an error `message`.
class CheckoutError extends CheckoutState {
  final String message;
  const CheckoutError(this.message);
}

/// Checkout Notifier
///
/// Manages the state of the checkout process, interacting with the PayPal service.
class CheckoutNotifier extends StateNotifier<CheckoutState> {
  /// Creates a `CheckoutNotifier`.
  ///
  /// Requires a `Ref` to access other providers and a `PaypalService` instance.
  CheckoutNotifier(this.ref, this.paypal) : super(CheckoutInitial());

  /// Reference to the provider container.
  final Ref ref;

  /// Instance of the PayPal service.
  final PaypalService paypal;

  Future<void> checkout() async {
    final items = ref.read(cartProvider);

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
      state = CheckoutReady(
        approvalUrl: 'approvalUrl',
        executeUrl: 'executeUrl',
      );
    } catch (e) {
      state = CheckoutError(e.toString());
    }
  }

  /// Executes the PayPal payment.
  ///
  /// Takes the `accessToken`, `executeUrl`, and `payerId` as parameters.
  /// Updates the state to `CheckoutLoading` while processing, then to
  /// `CheckoutSuccess` with the payment data or `CheckoutError` if an
  /// error occurs. Clears the cart upon successful payment.
  Future<void> execute(
    String accessToken,
    String executeUrl,
    String payerId,
  ) async {
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

  /// Creates a list of transaction maps in the format required by PayPal.
  ///
  /// Reads the current cart items and total amount to structure the
  /// transaction data.
  List<Map<String, dynamic>> transactionMap() {
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
            "shipping_discount": 0,
          },
        },
        "description": "Payment for items",
        "item_list": {"items": items.map((e) => e.toPaypalItem()).toList()},
      },
    ];
  }
}

/// Provider for the `CheckoutNotifier`.
///
/// This provider creates an instance of `CheckoutNotifier`, initializing it with
/// a `PaypalService` configured with client ID, secret key, and sandbox mode.
final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((
  ref,
) {
  final paypal = PaypalService(
    clientId:
        "AfDlfuKlj48GElNvFRld1LZIPGAhIbyCm0MLHuhlznh0nl_eX5YiEmJHAJPVzemw0waxHIRH4sdg1It1",
    secretKey:
        "EHkjluknVRt7RemM3BMP6q5WCB2xkOJ_LI4K7BBLCiGMyFOGDpR5zCVdTMXdJ9h5k2l2-zudQ8UjJnWp",
    sandboxMode: true,
  );
  return CheckoutNotifier(ref, paypal);
});
