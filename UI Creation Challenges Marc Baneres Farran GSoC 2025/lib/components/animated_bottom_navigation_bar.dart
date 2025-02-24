import 'package:flutter/material.dart';

class NavigationItem {
  final Widget icon;
  final String label;
  NavigationItem({required this.icon, required this.label});
}

class AnimatedBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final List<NavigationItem> items;

  const AnimatedBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111111),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final double indicatorWidth = width / items.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: indicatorWidth * selectedIndex,
                bottom: 0,
                child: Container(
                  width: indicatorWidth,
                  height: 4,
                  color: Colors.white,
                ),
              ),
              Row(
                children: items.asMap().entries.map((entry) {
                  int idx = entry.key;
                  NavigationItem item = entry.value;
                  return Expanded(
                    child: InkWell(
                      onTap: () => onTap(idx),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                  Colors.white, BlendMode.srcIn),
                              child: item.icon,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
