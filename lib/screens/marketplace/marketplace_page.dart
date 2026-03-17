import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/auth_state.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  int _selectedCategory = 0;

  static const _categories = [
    {'icon': '🛍️', 'label': 'All'},
    {'icon': '🧴', 'label': 'Hair Care'},
    {'icon': '💄', 'label': 'Makeup'},
    {'icon': '💅', 'label': 'Nails'},
    {'icon': '🪒', 'label': 'Shaving'},
    {'icon': '🧼', 'label': 'Skin Care'},
    {'icon': '🪑', 'label': 'Equipment'},
  ];

  static final _products = [
    _Product(
      emoji: '🧴',
      name: 'Kerastase Hair Treatment',
      brand: 'Kerastase',
      price: 'Rs. 3,200',
      location: 'Colombo 3',
      timeAgo: '2 hours ago',
      condition: 'New',
      saved: false,
    ),
    _Product(
      emoji: '🎨',
      name: 'Garnier Hair Dye Kit — Ash Blonde',
      brand: 'Garnier',
      price: 'Rs. 1,100',
      location: 'Nugegoda',
      timeAgo: '5 hours ago',
      condition: 'New',
      saved: false,
    ),
    _Product(
      emoji: '💅',
      name: 'OPI Nail Polish Set (12 colors)',
      brand: 'OPI',
      price: 'Rs. 2,400',
      location: 'Dehiwala',
      timeAgo: '1 day ago',
      condition: 'New',
      saved: true,
    ),
    _Product(
      emoji: '🪒',
      name: 'Gillette Fusion Razor Set',
      brand: 'Gillette',
      price: 'Rs. 650',
      location: 'Maharagama',
      timeAgo: '2 days ago',
      condition: 'New',
      saved: false,
    ),
    _Product(
      emoji: '🧼',
      name: 'Cetaphil Gentle Face Wash',
      brand: 'Cetaphil',
      price: 'Rs. 1,500',
      location: 'Colombo 7',
      timeAgo: '3 days ago',
      condition: 'New',
      saved: false,
    ),
    _Product(
      emoji: '🪑',
      name: 'Professional Salon Chair',
      brand: 'SalonPro',
      price: 'Rs. 45,000',
      location: 'Kandy',
      timeAgo: '1 week ago',
      condition: 'Used — Good',
      saved: false,
    ),
    _Product(
      emoji: '💆',
      name: 'Pantene Pro-V Shampoo 1L',
      brand: 'Pantene',
      price: 'Rs. 850',
      location: 'Gampaha',
      timeAgo: '4 hours ago',
      condition: 'New',
      saved: false,
    ),
    _Product(
      emoji: '💄',
      name: 'MAC Lipstick Collection',
      brand: 'MAC',
      price: 'Rs. 4,800',
      location: 'Colombo 5',
      timeAgo: '6 hours ago',
      condition: 'New',
      saved: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Marketplace',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => guardAction(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.add,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Sell',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const TextField(
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search Marketplace...',
                        hintStyle: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Category chips ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final selected = _selectedCategory == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.accent
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            _categories[i]['icon']!,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _categories[i]['label']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: selected ? AppColors.primary : textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Today's picks label ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                "Today's picks",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ),

          // ── Product grid ─────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ProductCard(
                  product: _products[index],
                  onSaveToggle: () => setState(() {
                    _products[index].saved = !_products[index].saved;
                  }),
                ),
                childCount: _products.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.72,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Product Card ──────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final _Product product;
  final VoidCallback onSaveToggle;

  const _ProductCard({required this.product, required this.onSaveToggle});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subColor = textColor.withValues(alpha: 0.55);

    return GestureDetector(
      onTap: () => _showProductDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: Container(
                    height: 130,
                    width: double.infinity,
                    color: AppColors.primary.withValues(alpha: 0.12),
                    child: Center(
                      child: Text(
                        product.emoji,
                        style: const TextStyle(fontSize: 56),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      if (!guardAction(context)) return;
                      onSaveToggle();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        product.saved ? Icons.bookmark : Icons.bookmark_border,
                        color: product.saved ? AppColors.accent : Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: product.condition.startsWith('Used')
                          ? Colors.orange.withValues(alpha: 0.85)
                          : Colors.green.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.condition,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.price,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 11, color: subColor),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          product.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: subColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.timeAgo,
                    style: TextStyle(fontSize: 10, color: subColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetail(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subColor = textColor.withValues(alpha: 0.55);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: subColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: Center(
                      child: Text(
                        product.emoji,
                        style: const TextStyle(fontSize: 80),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  product.price,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: product.condition.startsWith('Used')
                            ? Colors.orange.withValues(alpha: 0.15)
                            : Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.condition,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: product.condition.startsWith('Used')
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.location_on, size: 14, color: subColor),
                    Text(
                      product.location,
                      style: TextStyle(fontSize: 13, color: subColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: Text(
                        product.brand[0],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.brand,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'Listed ${product.timeAgo}',
                          style: TextStyle(fontSize: 11, color: subColor),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          guardAction(context);
                        },
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: const Text('Message'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          guardAction(context);
                        },
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        label: const Text('Add to Cart'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          side: const BorderSide(color: AppColors.accent),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
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
      ),
    );
  }
}

// ── Data model ─────────────────────────────────────────────────────────────

class _Product {
  final String emoji;
  final String name;
  final String brand;
  final String price;
  final String location;
  final String timeAgo;
  final String condition;
  bool saved;

  _Product({
    required this.emoji,
    required this.name,
    required this.brand,
    required this.price,
    required this.location,
    required this.timeAgo,
    required this.condition,
    required this.saved,
  });
}
