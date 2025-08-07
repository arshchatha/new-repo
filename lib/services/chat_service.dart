import 'package:flutter/material.dart';
import 'package:lboard/core/core/services/platform_database_service.dart';
import 'package:lboard/models/chat_message.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final Map<String, List<ChatMessage>> _conversations = {};
  final Map<String, String> _typingIndicators = {}; // userId: typingIndicator
  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  String _getConversationId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  Future<List<ChatMessage>> getConversation(String userId1, String userId2) async {
    return await PlatformDatabaseService.instance.getMessagesBetweenUsers(userId1, userId2);
  }

  Future<void> sendMessage({
    required String senderId,
    required String senderName,
    required String recipientId,
    required String recipientName,
    required String message,
  }) async {
    final chatMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName,
      recipientId: recipientId,
      recipientName: recipientName,
      message: message,
      timestamp: DateTime.now(),
      isRead: false,
    );

    await PlatformDatabaseService.instance.insertMessage(chatMessage);
    _notifyListeners();
  }

  void setTypingIndicator(String userId, String status) {
    _typingIndicators[userId] = status;
    _notifyListeners();
  }

  String getTypingIndicator(String userId) {
    return _typingIndicators[userId] ?? '';
  }

  void markMessagesAsRead(String currentUserId, String otherUserId) {
    final conversationId = _getConversationId(currentUserId, otherUserId);
    final conversation = _conversations[conversationId];
    
    if (conversation != null) {
      for (int i = 0; i < conversation.length; i++) {
        if (conversation[i].recipientId == currentUserId && !conversation[i].isRead) {
          // Note: This would need to be updated in the database as well
          // For now, just updating the local cache
        }
      }
      _notifyListeners();
    }
  }

  int getUnreadMessageCount(String userId) {
    int count = 0;
    for (final conversation in _conversations.values) {
      count += conversation.where((msg) => msg.recipientId == userId && !msg.isRead).length;
    }
    return count;
  }

  List<String> getConversationPartners(String userId) {
    final partners = <String>{};
    for (final conversationId in _conversations.keys) {
      final userIds = conversationId.split('_');
      if (userIds.contains(userId)) {
        partners.add(userIds.firstWhere((id) => id != userId));
      }
    }
    return partners.toList();
  }

  Future<ChatMessage?> getLastMessage(String userId1, String userId2) async {
    final conversation = await getConversation(userId1, userId2);
    return conversation.isNotEmpty ? conversation.last : null;
  }
}
