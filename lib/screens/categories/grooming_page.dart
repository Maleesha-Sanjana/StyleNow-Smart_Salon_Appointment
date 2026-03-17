import 'package:flutter/material.dart';
import 'category_page.dart';

class GroomingPage extends StatelessWidget {
  const GroomingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryPage(
      emoji: '💪',
      title: 'Grooming',
      description: 'Complete grooming packages for a polished look',
      options: [
        {'name': 'Basic Grooming', 'duration': '45 min', 'price': 'Rs. 1500'},
        {'name': 'Full Grooming', 'duration': '90 min', 'price': 'Rs. 3000'},
        {'name': 'Eyebrow Shaping', 'duration': '20 min', 'price': 'Rs. 600'},
        {'name': 'Ear & Nose Trim', 'duration': '15 min', 'price': 'Rs. 400'},
        {'name': 'Premium Package', 'duration': '120 min', 'price': 'Rs. 4500'},
      ],
    );
  }
}
