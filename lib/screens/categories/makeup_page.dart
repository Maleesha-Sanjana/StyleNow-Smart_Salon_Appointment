import 'package:flutter/material.dart';
import 'category_page.dart';

class MakeupPage extends StatelessWidget {
  const MakeupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryPage(
      emoji: '💄',
      title: 'Makeup',
      description: 'Professional makeup for every occasion',
      options: [
        {'name': 'Everyday Makeup', 'duration': '45 min', 'price': 'Rs. 2000'},
        {'name': 'Party Makeup', 'duration': '60 min', 'price': 'Rs. 3500'},
        {'name': 'Bridal Makeup', 'duration': '120 min', 'price': 'Rs. 8000'},
        {'name': 'Eye Makeup', 'duration': '30 min', 'price': 'Rs. 1200'},
        {'name': 'Airbrush Makeup', 'duration': '75 min', 'price': 'Rs. 5000'},
      ],
    );
  }
}
