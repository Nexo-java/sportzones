import 'dart:async';

import 'package:flutter/material.dart';

import '../../../services/notification_service.dart';
import '../../news/pages/news_detail_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFF09092D);
  static const _accent = Color(0xFFFECF06);

  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late DateTime _now;
  Timer? _clockTimer;
  final Set<String> _deletingIds = <String>{};

  NotificationService get _service => NotificationService.instance;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    final curve = CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(curve);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(curve);
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _entryController.forward();
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _entryController.dispose();
    super.dispose();
  }

  void _markAllAsRead() {
    _service.markAllAsRead();
  }

  Future<void> _deleteNotification(AppNotificationItem item) async {
    setState(() {
      _deletingIds.add(item.id);
    });

    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;

    _service.delete(item.id);
    if (!mounted) return;

    setState(() {
      _deletingIds.remove(item.id);
    });
  }

  void _openNotification(AppNotificationItem item) {
    _service.markAsRead(item.id);

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (context, animation, secondaryAnimation) => NewsDetailPage(
          imageUrl: item.imageUrl,
          title: item.title,
          description: item.description,
          date: item.date,
          category: item.category,
          createdBy: item.createdBy,
          updatedAt: item.timestamp,
          initialBottomTabIndex: 0,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curve),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _Header(onBack: () => Navigator.maybePop(context)),
                const _DividerLine(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: InkWell(
                    onTap: _markAllAsRead,
                    borderRadius: BorderRadius.circular(8),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.done_all_rounded,
                          color: _accent,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Tandai semua sudah dibaca',
                          style: TextStyle(
                            color: _accent,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder<List<AppNotificationItem>>(
                    valueListenable: _service.notifications,
                    builder: (context, notifications, child) {
                      if (notifications.isEmpty) {
                        return const Center(
                          child: Text(
                            'No notifications yet',
                            style: TextStyle(
                              color: Color(0xFFAAAAAA),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: notifications.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = notifications[index];
                          final isRemoving = _deletingIds.contains(item.id);
                          return AnimatedOpacity(
                            duration: const Duration(milliseconds: 180),
                            opacity: isRemoving ? 0 : 1,
                            child: AnimatedSlide(
                              duration: const Duration(milliseconds: 180),
                              offset: isRemoving ? const Offset(-0.04, 0) : Offset.zero,
                              curve: Curves.easeOut,
                              child: _NotificationCard(
                                item: item,
                                now: _now,
                                onTap: () => _openNotification(item),
                                onDelete: () => _deleteNotification(item),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            ),
            const Spacer(),
            const Text(
              'Notifikasi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 1,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(color: Color(0xFF1A1A40)),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.now,
    required this.onTap,
    required this.onDelete,
  });

  final AppNotificationItem item;
  final DateTime now;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 82,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A40),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              if (!item.isRead)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    width: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFECF06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(left: item.isRead ? 0 : 5),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    item.category,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  NotificationService.formatRelativeTime(item.timestamp, now),
                                  style: const TextStyle(
                                    color: Color(0xFFAAAAAA),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(18),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFD94242),
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}