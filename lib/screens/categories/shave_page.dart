import 'package:flutter/material.dart';
import 'category_page.dart';

class ShavePage extends StatelessWidget {
  const ShavePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryPage(
      emoji: '🪒',
      title: 'Shave',
      description: 'Classic and modern shaving services',
      options: [
        {'name': 'Classic Shave', 'duration': '20 min', 'price': 'Rs. 500'},
        {'name': 'Hot Towel Shave', 'duration': '35 min', 'price': 'Rs. 900'},
        {
          'name': 'Straight Razor Shave',
          'duration': '40 min',
          'price': 'Rs. 1200',
        },
        {'name': 'Head Shave', 'duration': '30 min', 'price': 'Rs. 800'},
        {'name': 'Shave & Facial', 'duration': '60 min', 'price': 'Rs. 1800'},
      ],
    );
  }
}
