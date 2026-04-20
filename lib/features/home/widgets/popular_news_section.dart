import 'package:flutter/material.dart';
import '../../../core/utils/responsive_layout.dart';

import 'popular_news_card.dart';

typedef PopularNewsTap = void Function({
  required String title,
  required String date,
  String? imageUrl,
});

class PopularNewsSection extends StatelessWidget {
  const PopularNewsSection({
    super.key,
    this.onNewsTap,
  });

  static const double _horizontalInset = 16;
  final PopularNewsTap? onNewsTap;

  @override
  Widget build(BuildContext context) {
    final scale = ResponsiveLayout.scale(context, min: 0.9, max: 1.08);
    final sectionHeight = (236 * scale).clamp(214.0, 248.0).toDouble();

    final popularNews = List<Map<String, String?>>.generate(10, (index) {
      return {
        'title': _dummyTitles[index % _dummyTitles.length],
        'date': '12/01/0$index',
        'image': null,
      };
    });

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
                size: 20,
              ),
              SizedBox(width: 6),
              Text(
                'Popular News',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12 * scale),
        SizedBox(
          height: sectionHeight,
          child: ListView.separated(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.only(left: _horizontalInset, right: 6),
            scrollDirection: Axis.horizontal,
            itemCount: popularNews.length,
            separatorBuilder: (context, index) => SizedBox(width: 12 * scale),
            itemBuilder: (context, index) {
              final item = popularNews[index];
              return PopularNewsCard(
                title: item['title'] ?? '',
                date: item['date'] ?? '',
                imageUrl: item['image'],
                onTap: () {
                  onNewsTap?.call(
                    title: item['title'] ?? '',
                    date: item['date'] ?? '',
                    imageUrl: item['image'],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

const _dummyTitles = [
  'Manchester is red! Manchester is back with big momentum',
  'Indonesia has already for Indonesia in this major event',
  'Brazil keeps pushing after dramatic late comeback win',
  'The derby turns chaotic after a stunning extra-time goal',
  'Final set thriller ends with unbelievable rally sequence',
  'New strategy changes the game for underdog contenders',
  'Captain returns and instantly changes team chemistry',
  'Fans celebrate historic result after years of waiting',
  'Rival teams clash again in the most heated matchup',
  'Coach explains tactical tweaks behind recent victories',
];
