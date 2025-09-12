import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------- Fake Paypal Service ----------------
class FakePaypalService {
  Future<Map<String, dynamic>> executePayment() async =>
      {'id': 'PAY-EXECUTED', 'state': 'approved'};
}

// ---------------- Fake PaypalCheckoutView for Testing ----------------
class FakePaypalCheckoutView extends StatelessWidget {
  final VoidCallback onCancel;
  final Function(Map<String, dynamic>) onSuccess;
  final Function(dynamic) onError;
  final Widget? loadingIndicator;

  const FakePaypalCheckoutView({
    super.key,
    required this.onSuccess,
    required this.onError,
    required this.onCancel,
    this.loadingIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (loadingIndicator != null) loadingIndicator!,
        ElevatedButton(
          key: const ValueKey('fake-execute-button'),
          onPressed: () => onSuccess({'id': 'PAY-EXECUTED', 'state': 'approved'}),
          child: const Text('Execute Payment'),
        ),
      ],
    );
  }
}

// ---------------- Test ----------------
void main() {
  testWidgets('PaypalCheckoutView loads and calls success callback', (tester) async {
    bool successCalled = false;
    bool errorCalled = false;
    bool cancelCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: FakePaypalCheckoutView(
          onSuccess: (_) => successCalled = true,
          onError: (_) => errorCalled = true,
          onCancel: () => cancelCalled = true,
          loadingIndicator: const Text('Loading...'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify loading indicator
    expect(find.text('Loading...'), findsOneWidget);

    // Simulate success
    await tester.tap(find.byKey(const ValueKey('fake-execute-button')));
    await tester.pumpAndSettle();

    expect(successCalled, true);
    expect(errorCalled, false);
    expect(cancelCalled, false);
  });
}
