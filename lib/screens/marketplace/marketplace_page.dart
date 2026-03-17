import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/auth_state.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key});

  static const _products = [
    {
      'icon': '🧴',
      'name': 'Hair Shampoo',
      'brand': 'Pantene',
      'price': 'Rs. 850',
    },
    {
      'icon': '💊',
      'name': 'Hair Treatment',
      'brand': 'Kerastase',
      'price': 'Rs. 3200',
    },
    {
      'icon': '🎨',
      'name': 'Hair Dye Kit',
      'brand': 'Garnier',
      'price': 'Rs. 1100',
    },
    {
      'icon': '💅',
      'name': 'Nail Polish Set',
      'brand': 'OPI',
      'price': 'Rs. 2400',
    },
    {
      'icon': '🪒',
      'name': 'Razor Set',
      'brand': 'Gillette',
      'price': 'Rs. 650',
    },
    {
      'icon': '🧼',
      'name': 'Face Wash',
      'brand': 'Cetaphil',
      'price': 'Rs. 1500',
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
                  Icons.shopping_bag_outlined,
                  color: AppColors.accent,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Marketplace',
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
                childAspectRatio: 0.85,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final p = _products[index];
                return Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6),
                    ],
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          p['icon']!,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        p['name']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: textColor,
                        ),
                      ),
                      Text(
                        p['brand']!,
                        style: TextStyle(
                          fontSize: 11,
                          color: textColor.withOpacity(0.5),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            p['price']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => guardAction(context),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.add_shopping_cart,
                                color: AppColors.primary,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
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
