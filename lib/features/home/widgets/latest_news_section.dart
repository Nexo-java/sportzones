import 'package:flutter/material.dart';

import '../../authentication/models/sport_model.dart';
import 'latest_news_card.dart';

typedef LatestNewsTap = void Function(SportModel newsItem);

class LatestNewsSection extends StatelessWidget {
  const LatestNewsSection({
    super.key,
    required this.newsItems,
    this.onNewsTap,
    this.showHeader = true,
  });

  static const double _horizontalInset = 16;
  final List<SportModel> newsItems;
  final LatestNewsTap? onNewsTap;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            const Row(
              children: [
                Icon(Icons.article_outlined, color: Colors.white, size: 22),
                SizedBox(width: 6),
                Text(
                  'Latest News',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Column(
            children: List.generate(newsItems.length, (index) {
              final item = newsItems[index];
              return LatestNewsCard(
                newsId: item.idBerita,
                title: item.title,
                category: item.category,
                date: item.date,
                imageUrl: item.imageUrl,
                onTap: () {
                  onNewsTap?.call(item);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
