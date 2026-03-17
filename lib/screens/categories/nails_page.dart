import 'package:flutter/material.dart';
import 'category_page.dart';

class NailsPage extends StatelessWidget {
  const NailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryPage(
      emoji: '💅',
      title: 'Nails',
      description: 'Manicure, pedicure and nail art services',
      options: [
        {'name': 'Basic Manicure', 'duration': '30 min', 'price': 'Rs. 800'},
        {'name': 'Gel Manicure', 'duration': '45 min', 'price': 'Rs. 1400'},
        {'name': 'Basic Pedicure', 'duration': '40 min', 'price': 'Rs. 1000'},
        {'name': 'Nail Art', 'duration': '60 min', 'price': 'Rs. 1800'},
        {'name': 'Full Set Acrylic', 'duration': '90 min', 'price': 'Rs. 2500'},
      ],
    );
  }
}
