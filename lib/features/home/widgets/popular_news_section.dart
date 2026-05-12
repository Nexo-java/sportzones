import 'package:flutter/material.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../authentication/models/news_model.dart';

import 'popular_news_card.dart';

typedef PopularNewsTap = void Function(SportModel newsItem);

class PopularNewsSection extends StatelessWidget {
  const PopularNewsSection({
    super.key,
    required this.newsItems,
    this.onNewsTap,
  });

  static const double _horizontalInset = 16;
  final List<SportModel> newsItems;
  final PopularNewsTap? onNewsTap;

  @override
  Widget build(BuildContext context) {
    final scale = ResponsiveLayout.scale(context, min: 0.9, max: 1.08);
    final sectionHeight = (236 * scale).clamp(214.0, 248.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: _horizontalInset),
          child: Row(
            children: [
              Icon(
                Icons.whatshot,
                color: Colors.white,
                size: 22,
              ),
              SizedBox(width: 6),
              Text(
                'Popular News',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12 * scale),
        SizedBox(
          height: sectionHeight,
          child: newsItems.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada berita populer',
                    style: TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : ListView.separated(
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.only(left: _horizontalInset, right: 6),
                  scrollDirection: Axis.horizontal,
                  itemCount: newsItems.length,
                  separatorBuilder: (context, index) => SizedBox(width: 12 * scale),
                  itemBuilder: (context, index) {
                    final item = newsItems[index];
                    return PopularNewsCard(
                      title: item.title,
                      date: item.date,
                      imageUrl: item.imageUrl,
                      onTap: () {
                        onNewsTap?.call(item);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
