import 'package:flutter/material.dart';

import '../models/news_model.dart';
import 'latest_news_card.dart';

typedef LatestNewsTap = void Function({
  required String title,
  required String date,
  required String imageUrl,
  required String description,
  required String category,
});

class LatestNewsSection extends StatelessWidget {
  const LatestNewsSection({
    super.key,
    required this.newsItems,
    this.onNewsTap,
  });

  static const double _horizontalInset = 16;
  final List<NewsModel> newsItems;
  final LatestNewsTap? onNewsTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.article_outlined,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 6),
              Text(
                'Latest News',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: List.generate(newsItems.length, (index) {
              final item = newsItems[index];
              return LatestNewsCard(
                title: item.title,
                category: item.category,
                date: item.date,
                imageUrl: item.imageUrl,
                onTap: () {
                  onNewsTap?.call(
                    title: item.title,
                    date: item.date,
                    imageUrl: item.imageUrl,
                    description: item.description,
                    category: item.category,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
