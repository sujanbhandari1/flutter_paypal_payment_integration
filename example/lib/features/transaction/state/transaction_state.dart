import '../models/transaction_history_model.dart';

class TransactionHistoryState {
  final bool isLoading;
  final TransactionHistoryResponse? data;
  final String? error;

  TransactionHistoryState({this.isLoading = false, this.data, this.error});

  TransactionHistoryState copyWith({
    bool? isLoading,
    TransactionHistoryResponse? data,
    String? error,
  }) {
    return TransactionHistoryState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }
}
