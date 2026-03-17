import 'package:flutter/material.dart';
import 'category_page.dart';

class FacialPage extends StatelessWidget {
  const FacialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryPage(
      emoji: '💆',
      title: 'Facial',
      description: 'Rejuvenate your skin with expert facial treatments',
      options: [
        {'name': 'Basic Facial', 'duration': '45 min', 'price': 'Rs. 1500'},
        {'name': 'Deep Cleanse', 'duration': '60 min', 'price': 'Rs. 2000'},
        {
          'name': 'Anti-Aging Facial',
          'duration': '75 min',
          'price': 'Rs. 2800',
        },
        {
          'name': 'Brightening Facial',
          'duration': '60 min',
          'price': 'Rs. 2200',
        },
        {'name': 'Hydrating Facial', 'duration': '50 min', 'price': 'Rs. 1800'},
      ],
    );
  }
}
