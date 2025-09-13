# PayPal Integration Example (Flutter)
## Welcome to the PayPal Integration Example! This is not a package setup instruction
This example demonstrates a full PayPal integration flow in Flutter using the paypal_integration package, Riverpod for state management, and GoRouter for navigation. It includes a cart system, checkout flow, refund handling, and both prebuilt PayPal buttons and customizable webview checkout.

---

## Features

* Add items to a cart
* View cart total
* Checkout using PayPal (sandbox mode)
* In-app WebView checkout 
* Prebuilt PayPal payment button
* Default success/failure/cancel UI with callbacks
* Refund functionality via a dialog after successful payment
* Transaction page navigation
* Enable/disable PayPal button dynamically based on cart state

---

## Setup

### 1. Dependencies

Add the required dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.3.6
  go_router: ^7.5.0
  paypal_integration:
    path: ../paypal_integration
  flutter_inappwebview: ^6.0.0
```

### 2. Import in your Dart files

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypal_integration/paypal_integration.dart';
import 'package:go_router/go_router.dart';
```

---

## How to Use

### 1. Cart System

The example provides a simple cart using Riverpod:

```dart
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);
```

You can add items to the cart:

```dart
ref.read(cartProvider.notifier).addItem(item);
```

### 2. Checkout Button (WebView)

The `PaypalCheckoutView` allows you to integrate PayPal payments inside your app:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PaypalCheckoutView(
      clientId: "YOUR_PAYPAL_CLIENT_ID",
      secretKey: "YOUR_PAYPAL_SECRET",
      sandboxMode: true,
      transactions: [
        {
          "amount": {
            "total": total.toStringAsFixed(2),
            "currency": "AUD",
            "details": {
              "subtotal": total.toStringAsFixed(2),
              "shipping": "0",
              "shipping_discount": 0
            }
          },
          "description": "Payment for items",
          "item_list": {
            "items": cartItems.map((e) => e.toPaypalItem()).toList(),
          }
        }
      ],
      returnUrl: "YOUR_RETURN_URL",
      cancelUrl: "YOUR_CANCEL_URL",
      onSuccess: (data) => print("Payment Success: $data"),
      onError: (error) => print("Payment Error: $error"),
      onCancel: () => print("Payment Cancelled"),
    ),
  ),
);
```

### 3. Prebuilt PayPal Button

Use `PaypalPaymentButton` for an easier setup:

```dart
PaypalPaymentButton(
  enabled: cart.isNotEmpty,
  clientId: "YOUR_PAYPAL_CLIENT_ID",
  secretKey: "YOUR_PAYPAL_SECRET",
  transactions: [
    {
      "amount": {
        "total": total.toStringAsFixed(2),
        "currency": "AUD",
      },
      "description": "Payment for items",
      "item_list": {
        "items": cartItems.map((e) => e.toPaypalItem()).toList(),
      }
    }
  ],
  returnUrl: "YOUR_RETURN_URL",
  cancelUrl: "YOUR_CANCEL_URL",
  onSuccess: (data) => print("Payment Success: $data"),
  onError: (error) => print("Payment Failed: $error"),
  onCancel: () => print("Payment Cancelled"),
)
```

> Supports **enabled/disabled state** and **tap callbacks**.

### 4. Refund Flow

After a successful payment, the dialog shows a **Refund button**:

```dart
await ref.read(refundProvider.notifier).refundTransaction(
  captureId: saleId,
  value: amount,
  currencyCode: currency,
  noteToPayer: "Refund for order",
);
```

The dialog will update with **success/error messages** accordingly.

---

## Cart Item Model

```dart
class CartItem {
  final String name;
  final String description;
  final double price;
  final int quantity;

  CartItem({
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toPaypalItem() {
    return {
      "name": name,
      "description": description,
      "quantity": quantity.toString(),
      "price": price.toStringAsFixed(2),
      "currency": "AUD",
    };
  }
}
```

---

## Notes

* Replace **sandbox credentials** with your own PayPal sandbox client ID and secret.
* Ensure `returnUrl` and `cancelUrl` are **properly configured** in your PayPal developer account.
* The example includes **Riverpod providers** for checkout and refund states. Update according to your app architecture.
* All payment flows **show default dialogs**, but you can also supply custom callbacks.

---

## License

MIT License.
