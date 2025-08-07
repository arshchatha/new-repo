import 'package:flutter/material.dart';
import 'package:lboard/models/chat_message.dart';
import 'package:lboard/services/chat_service.dart';
import 'package:lboard/providers/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  String? _selectedUserId;
  String? _selectedUserName;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _chatService.addListener(_onChatUpdated);
    _focusNode.addListener(_onFocusChange);
  }
  
  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _controller.text = '';
      showEmojiPicker = false;
    }
  }

  @override
  void dispose() {
    _chatService.removeListener(_onChatUpdated);
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onChatUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = AuthProvider.of(context);
    final currentUser = authProvider.user;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(child: Text('Please log in to access chat')),
      );
    }

    final conversationPartners = _chatService.getConversationPartners(currentUser.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Row(
        children: [
          // Conversation list
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: conversationPartners.isEmpty
                  ? const Center(
                      child: Text(
                        'No conversations yet.\nStart chatting from load details!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: conversationPartners.length,
                      itemBuilder: (context, index) {
                        final partnerId = conversationPartners[index];
                        return FutureBuilder<ChatMessage?>(
                          future: _chatService.getLastMessage(currentUser.id, partnerId),
                          builder: (context, lastMessageSnapshot) {
                            final lastMessage = lastMessageSnapshot.data;
                            return FutureBuilder<List<ChatMessage>>(
                              future: _chatService.getConversation(currentUser.id, partnerId),
                              builder: (context, conversationSnapshot) {
                                int unreadCount = 0;
                                if (conversationSnapshot.hasData) {
                                  unreadCount = conversationSnapshot.data!
                                      .where((msg) => msg.recipientId == currentUser.id && !msg.isRead)
                                      .length;
                                }

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Text(
                                      partnerId.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(
                                    partnerId,
                                    style: TextStyle(
                                      fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: lastMessage != null
                                      ? Text(
                                          lastMessage.message,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                                          ),
                                        )
                                      : null,
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        lastMessage != null ? _formatTime(lastMessage.timestamp) : '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      if (unreadCount > 0)
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 20,
                                            minHeight: 20,
                                          ),
                                          child: Text(
                                            '$unreadCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                    ],
                                  ),
                                  selected: _selectedUserId == partnerId,
                                  onTap: () {
                                    setState(() {
                                      _selectedUserId = partnerId;
                                      _selectedUserName = partnerId;
                                    });
                                    _chatService.markMessagesAsRead(currentUser.id, partnerId);
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
          // Chat area
          Expanded(
            flex: 2,
            child: _selectedUserId == null
                ? const Center(
                    child: Text(
                      'Select a conversation to start chatting',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  _selectedUserId!.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _selectedUserName ?? _selectedUserId!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _buildChatMessages(currentUser.id, _selectedUserId!),
                        ),
                        _buildMessageInput(currentUser, _selectedUserId!, _selectedUserName!),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages(String currentUserId, String partnerId) {
    return FutureBuilder<List<ChatMessage>>(
      future: _chatService.getConversation(currentUserId, partnerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No messages yet.\nStart the conversation!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        final messages = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isCurrentUser = message.senderId == currentUserId;

            return Align(
              alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(maxWidth: 300),
                decoration: BoxDecoration(
                  color: isCurrentUser ? Colors.blue.shade500 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
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
        );
      },
    );
  }

  Widget _buildMessageInput(dynamic currentUser, String partnerId, String partnerName) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (text) {
                _chatService.setTypingIndicator(currentUser.id, text.isNotEmpty ? 'typing...' : '');
              },
              onSubmitted: (text) => _sendMessage(_controller, currentUser, partnerId, partnerName),
              maxLines: null,
            ),
          ),
          IconButton(
            icon: Icon(showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions, color: Colors.blue),
            onPressed: () {
              setState(() {
                showEmojiPicker = !showEmojiPicker;
                if (!showEmojiPicker) {
                  _focusNode.requestFocus();
                } else {
                  _focusNode.unfocus();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () => _sendMessage(_controller, currentUser, partnerId, partnerName),
          ),
        ],
      ),
    );
  }

  void _sendMessage(TextEditingController controller, dynamic currentUser, String partnerId, String partnerName) {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    _chatService.sendMessage(
      senderId: currentUser.id,
      senderName: currentUser.name.isNotEmpty ? currentUser.name : 'User',
      recipientId: partnerId,
      recipientName: partnerName,
      message: text,
    );

    controller.clear();
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
      return '${difference.inDays}d ago';
    }
  }
}
