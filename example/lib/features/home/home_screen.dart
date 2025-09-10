// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'package:example/features/home/provider/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypal_integration/paypal_intregation.dart';

import '../refund/provider/refund_state_provider.dart';
import 'model/items.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final checkoutState = ref.watch(checkoutProvider);
    final total = ref.read(cartProvider.notifier).total;
    final cartItems = ref.read(cartProvider);

    final items = [
      CartItem(name: "Apple", description: "Fresh apples", quantity: 1, price: 2.0),
      CartItem(name: "Pineapple", description: "Juicy pineapple", quantity: 1, price: 3.5),
      CartItem(name: "Mango", description: "Sweet mango", quantity: 1, price: 4.0),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("PayPal Integration Example"),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🛒 Product List
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (ctx, i) {
                  final item = items[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: ListTile(
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("\$${item.price.toStringAsFixed(2)}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                        onPressed: () => ref.read(cartProvider.notifier).addItem(item),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 🛍️ Checkout Section
            if (cart.isNotEmpty) ...[
              const Divider(),
              Text(
                "Cart total: \$${total.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                icon: const Icon(Icons.payment),
                label: const Text("Checkout"),
                onPressed: () async {
                  await ref.read(checkoutProvider.notifier).checkout();
                  final state = ref.read(checkoutProvider);
                  if (state is CheckoutReady) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PaypalCheckoutView(
                          sandboxMode: true,
                          clientId: "AfDlfuKlj48GElNvFRld1LZIPGAhIbyCm0MLHuhlznh0nl_eX5YiEmJHAJPVzemw0waxHIRH4sdg1It1",
                          secretKey: "EHkjluknVRt7RemM3BMP6q5WCB2xkOJ_LI4K7BBLCiGMyFOGDpR5zCVdTMXdJ9h5k2l2-zudQ8UjJnWp",
                          transactions: [
                            {
                              "amount": {
                                "total": total.toStringAsFixed(2),
                                "currency": "AUD",
                                "details": {
                                  "subtotal": total.toStringAsFixed(2),
                                  "shipping": '0',
                                  "shipping_discount": 0,
                                },
                              },
                              "description": "Payment for items sujan",
                              "item_list": {
                                "items": cartItems.map((e) => e.toPaypalItem()).toList(),
                              },
                            },
                          ],
                          onSuccess: (data) {
                            debugPrint("✅ Payment successful: $data");
                            Navigator.pop(context);
                            _showPaymentDialog(context, data,ref);
                          },
                          onError: (error) {
                            debugPrint("❌ Payment error: $error");
                            Navigator.pop(context);
                            _showDialog(context, "Payment Failed", error.toString());
                          },
                          onCancel: () {
                            debugPrint("🚫 Payment cancelled");
                            Navigator.pop(context);
                            _showDialog(context, "Payment Cancelled", "User cancelled the payment");
                          },
                          returnUrl: "https://www.youtube.com/channel/UC9a1yj1xV2zeyiFPZ1gGYGw",
                          cancelUrl: "https://www.youtube.com/channel/UC9a1yj1xV2zeyiFPZ1gGYGw",
                        ),
                      ),
                    );
                  }
                },
              ),

            ],
            const SizedBox(height: 8),
            if (cart.isEmpty)
              const Text(
                "🛒 Add items to cart to enable checkout",
                style: TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 4),

            // 🔗 Transaction Page Button
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => context.pushNamed('transaction'),
              child: const Text("Go to Transaction Page"),
            ),
            const SizedBox(height: 4),

            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => context.pushNamed('refund'),
              child: const Text("Go to Refund Page"),
            ),

            // --- Checkout State Messages ---
            if (checkoutState is CheckoutLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(),
              ),
            if (checkoutState is CheckoutError)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text("❌ Error: ${(checkoutState).message}", style: const TextStyle(color: Colors.red)),
              ),
            if (checkoutState is CheckoutSuccess)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text("✅ Payment successful!", style: TextStyle(color: Colors.green)),
              ),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // only close the dialog
              // If you want to close webview too, call Navigator.pop(context) AFTER
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
  void _showPaymentDialog(BuildContext context, Map<String, dynamic> data, WidgetRef ref) {
    final saleId = _extractSaleId(data);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isRefundLoading = false;
        String? refundError;
        String? refundSuccess;

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text("Payment Successful"),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Your payment was successful!"),
                  const SizedBox(height: 12),
                  Text("Sale ID: ${saleId ?? 'N/A'}"),
                  if (isRefundLoading)
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(),
                    ),
                  if (refundError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(refundError!, style: const TextStyle(color: Colors.red)),
                    ),
                  if (refundSuccess != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(refundSuccess!, style: const TextStyle(color: Colors.green)),
                    ),
                ],
              ),
            ),
            actions: [
              if (saleId != null)
                TextButton(
                  onPressed: isRefundLoading
                      ? null
                      : () async {
                    setState(() {
                      isRefundLoading = true;
                      refundError = null;
                      refundSuccess = null;
                    });

                    try {
                      final result = await ref.read(refundProvider.notifier).refundTransaction(
                        accessToken: "YOUR_ACCESS_TOKEN",
                        captureId: saleId,
                        value: null,
                        currencyCode: "USD",
                        noteToPayer: "Refund from app",
                      );

                      setState(() {
                        refundSuccess = "Refund successful!";
                      });
                    } catch (e) {
                      setState(() {
                        refundError = "Refund failed: $e";
                      });
                    } finally {
                      setState(() {
                        isRefundLoading = false;
                      });
                    }
                  },
                  child: const Text("Refund"),
                ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      },
    );

    // Always print the full payment data
    debugPrint("✅ Full payment response: $data");
  }

  String? _extractSaleId(Map<String, dynamic> data) {
    try {
      final transactions = data['transactions'] as List<dynamic>?;
      if (transactions != null && transactions.isNotEmpty) {
        final relatedResources = transactions[0]['related_resources'] as List<dynamic>?;
        if (relatedResources != null && relatedResources.isNotEmpty) {
          final sale = relatedResources[0]['sale'] as Map<String, dynamic>?;
          return sale?['id'] as String?;
        }
      }
    } catch (_) {}
    return null;
  }


}
