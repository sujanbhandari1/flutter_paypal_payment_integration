# Troubleshooting Guide – Flutter PayPal Integration

This guide helps you resolve common issues when using the Flutter PayPal integration package.

---

## 1. WebView Does Not Load / Blank Screen

**Possible Causes:**
- Incorrect `approvalUrl` or `returnUrl`.
- InAppWebView not properly configured.
- Network restrictions or missing permissions.

**Solutions:**
1. Ensure you are passing valid sandbox/live credentials (`clientId` and `secretKey`).
2. Verify that your `returnUrl` and `cancelUrl` are correctly formatted. Example:
   ```dart
   returnUrl: "https://example.com/success",
   cancelUrl: "https://example.com/cancel",
   ```
3. Add necessary Android permissions in `AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   ```
4. For iOS, update **Info.plist**:
   ```xml
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsArbitraryLoads</key>
       <true/>
   </dict>
   ```

---

## 2. Payment Not Executing / Missing PayerID

**Cause:**
- PayPal does not return a valid `PayerID` after approval.

**Solution:**
- Make sure your `returnUrl` matches the one registered in PayPal.
- Confirm `_executePayment(payerId)` is called with the correct `payerId`:
  ```dart
  final payerId = Uri.parse(url).queryParameters['PayerID'];
  ```

---

## 3. Payment Failure

**Common Causes:**
- Incorrect client ID or secret key.
- Currency mismatch.
- Invalid transaction details (amount, subtotal, shipping, etc.).

**Solution:**
- Verify all transaction details:
  ```dart
  "amount": {
    "total": total.toStringAsFixed(2),
    "currency": "AUD",
    "details": {"subtotal": total.toStringAsFixed(2)}
  }
  ```
- Use sandbox mode for testing:
  ```dart
  sandboxMode: true
  ```

---

## 4. Button Disabled / Not Tappable

**Possible Causes:**
- `enabled` property is `false`.
- Widget tree blocked by overlay.

**Solution:**
- Ensure `enabled` is true when the cart has items:
  ```dart
enabled: cart.isNotEmpty
  ```
- Check that the button is not covered by other widgets.

---

## 5. Loading Indicator Stuck / Payment Not Started

**Cause:**
- `_approvalUrl` is `null` due to failed `_createPayment`.

**Solution:**
- Wrap `_createPayment` in `try/catch` and show a retry button on failure.
- Use optional `loadingIndicator` widget.

---

## 6. Refund Not Working

**Possible Causes:**
- Incorrect `captureId` or amount.
- Sandbox account limitations.

**Solution:**
- Extract the **saleId** correctly:
  ```dart
  final saleId = data['transactions'][0]['related_resources'][0]['sale']['id'];
  ```
- Refund only after payment is completed successfully.

---

## 7. Common Flutter / WebView Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `PlatformException: WebView not available` | WebView plugin not installed/configured | Ensure `flutter_inappwebview` is in `pubspec.yaml` and run `flutter pub get`. |
| `Network Error` | No internet or blocked domain | Check device internet and URLs allowed by PayPal sandbox/live. |
| `Null PayerID` | User canceled or malformed URL | Implement `onCancel` callback and handle errors gracefully. |

---

## 8. Debugging Tips

1. Use `debugPrint` to log payment data:
   ```dart
   debugPrint("Payment response: $data");
   ```
2. Use **sandbox accounts** for testing.

3. Always handle errors gracefully in `onError` callback.

---

## 9. Support / Reporting Bugs

- Provide the following information when reporting bugs:
    - Flutter version
    - Package version
    - Platform (iOS/Android)
    - Full debug logs
    - Sandbox/live credentials (if safe)

- Open a GitHub issue if the problem persists.

---

This guide covers most common issues when integrating PayPal in Flutter apps.

