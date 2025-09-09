// import 'package:flutter/material.dart';
// import 'package:paypal_integration/paypal_intregation.dart';
//


import 'package:example/features/home/provider/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypal_integration/paypal_intregation.dart';

import 'model/items.dart';
class HomePages extends StatelessWidget {
  HomePages({super.key});

  PaypalService paypalService = PaypalService(clientId: "AfDlfuKlj48GElNvFRld1LZIPGAhIbyCm0MLHuhlznh0nl_eX5YiEmJHAJPVzemw0waxHIRH4sdg1It1",
      secretKey: "EHkjluknVRt7RemM3BMP6q5WCB2xkOJ_LI4K7BBLCiGMyFOGDpR5zCVdTMXdJ9h5k2l2-zudQ8UjJnWp",
      sandboxMode: true);

  TextEditingController refundSalesCode = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PayPal Integration Example")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async{
              final token = await paypalService.getAccessToken();
              String formatForPaypal(DateTime dt) {
                return '${dt.toUtc().toIso8601String().split('.').first}Z';
              }

              final startDate = formatForPaypal(DateTime.now().subtract(Duration(days: 30)));
              final endDate = formatForPaypal(DateTime.now());

              Map<String, dynamic> transactions = await paypalService.listTransactions(
                accessToken: token['token'],
                startDate: startDate,
                endDate: endDate,
                fields: 'all', // ensures you get full transaction details
                // pageSize: 50,  // adjust as needed
                // page: 1,
              );
              debugPrint(transactions.toString());

            },
            child: const Text("Transaction details"),
          ),
          Center(
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
                            "total": '200',
                            "currency": "AUD",
                            "details": {
                              "subtotal": '200',
                              "shipping": '0',
                              "shipping_discount": 0
                            }
                          },
                          "description": "Payment for freelance graphic design project",
                          "item_list": {
                            "items": [
                              {
                                "name": "Logo Design Service",
                                "quantity": 1,
                                "price": '150',
                                "currency": "AUD"
                              },
                              {
                                "name": "Business Card Design Service",
                                "quantity": 1,
                                "price": '50',
                                "currency": "AUD"
                              }
                            ]
                          }
                        }
                      ],
                      onSuccess: (data) {
                        debugPrint("✅ Payment successful: $data");
                        debugPrint(data.toString(), wrapWidth: 99999);

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
                      }, returnUrl: "https://www.youtube.com/channel/UC9a1yj1xV2zeyiFPZ1gGYGw", cancelUrl: "https://www.youtube.com/channel/UC9a1yj1xV2zeyiFPZ1gGYGw",
                    ),
                  ),
                );
              },
              child: const Text("Pay with PayPal"),
            ),
          ),

          TextField(
            controller: refundSalesCode,
          ),
          ElevatedButton(
            onPressed: () async{
              try{
                final token = await paypalService.getAccessToken();

                Map<String, dynamic> transactions = await paypalService.refundCapture(
                  captureId: refundSalesCode.text, accessToken: token['token'],// ensures you get full transaction details
                  // pageSize: 50,  // adjust as needed
                  // page: 1,
                );

                _showDialog(context, 'refund success', transactions.toString());
              }catch(e){
                debugPrint(e.toString());
                _showDialog(context, "Refund Failed", e.toString());


              }


            },
            child: const Text("Refund Transaction"),
          ),


        ],
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



class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final checkoutState = ref.watch(checkoutProvider);

    final items = [
      CartItem(name: "Apple", description: "Fresh apples", quantity: 1, price: 2.0),
      CartItem(name: "Pineapple", description: "Juicy pineapple", quantity: 1, price: 3.5),
      CartItem(name: "Mango", description: "Sweet mango", quantity: 1, price: 4.0),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Fruit Shop")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final item = items[i];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text("\$${item.price.toStringAsFixed(2)}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () {
                      ref.read(cartProvider.notifier).addItem(item);
                    },
                  ),
                );
              },
            ),
          ),
          if (cart.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text("Cart total: \$${ref.read(cartProvider.notifier).total.toStringAsFixed(2)}"),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await ref.read(checkoutProvider.notifier).checkout();
                      final state = ref.read(checkoutProvider);
                      if (state is CheckoutReady) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PaypalCheckoutView(
                              sandboxMode: true, // true for testing
                              clientId: "AfDlfuKlj48GElNvFRld1LZIPGAhIbyCm0MLHuhlznh0nl_eX5YiEmJHAJPVzemw0waxHIRH4sdg1It1",
                              secretKey: "EHkjluknVRt7RemM3BMP6q5WCB2xkOJ_LI4K7BBLCiGMyFOGDpR5zCVdTMXdJ9h5k2l2-zudQ8UjJnWp",
                              transactions: const [
                                {
                                  "amount": {
                                    "total": '200',
                                    "currency": "AUD",
                                    "details": {
                                      "subtotal": '200',
                                      "shipping": '0',
                                      "shipping_discount": 0
                                    }
                                  },
                                  "description": "Payment for freelance graphic design project",
                                  "item_list": {
                                    "items": [
                                      {
                                        "name": "Logo Design Service",
                                        "quantity": 1,
                                        "price": '150',
                                        "currency": "AUD"
                                      },
                                      {
                                        "name": "Business Card Design Service",
                                        "quantity": 1,
                                        "price": '50',
                                        "currency": "AUD"
                                      }
                                    ]
                                  }
                                }
                              ],
                              onSuccess: (data) {
                                debugPrint("✅ Payment successful: $data");
                                debugPrint(data.toString(), wrapWidth: 99999);

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
                              }, returnUrl: "https://www.youtube.com/channel/UC9a1yj1xV2zeyiFPZ1gGYGw", cancelUrl: "https://www.youtube.com/channel/UC9a1yj1xV2zeyiFPZ1gGYGw",
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text("Checkout"),
                  ),
                ],
              ),
            ),
          // --- Checkout State ---
          if (checkoutState is CheckoutLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          if (checkoutState is CheckoutError)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text("❌ Error: ${(checkoutState as CheckoutError).message}"),
            ),
          if (checkoutState is CheckoutSuccess)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text("✅ Payment successful!"),
            ),
        ],
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
