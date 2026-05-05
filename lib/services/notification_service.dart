import 'package:flutter/foundation.dart';

import '../features/authentication/models/news_model.dart';

class AppNotificationItem {
  AppNotificationItem({
    required this.id,
    required this.title,
    required this.category,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl = '',
    this.description = '',
    this.date = '',
    this.createdBy = 'Admin',
  });

  final String id;
  final String title;
  final String category;
  final DateTime timestamp;
  final bool isRead;
  final String imageUrl;
  final String description;
  final String date;
  final String createdBy;

  AppNotificationItem copyWith({
    String? id,
    String? title,
    String? category,
    DateTime? timestamp,
    bool? isRead,
    String? imageUrl,
    String? description,
    String? date,
    String? createdBy,
  }) {
    return AppNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      date: date ?? this.date,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final ValueNotifier<List<AppNotificationItem>> notifications =
      ValueNotifier<List<AppNotificationItem>>(_seedNotifications());

  static List<AppNotificationItem> _seedNotifications() {
    final now = DateTime.now();
    return [
      AppNotificationItem(
        id: 'seed-1',
        title: 'Indonesia has already for Indonesia masters 2026',
        category: 'Badminton',
        timestamp: now.subtract(const Duration(minutes: 5)),
        isRead: false,
        imageUrl: 'https://via.placeholder.com/150',
        description: 'Popular news detail from home page.',
        date: '16/12/2025',
        createdBy: 'Admin',
      ),
      AppNotificationItem(
        id: 'seed-2',
        title: 'Lin Chun Yi reached the final after a hard-fought match',
        category: 'Badminton',
        timestamp: now.subtract(const Duration(minutes: 5)),
        isRead: true,
        imageUrl: 'https://via.placeholder.com/150',
        description: 'Hot news detail from home page.',
        date: '20/01/2026',
        createdBy: 'Admin',
      ),
      AppNotificationItem(
        id: 'seed-3',
        title: 'Brazil keeps pushing after dramatic late comeback win',
        category: 'Soccer',
        timestamp: now.subtract(const Duration(minutes: 5)),
        isRead: false,
        imageUrl: 'https://via.placeholder.com/150',
        description: 'Popular news detail from home page.',
        date: '12/01/03',
        createdBy: 'Admin',
      ),
      AppNotificationItem(
        id: 'seed-4',
        title: 'Tim Basket Indonesia Raih Kemenangan Besar di Kualifikasi Asia',
        category: 'Basketball',
        timestamp: now.subtract(const Duration(minutes: 5)),
        isRead: true,
        imageUrl: 'https://via.placeholder.com/150',
        description: 'Latest news detail from home page.',
        date: '30/01/2026',
        createdBy: 'Admin',
      ),
      AppNotificationItem(
        id: 'seed-5',
        title: 'Captain returns and instantly changes team chemistry',
        category: 'Volly',
        timestamp: now.subtract(const Duration(minutes: 5)),
        isRead: false,
        imageUrl: 'https://via.placeholder.com/150',
        description: 'Popular news detail from home page.',
        date: '12/01/07',
        createdBy: 'Admin',
      ),
    ];
  }

  void addFromNews(SportModel news, {DateTime? timestamp}) {
    final nextNotification = AppNotificationItem(
      id: '${news.title}_${DateTime.now().microsecondsSinceEpoch}',
      title: news.title,
      category: news.category,
      timestamp: timestamp ?? news.createdAt,
      isRead: false,
      imageUrl: news.imageUrl,
      description: news.description,
      date: news.date,
      createdBy: news.createdBy,
    );

    notifications.value = [
      nextNotification,
      ...notifications.value,
    ];
  }

  void markAsRead(String id) {
    notifications.value = notifications.value
        .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
        .toList(growable: false);
  }

  void markAllAsRead() {
    notifications.value = notifications.value
        .map((item) => item.copyWith(isRead: true))
        .toList(growable: false);
  }

  void delete(String id) {
    notifications.value = notifications.value
        .where((item) => item.id != id)
        .toList(growable: false);
  }

  static String formatRelativeTime(DateTime timestamp, DateTime now) {
    final diff = now.difference(timestamp);
    if (diff.isNegative || diff < const Duration(minutes: 1)) {
      return 'Just now';
    }
    if (diff < const Duration(hours: 1)) {
      final minutes = diff.inMinutes;
      return '$minutes minute${minutes == 1 ? '' : 's'} ago';
    }
    if (diff < const Duration(days: 1)) {
      final hours = diff.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    }
    final days = diff.inDays;
    return '$days day${days == 1 ? '' : 's'} ago';
  }
}