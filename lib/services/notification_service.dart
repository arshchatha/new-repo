import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<AppNotification> _notifications = [];
  final List<VoidCallback> _listeners = [];

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

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

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    _notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _notifyListeners();
  }

  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    _notifyListeners();
  }

  // Specific methods for bid notifications
  void notifyBidApproved({
    required String loadId,
    required String carrierId,
    required String brokerName,
    required double bidAmount,
    required String loadOrigin,
    required String loadDestination,
  }) {
    final notification = AppNotification(
      id: 'bid_approved_${loadId}_${carrierId}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Bid Approved!',
      message: 'Your bid of \$${bidAmount.toStringAsFixed(2)} for load #$loadId ($loadOrigin → $loadDestination) has been approved by $brokerName.',
      type: NotificationType.bidApproved,
      timestamp: DateTime.now(),
      userId: carrierId,
      loadId: loadId,
      bidAmount: bidAmount,
    );
    addNotification(notification);
  }

  void notifyBidRejected({
    required String loadId,
    required String carrierId,
    required String brokerName,
    required double bidAmount,
    required String loadOrigin,
    required String loadDestination,
  }) {
    final notification = AppNotification(
      id: 'bid_rejected_${loadId}_${carrierId}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Bid Rejected',
      message: 'Your bid of \$${bidAmount.toStringAsFixed(2)} for load #$loadId ($loadOrigin → $loadDestination) has been rejected by $brokerName.',
      type: NotificationType.bidRejected,
      timestamp: DateTime.now(),
      userId: carrierId,
      loadId: loadId,
      bidAmount: bidAmount,
    );
    addNotification(notification);
  }

  void notifyBidCountered({
    required String loadId,
    required String carrierId,
    required String brokerName,
    required double originalBidAmount,
    required double counterBidAmount,
    required String loadOrigin,
    required String loadDestination,
  }) {
    final notification = AppNotification(
      id: 'bid_countered_${loadId}_${carrierId}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Bid Countered',
      message: '$brokerName has countered your bid of \$${originalBidAmount.toStringAsFixed(2)} with \$${counterBidAmount.toStringAsFixed(2)} for load #$loadId ($loadOrigin → $loadDestination).',
      type: NotificationType.bidCountered,
      timestamp: DateTime.now(),
      userId: carrierId,
      loadId: loadId,
      bidAmount: counterBidAmount,
    );
    addNotification(notification);
  }

  void notifyBrokerApprovalConfirmation({
    required String loadId,
    required String brokerId,
    required String carrierName,
    required double bidAmount,
    required String loadOrigin,
    required String loadDestination,
  }) {
    final notification = AppNotification(
      id: 'approval_confirmed_${loadId}_${brokerId}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Bid Approval Confirmed',
      message: 'You have successfully approved $carrierName\'s bid of \$${bidAmount.toStringAsFixed(2)} for load #$loadId ($loadOrigin → $loadDestination).',
      type: NotificationType.approvalConfirmation,
      timestamp: DateTime.now(),
      userId: brokerId,
      loadId: loadId,
      bidAmount: bidAmount,
    );
    addNotification(notification);
  }

  void notifyCarrierConfirmationRequest({
    required String loadId,
    required String carrierId,
    required String brokerName,
    required double bidAmount,
    required String loadOrigin,
    required String loadDestination,
  }) {
    final notification = AppNotification(
      id: 'confirmation_request_${loadId}_${carrierId}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Load Confirmation Required',
      message: '$brokerName has approved your bid of \$${bidAmount.toStringAsFixed(2)} for load #$loadId ($loadOrigin → $loadDestination). Please confirm or decline the load.',
      type: NotificationType.carrierConfirmationRequest,
      timestamp: DateTime.now(),
      userId: carrierId,
      loadId: loadId,
      bidAmount: bidAmount,
    );
    addNotification(notification);
  }

  void notifyLoadConfirmed({
    required String loadId,
    required String brokerId,
    required String carrierName,
    required double bidAmount,
    required String loadOrigin,
    required String loadDestination,
  }) {
    final notification = AppNotification(
      id: 'load_confirmed_${loadId}_${brokerId}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Load Confirmed by Carrier',
      message: '$carrierName has confirmed load #$loadId ($loadOrigin → $loadDestination) for \$${bidAmount.toStringAsFixed(2)}.',
      type: NotificationType.loadConfirmed,
      timestamp: DateTime.now(),
      userId: brokerId,
      loadId: loadId,
      bidAmount: bidAmount,
    );
    addNotification(notification);
  }

  void notifyLoadDeclined({
    required String loadId,
    required String brokerId,
    required String carrierName,
    required double bidAmount,
    required String loadOrigin,
    required String loadDestination,
  }) {
    final notification = AppNotification(
      id: 'load_declined_${loadId}_${brokerId}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Load Declined by Carrier',
      message: '$carrierName has declined load #$loadId ($loadOrigin → $loadDestination). You can now choose another carrier.',
      type: NotificationType.loadDeclined,
      timestamp: DateTime.now(),
      userId: brokerId,
      loadId: loadId,
      bidAmount: bidAmount,
    );
    addNotification(notification);
  }

  void notifyChatMessage({
    required String senderId,
    required String senderName,
    required String message,
    required String recipientId,
  }) {
    final notification = AppNotification(
      id: 'chat_message_${senderId}_${recipientId}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Message from $senderName',
      message: message,
      type: NotificationType.chatMessage,
      timestamp: DateTime.now(),
      userId: recipientId,
      senderId: senderId,
    );
    addNotification(notification);
  }
}

enum NotificationType {
  bidApproved,
  bidRejected,
  bidCountered,
  approvalConfirmation,
  carrierConfirmationRequest,
  loadConfirmed,
  loadDeclined,
  chatMessage,
  general,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? userId;
  final String? loadId;
  final double? bidAmount;
  final String? senderId;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.userId,
    this.loadId,
    this.bidAmount,
    this.senderId,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? userId,
    String? loadId,
    double? bidAmount,
    String? senderId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      userId: userId ?? this.userId,
      loadId: loadId ?? this.loadId,
      bidAmount: bidAmount ?? this.bidAmount,
      senderId: senderId ?? this.senderId,
    );
  }

  IconData get icon {
    switch (type) {
      case NotificationType.bidApproved:
        return Icons.check_circle;
      case NotificationType.bidRejected:
        return Icons.cancel;
      case NotificationType.bidCountered:
        return Icons.swap_horiz;
      case NotificationType.approvalConfirmation:
        return Icons.verified;
      case NotificationType.carrierConfirmationRequest:
        return Icons.assignment_turned_in;
      case NotificationType.loadConfirmed:
        return Icons.verified_user;
      case NotificationType.loadDeclined:
        return Icons.assignment_return;
      case NotificationType.chatMessage:
        return Icons.chat;
      case NotificationType.general:
        return Icons.notifications;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.bidApproved:
        return Colors.green;
      case NotificationType.bidRejected:
        return Colors.red;
      case NotificationType.bidCountered:
        return Colors.orange;
      case NotificationType.approvalConfirmation:
        return Colors.blue;
      case NotificationType.carrierConfirmationRequest:
        return Colors.purple;
      case NotificationType.loadConfirmed:
        return Colors.green;
      case NotificationType.loadDeclined:
        return Colors.orange;
      case NotificationType.chatMessage:
        return Colors.blue;
      case NotificationType.general:
        return Colors.grey;
    }
  }
}
