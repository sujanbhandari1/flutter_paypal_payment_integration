import 'package:flutter/material.dart';
import 'package:paypal_integration/paypal_intregation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PayPal Integration Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PayPal Integration Example")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PaypalCheckoutView(
                  sandboxMode: true, // true for testing
                  clientId: "AfDlfuKlj48GElNvFRld1LZIPGAhIbyCm0MLHuhlznh0nl_eX5YiEmJHAJPVzemw0waxHIRH4sdg1It1",
                  secretKey: "EHkjluknVRt7RemM3BMP6q5WCB2xkOJ_LI4K7BBLCiGMyFOGDpR5zCVdTMXdJ9h5k2l2-zudQ8UjJnWp",
                  transactions: const [
                    {
                      "amount": {
                        "total": '100',
                        "currency": "USD",
                        "details": {
                          "subtotal": '100',
                          "shipping": '0',
                          "shipping_discount": 0
                        }
                      },
                      "description": "Payment for products",
                      "item_list": {
                        "items": [
                          {"name": "Apple", "quantity": 4, "price": '10', "currency": "USD"},
                          {"name": "Pineapple", "quantity": 5, "price": '12', "currency": "USD"}
                        ]
                      }
                    }
                  ],
                  onSuccess: (data) {
                    debugPrint("✅ Payment successful: $data");
                    Navigator.pop(context);
                    _showDialog(context, "Payment Successful", data.toString());
                  },
                  onError: (error) {
                    debugPrint("❌ Payment error: $error");
                    Navigator.pop(context);
                    _showDialog(context, "Payment Failed", error.toString(),);
                  },
                  onCancel: () {
                    debugPrint("🚫 Payment cancelled");
                    Navigator.pop(context);
                    _showDialog(context, "Payment Cancelled", "User cancelled the payment");
                  }, returnUrl: '', cancelUrl: '',
                ),
              ),
            );
          },
          child: const Text("Pay with PayPal"),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
}
