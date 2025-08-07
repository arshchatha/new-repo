import 'package:flutter/material.dart';

class CarrierBrokerChatTile extends StatelessWidget {
  final String avatarUrl;
  final String username;
  final String loadId;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final VoidCallback onTap;

  const CarrierBrokerChatTile({
    super.key,
    required this.avatarUrl,
    required this.username,
    required this.loadId,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.onTap,
  });

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 7) {
      return '${time.month}/${time.day}/${time.year}';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundImage: avatarUrl.isNotEmpty
            ? NetworkImage(avatarUrl)
            : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
      ),
      title: Text(
        username,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatTimestamp(lastMessageTime),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
