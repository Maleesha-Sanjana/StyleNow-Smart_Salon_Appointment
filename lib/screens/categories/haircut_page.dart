import 'package:flutter/material.dart';
import 'category_page.dart';

class HaircutPage extends StatelessWidget {
  const HaircutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryPage(
      emoji: '✂️',
      title: 'Haircut',
      description: 'Professional cuts for every style and length',
      options: [
        {'name': 'Classic Cut', 'duration': '30 min', 'price': 'Rs. 800'},
        {'name': 'Fade Cut', 'duration': '45 min', 'price': 'Rs. 1200'},
        {'name': 'Layered Cut', 'duration': '60 min', 'price': 'Rs. 1500'},
        {'name': 'Kids Cut', 'duration': '20 min', 'price': 'Rs. 600'},
        {'name': 'Trim & Style', 'duration': '40 min', 'price': 'Rs. 1000'},
      ],
    );
  }
}
