import 'dart:async';
import 'package:flutter/material.dart';
import '../../news/pages/news_detail_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key, this.notifications});
  final ValueNotifier<List<Map<String, dynamic>>>? notifications;
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

/// NotificationPage
///
/// Kegunaan:
/// - Menampilkan daftar notifikasi internal yang dikirim dari `HomeScreen`
///   ketika ada berita baru.
/// - Mendukung menandai semua sebagai dibaca, menghapus notifikasi, dan
///   membuka detail berita terkait.
///
/// Catatan:
/// - Notifikasi disimpan sementara di `ValueNotifier` yang diteruskan dari
///   `HomeScreen`; tidak ada persistensi ke Firestore pada implementasi saat ini.

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFF09092D);
  static const _accent = Color(0xFFFECF06);
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late DateTime _now;
  Timer? _clockTimer;
  final Set<String> _deletingIds = <String>{};

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    final curve = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(curve);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(curve);
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _entryController.dispose();
    super.dispose();
  }

  void _markAllAsRead() {
    if (widget.notifications == null) return;
    final updated = widget.notifications!.value
        .map((item) => {...item, 'isRead': true})
        .toList();
    widget.notifications!.value = updated;
  }

  Future<void> _deleteNotification(String itemId) async {
    if (widget.notifications == null) return;
    setState(() => _deletingIds.add(itemId));
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    widget.notifications!.value = widget.notifications!.value
        .where((item) => item['id'] != itemId)
        .toList();
    if (!mounted) return;
    setState(() => _deletingIds.remove(itemId));
  }

  void _openNotification(Map<String, dynamic> item) {
    if (widget.notifications == null) return;
    final itemId = item['id'] as String;
    final updated = widget.notifications!.value
        .map((n) => n['id'] == itemId ? {...n, 'isRead': true} : n)
        .toList();
    widget.notifications!.value = updated;
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (context, animation, secondaryAnimation) => NewsDetailPage(
          imageUrl: item['imageUrl'] as String,
          title: item['title'] as String,
          description: item['description'] as String,
          date: item['date'] as String,
          category: item['category'] as String,
          createdBy: item['createdBy'] as String,
          updatedAt: item['timestamp'] as DateTime,
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
                        Icon(Icons.done_all_rounded, color: _accent, size: 18),
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
                  child: widget.notifications != null
                      ? ValueListenableBuilder<List<Map<String, dynamic>>>(
                          valueListenable: widget.notifications!,
                          builder: (context, notifications, _) {
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
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, index) {
                                final item = notifications[index];
                                final itemId = item['id'] as String;
                                final isRemoving = _deletingIds.contains(
                                  itemId,
                                );
                                return AnimatedOpacity(
                                  duration: const Duration(milliseconds: 180),
                                  opacity: isRemoving ? 0 : 1,
                                  child: AnimatedSlide(
                                    duration: const Duration(milliseconds: 180),
                                    offset: isRemoving
                                        ? const Offset(-0.04, 0)
                                        : Offset.zero,
                                    curve: Curves.easeOut,
                                    child: _NotificationCard(
                                      item: item,
                                      now: _now,
                                      onTap: () => _openNotification(item),
                                      onDelete: () =>
                                          _deleteNotification(itemId),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                            'No notifications',
                            style: TextStyle(
                              color: Color(0xFFAAAAAA),
                              fontSize: 14,
                            ),
                          ),
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
      child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFF1A1A40))),
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
  final Map<String, dynamic> item;
  final DateTime now;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  static String _formatRelativeTime(DateTime timestamp, DateTime now) {
    final diff = now.difference(timestamp);
    if (diff.isNegative || diff < const Duration(minutes: 1)) return 'Just now';
    if (diff < const Duration(hours: 1)) {
      final min = diff.inMinutes;
      return '$min minute${min == 1 ? '' : 's'} ago';
    }
    if (diff < const Duration(days: 1)) {
      final hrs = diff.inHours;
      return '$hrs hour${hrs == 1 ? '' : 's'} ago';
    }
    final d = diff.inDays;
    return '$d day${d == 1 ? '' : 's'} ago';
  }

  @override
  Widget build(BuildContext context) {
    final isRead = item['isRead'] as bool? ?? false;

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
              if (!isRead)
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
                padding: EdgeInsets.only(left: isRead ? 0 : 5),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    item['category'] as String,
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
                                  _formatRelativeTime(
                                    item['timestamp'] as DateTime,
                                    now,
                                  ),
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
                              item['title'] as String,
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
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: onDelete,
                        child: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFFAAAAAA),
                          size: 20,
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
