import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/transaction_state_provider.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch transactions once when screen is first opened
    Future.microtask(() {
      ref.read(transactionHistoryProvider.notifier).fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
            ? _buildMessage("❌ Error: ${state.error}", Colors.red)
            : state.data == null ||
            state.data!.transactionDetails.isEmpty
            ? _buildMessage("No transactions found", Colors.grey)
            : ListView.builder(
          itemCount: state.data!.transactionDetails.length,
          itemBuilder: (context, index) {
            final txn =
            state.data!.transactionDetails[index];
            final info = txn.transactionInfo;

            return Card(
              margin: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  "Txn ID: ${info.transactionId}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildStatusBadge(
                              info.transactionStatus),
                          const SizedBox(width: 8),
                          Text(
                            "${info.transactionAmount.value} ${info.transactionAmount.currencyCode}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Updated: ${info.transactionUpdatedDate}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.refresh),
          label: const Text("Refresh Transactions"),
          onPressed: () {
            ref
                .read(transactionHistoryProvider.notifier)
                .fetchTransactions();
          },
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case "completed":
        color = Colors.green;
        break;
      case "pending":
        color = Colors.orange;
        break;
      case "failed":
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildMessage(String text, Color color) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
