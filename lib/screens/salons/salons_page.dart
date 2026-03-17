import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/auth_state.dart';

class SalonsPage extends StatefulWidget {
  const SalonsPage({super.key});

  @override
  State<SalonsPage> createState() => _SalonsPageState();
}

class _SalonsPageState extends State<SalonsPage> {
  final _salons = [
    {
      'name': 'Golden Scissors',
      'rating': '4.7',
      'distance': '1.2 km',
      'price': '1200',
      'tag': 'Popular',
    },
    {
      'name': 'The Barber Co.',
      'rating': '4.5',
      'distance': '2.0 km',
      'price': '1500',
      'tag': 'Trending',
    },
    {
      'name': 'Style Hub',
      'rating': '4.8',
      'distance': '0.8 km',
      'price': '1000',
      'tag': 'Nearest',
    },
    {
      'name': 'Glamour Studio',
      'rating': '4.6',
      'distance': '3.1 km',
      'price': '2000',
      'tag': 'Top Rated',
    },
    {
      'name': 'Royal Cuts',
      'rating': '4.3',
      'distance': '1.8 km',
      'price': '900',
      'tag': '',
    },
    {
      'name': 'Beauty Lounge',
      'rating': '4.9',
      'distance': '0.5 km',
      'price': '1800',
      'tag': 'Popular',
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
                const Icon(Icons.store, color: AppColors.accent, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Salons',
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
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _salons.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final s = _salons[index];
                return Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(16),
                        ),
                        child: Container(
                          width: 90,
                          height: 90,
                          color: AppColors.primary,
                          child: const Center(
                            child: Icon(
                              Icons.content_cut,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      s['name']!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                  if (s['tag']!.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent.withOpacity(
                                          0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        s['tag']!,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.accent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: AppColors.star,
                                    size: 14,
                                  ),
                                  Text(
                                    ' ${s['rating']}  ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textColor,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.location_on,
                                    color: AppColors.accent,
                                    size: 14,
                                  ),
                                  Text(
                                    ' ${s['distance']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textColor.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'From Rs. ${s['price']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textColor.withOpacity(0.6),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 28,
                                    child: ElevatedButton(
                                      onPressed: () => guardAction(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.accent,
                                        foregroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Book',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
