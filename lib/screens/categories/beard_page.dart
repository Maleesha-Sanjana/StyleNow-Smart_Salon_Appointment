import 'package:flutter/material.dart';
import 'category_page.dart';

class BeardPage extends StatelessWidget {
  const BeardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryPage(
      emoji: '🧔',
      title: 'Beard',
      description: 'Shape, trim and style your beard perfectly',
      options: [
        {'name': 'Beard Trim', 'duration': '20 min', 'price': 'Rs. 500'},
        {'name': 'Beard Shape', 'duration': '30 min', 'price': 'Rs. 700'},
        {'name': 'Full Beard Style', 'duration': '45 min', 'price': 'Rs. 1000'},
        {'name': 'Beard & Mustache', 'duration': '35 min', 'price': 'Rs. 900'},
        {'name': 'Beard Color', 'duration': '50 min', 'price': 'Rs. 1400'},
      ],
    );
  }
}
