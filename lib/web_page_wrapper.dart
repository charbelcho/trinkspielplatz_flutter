import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SafariWrapper extends StatefulWidget {
  final String url;

  const SafariWrapper({super.key, required this.url});

  @override
  // ignore: library_private_types_in_public_api
  _SafariWrapperState createState() => _SafariWrapperState();
}

class _SafariWrapperState extends State<SafariWrapper> {
  WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  //..loadRequest(Uri.parse(url));

  @override
  Widget build(BuildContext context) {
    controller.loadRequest(Uri.parse(widget.url));
    return WebViewWidget(
      controller: controller,
      
    );
  }
}
