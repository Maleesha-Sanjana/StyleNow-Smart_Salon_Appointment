import 'package:flutter/material.dart';
import 'category_page.dart';

class HairColorPage extends StatelessWidget {
  const HairColorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryPage(
      emoji: '🎨',
      title: 'Hair Color',
      description: 'Transform your look with vibrant hair coloring',
      options: [
        {'name': 'Full Color', 'duration': '90 min', 'price': 'Rs. 3500'},
        {'name': 'Highlights', 'duration': '120 min', 'price': 'Rs. 4500'},
        {'name': 'Balayage', 'duration': '150 min', 'price': 'Rs. 6000'},
        {'name': 'Root Touch-Up', 'duration': '60 min', 'price': 'Rs. 2000'},
        {'name': 'Ombre', 'duration': '120 min', 'price': 'Rs. 5000'},
      ],
    );
  }
}
