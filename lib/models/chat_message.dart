class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String recipientId;
  final String recipientName;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.recipientName,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead ? 1 : 0,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      senderId: map['senderId'],
      senderName: map['senderName'],
      recipientId: map['recipientId'],
      recipientName: map['recipientName'],
      message: map['message'],
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'] == 1,
    );
  }
}
