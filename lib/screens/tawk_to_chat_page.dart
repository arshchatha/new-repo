import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TawkToChatPage extends StatefulWidget {
  // Replace this with your actual direct chat link from Tawk.to
  final String chatUrl = 'https://tawk.to/chat/YOUR_PROPERTY_ID/default';

  const TawkToChatPage({super.key});

  @override
  State<TawkToChatPage> createState() => _TawkToChatPageState();
}

class _TawkToChatPageState extends State<TawkToChatPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.chatUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Chat")),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
