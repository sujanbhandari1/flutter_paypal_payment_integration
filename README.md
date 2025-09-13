# PayPal Integration Flutter

Seamless **PayPal payment integration** for Flutter apps, supporting sandbox/live mode, customizable checkout UI, one-time payments, transaction history, and refunds. Ideal for Flutter developers who want to integrate PayPal payments with minimal setup.

---

## Features

- One-time Payments
- Sandbox & Live Mode Switching
- Customizable Checkout UI
- Transaction History
- Refunds
- Fully testable and extendable

---

## Installation

### From GitHub (Not published on pub.dev yet)

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  paypal_integration_flutter:
    git:
      url: https://github.com/sujanbhandari1/flutter_paypal_payment_integration.git
```

Then run:

```bash
flutter pub get
```

---

## Minimal Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:paypal_integration/paypal_intregation.dart';

void main() {
  runApp(const PaypalExampleApp());
}

class PaypalExampleApp extends StatelessWidget {
  const PaypalExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "PayPal Integration Example",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PayPal Example")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PaypalCheckoutView(
                  sandboxMode: true,
                  clientId: "YOUR_SANDBOX_CLIENT_ID",
                  secretKey: "YOUR_SANDBOX_SECRET_KEY",
                  returnUrl: "https://samplesite.com/return",
                  cancelUrl: "https://samplesite.com/cancel",
                  transactions: const [
                    {
                      "amount": {
                        "total": '10.00',
                        "currency": "USD",
                        "details": {
                          "subtotal": '10.00',
                          "shipping": '0',
                          "shipping_discount": 0
                        }
                      },
                      "description": "Test Payment",
                      "item_list": {
                        "items": [
                          {
                            "name": "Sample Item",
                            "quantity": 1,
                            "price": '10.00',
                            "currency": "USD"
                          }
                        ]
                      }
                    }
                  ],
                  onSuccess: (Map data) {
                    debugPrint("✅ Payment Success: $data");
                    Navigator.pop(context);
                  },
                  onError: (error) {
                    debugPrint("❌ Payment Error: $error");
                    Navigator.pop(context);
                  },
                  onCancel: () {
                    debugPrint("🚫 Payment Cancelled");
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          },
          child: const Text("Pay with PayPal"),
        ),
      ),
    );
  }
}
```

---

## Example App

- A full `/example` app is included in the repository demonstrating:
    - Adding items to a cart
    - Checkout flow
    - Success, error, and cancellation handling
    - Transaction listing
- Screenshots can be added in the `README.md` later.

---

## Platform Setup

### Android

1. Add internet permission in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

2. Set `minSdkVersion` to 21+ in `android/app/build.gradle`.

### iOS

1. Open `ios/Runner/Info.plist` and add:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

2. Set the minimum iOS version to 11.0 in `ios/Podfile`.

---

## API Reference

| Method | Description |
|--------|-------------|
| `PaypalCheckoutView` | Main checkout widget. Accepts clientId, secretKey, transactions, returnUrl, cancelUrl, callbacks. |
| `onSuccess(Map data)` | Called on successful payment. |
| `onError(dynamic error)` | Called on payment error. |
| `onCancel()` | Called if user cancels the payment. |

---

## License

MIT License – see `LICENSE` file.

---

## Contribution Guidelines

- Pull requests are welcome.
- Fork the repository, make changes, and submit PR.
- Ensure all tests pass before submitting.

---

## Badges (Optional)

- Pub.dev version badge
- GitHub Actions CI badge
- Codecov/coverage badge