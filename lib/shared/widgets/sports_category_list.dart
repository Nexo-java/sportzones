import 'package:flutter/material.dart';

class SportsCategory {
  const SportsCategory({required this.name, required this.icon});

  final String name;
  final IconData icon;
}

class SportsCategoryList extends StatefulWidget {
  const SportsCategoryList({
    super.key,
    this.onCategorySelected,
    this.initialSelectedIndex,
  });

  final ValueChanged<SportsCategory>? onCategorySelected;
  final int? initialSelectedIndex;

  static const List<SportsCategory> categories = [
    SportsCategory(name: 'Badminton', icon: Icons.sports_tennis),
    SportsCategory(name: 'Soccer', icon: Icons.sports_soccer),
    SportsCategory(name: 'Basketball', icon: Icons.sports_basketball),
    SportsCategory(name: 'Volly', icon: Icons.sports_volleyball),
  ];

  @override
  State<SportsCategoryList> createState() => _SportsCategoryListState();
}

class _SportsCategoryListState extends State<SportsCategoryList> {
  static const _selectedColor = Color(0xFFD9D9D9);
  static const _itemMinWidth = 150.0;
  static const _itemMaxWidth = 180.0;
  static const _itemHeight = 40.0;

  int? _selectedIndex;
  int? _pressedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _resolveSelectedIndex(widget.initialSelectedIndex);
  }

  @override
  void didUpdateWidget(covariant SportsCategoryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelectedIndex != widget.initialSelectedIndex) {
      setState(() {
        _selectedIndex = _resolveSelectedIndex(widget.initialSelectedIndex);
      });
    }
  }

  int? _resolveSelectedIndex(int? index) {
    if (index == null) {
      return null;
    }

    final maxIndex = SportsCategoryList.categories.length - 1;
    return index.clamp(0, maxIndex);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final itemWidth = (screenWidth * 0.34).clamp(_itemMinWidth, _itemMaxWidth);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(SportsCategoryList.categories.length, (index) {
          final category = SportsCategoryList.categories[index];
          final isSelected = _selectedIndex != null && _selectedIndex == index;
          final isPressed = _pressedIndex == index;

          return Padding(
            padding: EdgeInsets.only(
              right: index == SportsCategoryList.categories.length - 1 ? 0 : 8,
            ),
            child: GestureDetector(
              onTapDown: (_) {
                setState(() => _pressedIndex = index);
              },
              onTapCancel: () {
                setState(() => _pressedIndex = null);
              },
              onTapUp: (_) {
                setState(() => _pressedIndex = null);
              },
              onTap: () {
                setState(() => _selectedIndex = index);
                widget.onCategorySelected?.call(category);
              },
              child: AnimatedScale(
                scale: isPressed ? 0.97 : 1,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: itemWidth,
                  height: _itemHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? _selectedColor : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        category.icon,
                        size: 28,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}