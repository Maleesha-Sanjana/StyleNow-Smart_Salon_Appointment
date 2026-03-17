import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  static const _services = [
    {
      'icon': '✂️',
      'name': 'Haircut',
      'price': 'From Rs. 800',
      'duration': '30 min',
    },
    {
      'icon': '🎨',
      'name': 'Hair Coloring',
      'price': 'From Rs. 2500',
      'duration': '90 min',
    },
    {
      'icon': '💆',
      'name': 'Facial',
      'price': 'From Rs. 1500',
      'duration': '60 min',
    },
    {
      'icon': '🧔',
      'name': 'Beard Trimming',
      'price': 'From Rs. 500',
      'duration': '20 min',
    },
    {
      'icon': '💄',
      'name': 'Bridal Makeup',
      'price': 'From Rs. 8000',
      'duration': '120 min',
    },
    {
      'icon': '💅',
      'name': 'Nail Art',
      'price': 'From Rs. 1200',
      'duration': '45 min',
    },
    {
      'icon': '🪒',
      'name': 'Shave',
      'price': 'From Rs. 400',
      'duration': '15 min',
    },
    {
      'icon': '💪',
      'name': 'Hair Treatment',
      'price': 'From Rs. 3000',
      'duration': '75 min',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final cardColor = Theme.of(context).cardColor;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 20),
            child: Row(
              children: [
                const Icon(
                  Icons.content_cut,
                  color: AppColors.accent,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Services',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: _services.length,
              itemBuilder: (context, index) {
                final s = _services[index];
                return Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s['icon']!, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        s['name']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s['price']!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.accent,
                        ),
                      ),
                      Text(
                        s['duration']!,
                        style: TextStyle(
                          fontSize: 11,
                          color: textColor.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
