import 'package:flutter/foundation.dart';

class RefundState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? data;

  const RefundState({
    this.isLoading = false,
    this.error,
    this.data,
  });

  RefundState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? data,
  }) {
    return RefundState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      data: data ?? this.data,
    );
  }
}
