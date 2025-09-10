import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/transaction_state_provider.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen> {

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
      appBar: AppBar(title: const Text("Transaction History")),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(child: Text("❌ Error: ${state.error}"))
          : state.data == null
          ? const Center(child: Text("No transactions found"))
          : ListView.builder(
        itemCount: state.data!.transactionDetails.length,
        itemBuilder: (context, index) {
          final txn = state.data!.transactionDetails[index];
          final info = txn.transactionInfo;

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text("Txn ID: ${info.transactionId}"),
              subtitle: Text(
                "Status: ${info.transactionStatus}\n"
                    "Amount: ${info.transactionAmount.value} ${info.transactionAmount.currencyCode}",
              ),
              trailing: Text(info.transactionUpdatedDate),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(transactionHistoryProvider.notifier).fetchTransactions();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
