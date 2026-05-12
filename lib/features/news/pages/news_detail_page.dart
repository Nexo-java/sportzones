import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../home/home_screen.dart';
import '../../authentication/models/news_model.dart';
import '../../home/pages/add_news_page.dart';
import '../../notification/pages/notification_page.dart';
import '../../../services/user/user_repository.dart';
import '../../../services/bookmark/bookmark_service.dart';
import '../../../services/user/user_service.dart';
import '../../../shared/widgets/web_safe_network_image.dart';
import '../../../shared/widgets/custom_bottom_navbar.dart';
import '../../../shared/widgets/custom_header.dart';
import '../../../shared/widgets/top_success_banner.dart';

class NewsDetailPage extends StatefulWidget {
  NewsDetailPage({
    super.key,
    this.newsId,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.date,
    this.category = '',
    this.createdBy = 'Admin',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.initialBottomTabIndex = 0,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  final String? newsId;
  final String imageUrl;
  final String title;
  final String description;
  final String date;
  final String category;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int initialBottomTabIndex;

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage>
    with SingleTickerProviderStateMixin {
  static const _pageBg = Color(0xFF09092D);

  late int _currentBottomTab;
  late final List<String> _paragraphs;
  late final AnimationController _actionBannerController;
  late final Animation<Offset> _actionBannerAnimation;
  bool _isLoved = false;
  bool _isSaved = false;
  int _likeCount = 0;
  bool _showActionBanner = false;
  String _actionBannerText = '';
  Color _actionBannerColor = const Color(0xFF6FA437);
  final BookmarkService _bookmarkService = BookmarkService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final String _itemId;
  late DateTime _now;
  Timer? _relativeTimeTimer;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _likesCountSubscription;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _currentBottomTab = widget.initialBottomTabIndex.clamp(0, 3);
    _paragraphs = widget.description
        .split('\n\n')
        .where((text) => text.trim().isNotEmpty)
        .toList(growable: false);

    _itemId = widget.newsId ?? '${widget.title}_${widget.date}'.hashCode.toString();
    _isSaved = _bookmarkService.isBookmarked(_itemId);
    _checkIfLiked();
    _listenToLikeCount();

    _actionBannerController = AnimationController(
      duration: const Duration(milliseconds: 820),
      vsync: this,
    );
    _actionBannerAnimation = Tween<Offset>(
      begin: const Offset(0, -2.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _actionBannerController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _relativeTimeTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _relativeTimeTimer?.cancel();
    _likesCountSubscription?.cancel();
    _actionBannerController.dispose();
    super.dispose();
  }

  void _listenToLikeCount() {
    _likesCountSubscription?.cancel();
    _likesCountSubscription = _firestore
        .collection('likes')
        .where('id_berita', isEqualTo: _itemId)
        .snapshots()
        .listen(
      (snapshot) {
        if (!mounted) return;
        setState(() {
          _likeCount = snapshot.docs.length;
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _likeCount = 0;
        });
      },
    );
  }

  Future<void> _checkIfLiked() async {
    final currentUser = UserRepository.instance.getCurrentUser();
    if (currentUser == null || !mounted) return;

    final likeDocId = '${currentUser.idUser}_$_itemId';
    try {
      final doc = await _firestore.collection('likes').doc(likeDocId).get();
      if (mounted) {
        setState(() {
          _isLoved = doc.exists;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoved = false;
        });
      }
    }
  }

  String _formatRelativeTime(DateTime updatedAt) {
    final diff = _now.difference(updatedAt);
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

  void _onBottomNavTap(int index) {
    if (index == 0) {
      Navigator.pop(context);
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(initialIndex: index),
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
      (route) => false,
    );
  }

  Future<void> _onDeletePressed() async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A40),
              title: const Text(
                'Hapus Berita',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Yakin ingin menghapus berita ini?',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD94242),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Hapus'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed || !mounted) {
      return;
    }

    try {
      await _firestore.collection('berita').doc(_itemId).delete();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus berita di Firebase')),
      );
      return;
    }

    await _showActionBannerWith(
      text: 'Berhasil dihapus',
      backgroundColor: const Color(0xFFD94242),
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  Future<void> _onEditPressed() async {
    final updatedNews = await Navigator.push<SportModel>(
      context,
      PageRouteBuilder<SportModel>(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) => AddNewsPage(
          initialNews: SportModel(
            idBerita: _itemId,
            judul: widget.title,
            deskripsi: widget.description,
            isiKonten: widget.description,
            imgUrl: widget.imageUrl,
            kategori: widget.category.isEmpty ? 'Badminton' : widget.category,
            createdAt: widget.createdAt,
            updatedAt: widget.updatedAt,
            createdBy: widget.createdBy,
          ),
          pageTitle: 'Edit News',
          headerTitle: 'Update News Story',
          headerSubtitle: 'Edit the details below to update this SportZone headline.',
          submitButtonText: 'Update News',
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
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );

    if (updatedNews == null || !mounted) {
      return;
    }

    try {
      await _firestore.collection('berita').doc(_itemId).set(
            updatedNews.toMap(),
            SetOptions(merge: true),
          );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal update berita di Firebase')),
      );
      return;
    }

    await _showActionBannerWith(
      text: 'Succefull update news',
      backgroundColor: const Color(0xFF6FA437),
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop({'action': 'updated', 'news': updatedNews});
  }

  void _openNotifications() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 240),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (context, animation, secondaryAnimation) => const NotificationPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(curve),
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Future<void> _showActionBannerWith({
    required String text,
    required Color backgroundColor,
  }) async {
    if (!mounted) return;

    _actionBannerController.stop();
    _actionBannerController.value = 0.0;

    setState(() {
      _actionBannerText = text;
      _actionBannerColor = backgroundColor;
      _showActionBanner = true;
    });

    final frameReady = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!frameReady.isCompleted) {
        frameReady.complete();
      }
    });
    await frameReady.future;
    if (!mounted) return;

    await _actionBannerController.forward(from: 0.0);
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    await _actionBannerController.reverse();

    if (!mounted) return;

    setState(() {
      _showActionBanner = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final relativeUpdateText = _formatRelativeTime(widget.updatedAt);

    return Scaffold(
      backgroundColor: _pageBg,
      body: Stack(
        children: [
          SafeArea(
            top: false,
            bottom: false,
            child: Column(
              children: [
                CustomHeader(onNotificationTap: _openNotifications),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 26,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: SizedBox(
                              width: double.infinity,
                              height: 300,
                              child: _buildImage(widget.imageUrl),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                widget.date,
                                style: const TextStyle(
                                  color: Color(0xFFAAAAAA),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              if (UserService.instance.isAdmin) ...[
                                PopupMenuButton<String>(
                                  color: const Color(0xFF1A1A40),
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.white70,
                                    size: 24,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _onEditPressed();
                                    } else if (value == 'delete') {
                                      _onDeletePressed();
                                    }
                                  },
                                  itemBuilder: (context) {
                                    return const [
                                      PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                                            SizedBox(width: 10),
                                            Text('Edit', style: TextStyle(color: Colors.white)),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline_rounded, color: Color(0xFFD94242), size: 20),
                                            SizedBox(width: 10),
                                            Text('Delete', style: TextStyle(color: Colors.white)),
                                          ],
                                        ),
                                      ),
                                    ];
                                  },
                                ),
                                const SizedBox(width: 14),
                              ],
                              InkWell(
                                onTap: () async {
                                  final currentUser = UserRepository.instance.getCurrentUser();
                                  if (currentUser == null) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Silakan login terlebih dahulu')),
                                      );
                                    }
                                    return;
                                  }

                                  final likeDocId = '${currentUser.idUser}_$_itemId';
                                  try {
                                    if (_isLoved) {
                                      await _firestore.collection('likes').doc(likeDocId).delete();
                                    } else {
                                      await _firestore.collection('likes').doc(likeDocId).set({
                                        'id_user': currentUser.idUser,
                                        'id_berita': _itemId,
                                        'created_at': FieldValue.serverTimestamp(),
                                      });
                                    }

                                    if (mounted) {
                                      setState(() {
                                        _isLoved = !_isLoved;
                                      });
                                    }
                                  } catch (_) {
                                    if (mounted) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Gagal update like')),
                                        );
                                      }
                                    }
                                  }
                                },
                                borderRadius: BorderRadius.circular(18),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isLoved
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: _isLoved
                                            ? const Color(0xFFFF5F5F)
                                            : Colors.white70,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _likeCount > 999 ? '999+' : '$_likeCount',
                                        style: const TextStyle(
                                          color: Color(0xFFAAAAAA),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          height: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  final newsItem = NewsItem(
                                    id: _itemId,
                                    title: widget.title,
                                    category: widget.category,
                                    date: widget.date,
                                    imageUrl: widget.imageUrl,
                                  );

                                  if (_isSaved) {
                                    _bookmarkService.removeBookmark(_itemId);
                                  } else {
                                    _bookmarkService.addBookmark(newsItem);
                                  }

                                  if (mounted) {
                                    setState(() {
                                      _isSaved = !_isSaved;
                                    });
                                  }
                                },
                                borderRadius: BorderRadius.circular(18),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    _isSaved
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    color: _isSaved
                                        ? const Color(0xFFFECF06)
                                        : Colors.white70,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.38,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_paragraphs.isEmpty)
                            Text(
                              widget.description,
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                height: 1.7,
                              ),
                            )
                          else
                            ...List.generate(_paragraphs.length, (index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index == _paragraphs.length - 1
                                      ? 0
                                      : 14,
                                ),
                                child: Text(
                                  _paragraphs[index],
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    height: 1.7,
                                  ),
                                ),
                              );
                            }),
                          const SizedBox(height: 12),
                          Text(
                            'Last Update $relativeUpdateText',
                            style: const TextStyle(
                              color: Color(0xFFAAAAAA),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Posted by: ${widget.createdBy}',
                            style: const TextStyle(
                              color: Color(0xFFAAAAAA),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showActionBanner)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 44,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: TopSuccessBanner(
                  animation: _actionBannerAnimation,
                  text: _actionBannerText,
                  backgroundColor: _actionBannerColor,
                  maxWidth: 260,
                  height: 60,
                  fontSize: 17,
                  iconSize: 19,
                  horizontalMargin: 10,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentBottomTab,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        color: const Color(0xFF4A4A6A),
        alignment: Alignment.center,
        child: const Icon(
          Icons.image,
          color: Colors.white30,
          size: 44,
        ),
      );
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return WebSafeNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFF4A4A6A),
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_not_supported,
            color: Colors.white30,
            size: 44,
          ),
        );
      },
    );
  }
}
