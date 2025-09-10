import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/refund_state_provider.dart';

class RefundScreen extends ConsumerStatefulWidget {
  final String transactionId; // could be captureId
  const RefundScreen({super.key, required this.transactionId});

  @override
  ConsumerState<RefundScreen> createState() => _RefundScreenState();
}

class _RefundScreenState extends ConsumerState<RefundScreen> {
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(refundProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Refund Transaction")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Refund Transaction ID: ${widget.transactionId}",
                style: Theme.of(context).textTheme.titleMedium),

            const SizedBox(height: 16),

            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: "Refund Amount (optional)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: "Note to Payer (optional)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
              onPressed: () {
                ref.read(refundProvider.notifier).refundTransaction(
                  accessToken: "YOUR_ACCESS_TOKEN", // TODO: get from auth
                  captureId: widget.transactionId,
                  value: amountController.text.isEmpty
                      ? null
                      : amountController.text,
                  currencyCode: "USD", // static for demo
                  noteToPayer: noteController.text.isEmpty
                      ? null
                      : noteController.text,
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Process Refund"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),

            const SizedBox(height: 24),

            if (state.error != null)
              Text("❌ ${state.error}",
                  style: const TextStyle(color: Colors.red)),

            if (state.data != null)
              Expanded(
                child: ListView(
                  children: [
                    Text("✅ Refund Success!",
                        style: const TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Text(state.data.toString()),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
