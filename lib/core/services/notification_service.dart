import 'package:flutter/material.dart';
import 'dart:async';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  final List<Map<String, dynamic>> _notifications = [];
  Timer? _autoCleanTimer;
  
  void init() {
    _autoCleanTimer = Timer.periodic(const Duration(hours: 24), (timer) {
      _cleanOldNotifications();
    });
  }
  
  void showNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? action,
    Duration? autoDismiss,
  }) {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'timestamp': DateTime.now(),
      'read': false,
      'action': action,
    };
    
    _notifications.insert(0, notification);
    notifyListeners();
    
    if (autoDismiss != null) {
      Future.delayed(autoDismiss, () {
        _notifications.removeWhere((n) => n['id'] == notification['id']);
        notifyListeners();
      });
    }
  }
  
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notifications[index]['read'] = true;
      notifyListeners();
    }
  }
  
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['read'] = true;
    }
    notifyListeners();
  }
  
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
  
  void removeNotification(String id) {
    _notifications.removeWhere((n) => n['id'] == id);
    notifyListeners();
  }
  
  List<Map<String, dynamic>> getNotifications({bool unreadOnly = false}) {
    if (unreadOnly) {
      return _notifications.where((n) => !n['read']).toList();
    }
    return List.from(_notifications);
  }
  
  int getUnreadCount() {
    return _notifications.where((n) => !n['read']).length;
  }
  
  void _cleanOldNotifications() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    _notifications.removeWhere((n) => n['timestamp'].isBefore(weekAgo));
    notifyListeners();
  }
  
  void dispose() {
    _autoCleanTimer?.cancel();
    super.dispose();
  }
}

enum NotificationType {
  info,
  success,
  warning,
  error,
  system,
  security,
  update,
}

extension NotificationTypeExtension on NotificationType {
  Color getColor() {
    switch (this) {
      case NotificationType.info:
        return const Color(0xFF00BCD4);
      case NotificationType.success:
        return Colors.green;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.system:
        return Colors.purple;
      case NotificationType.security:
        return Colors.amber;
      case NotificationType.update:
        return Colors.blue;
    }
  }
  
  IconData getIcon() {
    switch (this) {
      case NotificationType.info:
        return Icons.info_outline;
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.warning:
        return Icons.warning_amber_outlined;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.system:
        return Icons.computer;
      case NotificationType.security:
        return Icons.security;
      case NotificationType.update:
        return Icons.system_update;
    }
  }
}
