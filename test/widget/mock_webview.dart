import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

class FakeInAppWebViewPlatform extends InAppWebViewPlatform {
  @override
  Widget build(BuildContext context, dynamic params) {
    // Return a simple container to simulate the webview
    return Container(key: const ValueKey('fake-webview'));
  }

  @override
  PlatformInAppWebViewWidget createPlatformInAppWebViewWidget(
      PlatformInAppWebViewWidgetCreationParams creationParams,
      ) {
    // Pass the creationParams as positional argument
    return PlatformInAppWebViewWidget(creationParams);
  }
}
