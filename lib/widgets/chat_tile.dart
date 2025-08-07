import 'package:flutter/material.dart';
import 'package:lboard/models/chat_message.dart';
import 'package:lboard/services/notification_service.dart';
import 'package:lboard/services/chat_service.dart';
import 'package:lboard/providers/auth_provider.dart';

class ChatTile extends StatefulWidget {
  final String userId;
  final String userName;
  final VoidCallback onClose;

  const ChatTile({
    super.key,
    required this.userId,
    required this.userName,
    required this.onClose,
  });

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  final TextEditingController _controller = TextEditingController();
  final NotificationService _notificationService = NotificationService();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _chatService.addListener(_onChatUpdated);
    
    // Mark messages as read when opening chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = AuthProvider.of(context);
      final currentUser = authProvider.user;
      if (currentUser != null) {
        _chatService.markMessagesAsRead(currentUser.id, widget.userId);
      }
    });
  }

  @override
  void dispose() {
    _chatService.removeListener(_onChatUpdated);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onChatUpdated() {
    if (mounted) {
      setState(() {});
      // Scroll to bottom when new message arrives
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    final authProvider = AuthProvider.of(context);
    final currentUser = authProvider.user;
    if (currentUser == null) return;

    // Send message through chat service
    _chatService.sendMessage(
      senderId: currentUser.id,
      senderName: currentUser.name.isNotEmpty ? currentUser.name : 'User',
      recipientId: widget.userId,
      recipientName: widget.userName,
      message: text,
    );
    
    // Send notification to the recipient
    _notificationService.notifyChatMessage(
      senderId: currentUser.id,
      senderName: currentUser.name.isNotEmpty ? currentUser.name : 'User',
      message: text,
      recipientId: widget.userId,
    );
    
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = AuthProvider.of(context);
    final currentUser = authProvider.user;
    
    if (currentUser == null) {
      return Container();
    }

    return FutureBuilder<List<ChatMessage>>(
      future: _chatService.getConversation(currentUser.id, widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final messages = snapshot.data ?? [];

        return Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Chat with ${widget.userName}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: widget.onClose,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: messages.isEmpty
                    ? const Center(
                        child: Text(
                          'No messages yet.\nStart the conversation!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isCurrentUser = message.senderId == currentUser.id;
                          
                          return Align(
                            alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              constraints: const BoxConstraints(maxWidth: 250),
                              decoration: BoxDecoration(
                                color: isCurrentUser ? Colors.blue.shade500 : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    message.message,
                                    style: TextStyle(
                                      color: isCurrentUser ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(message.timestamp),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isCurrentUser ? const Color.fromRGBO(255, 255, 255, 0.7) : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
