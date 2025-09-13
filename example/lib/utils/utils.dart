class ReusableUtils{
  /// Extracts the sale ID from the provided payment data.
  ///
  static String? extractSaleId(Map<String, dynamic> data) {
    try {
      final transactions = data['transactions'] as List<dynamic>?;
      if (transactions != null && transactions.isNotEmpty) {
        final relatedResources =
        transactions[0]['related_resources'] as List<dynamic>?;
        if (relatedResources != null && relatedResources.isNotEmpty) {
          final sale = relatedResources[0]['sale'] as Map<String, dynamic>?;
          return sale?['id'] as String?;
        }
      }
    } catch (_) {}
    return null;
  }

  static String? extractCurrency(Map<String, dynamic> data) {
    try {
      final transactions = data['transactions'] as List<dynamic>?;
      if (transactions != null && transactions.isNotEmpty) {
        Map<String, dynamic> transactionData = transactions[0];
        final relatedResources = transactionData['amount']['currency'];
        if (relatedResources != null) {
          return relatedResources;
        }
      }
    } catch (_) {}
    return null;
  }

  static String? extractTotal(Map<String, dynamic> data) {
    try {
      final transactions = data['transactions'] as List<dynamic>?;
      if (transactions != null && transactions.isNotEmpty) {
        Map<String, dynamic> transactionData = transactions[0];
        if (transactionData['amount']['total'] != null) {
          return transactionData['amount']['total'];
        }
      }
    } catch (_) {}
    return null;
  }
}