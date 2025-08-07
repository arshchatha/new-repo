import 'package:flutter/material.dart';
import '../screens/custom_chat_page.dart';

class TawkToChatButton extends StatefulWidget {
  const TawkToChatButton({super.key});

  @override
  State<TawkToChatButton> createState() => _TawkToChatButtonState();
}

class _TawkToChatButtonState extends State<TawkToChatButton> {
  bool _isChatOpen = false;

  void _toggleChat() {
    setState(() {
      _isChatOpen = !_isChatOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360, // Constrain width to avoid overflow
      height: 480, // Constrain height to avoid overflow
      child: Stack(
        clipBehavior: Clip.hardEdge, // Changed from Clip.none to Clip.hardEdge to prevent overflow issues
        children: [
          if (_isChatOpen)
            Positioned(
              bottom: 80,
              right: 20,
              width: 320, // Slightly smaller width to fit inside SizedBox
              height: 400,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Customer Service',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: _toggleChat,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: const CustomChatPage(),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _toggleChat,
              tooltip: 'Chat with Customer Service',
              child: Icon(_isChatOpen ? Icons.close : Icons.chat_bubble_outline),
            ),
          ),
        ],
      ),
    );
  }
}
