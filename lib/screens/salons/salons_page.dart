import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/auth_state.dart';

// ── Data ───────────────────────────────────────────────────────────────────

class _Salon {
  final String name;
  final String tagline;
  final double rating;
  final int reviews;
  final String distance;
  final String price;
  final String tag;
  final String emoji;
  final List<String> services;
  final Color coverColor;
  bool saved;

  _Salon({
    required this.name,
    required this.tagline,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.price,
    required this.tag,
    required this.emoji,
    required this.services,
    required this.coverColor,
    this.saved = false,
  });
}

final _allSalons = [
  _Salon(
    name: 'Golden Scissors',
    tagline: 'Premium cuts & styling',
    rating: 4.7,
    reviews: 312,
    distance: '1.2 km',
    price: '1,200',
    tag: 'Popular',
    emoji: '✂️',
    services: ['Haircut', 'Beard', 'Color'],
    coverColor: const Color(0xFF5C4033),
  ),
  _Salon(
    name: 'Beauty Lounge',
    tagline: 'Luxury beauty experience',
    rating: 4.9,
    reviews: 528,
    distance: '0.5 km',
    price: '1,800',
    tag: 'Top Rated',
    emoji: '💄',
    services: ['Makeup', 'Facial', 'Nails'],
    coverColor: const Color(0xFF880E4F),
  ),
  _Salon(
    name: 'Style Hub',
    tagline: 'Modern styles for everyone',
    rating: 4.8,
    reviews: 410,
    distance: '0.8 km',
    price: '1,000',
    tag: 'Nearest',
    emoji: '💆',
    services: ['Massage', 'Hair Spa', 'Waxing'],
    coverColor: const Color(0xFF1A237E),
  ),
  _Salon(
    name: 'The Barber Co.',
    tagline: 'Classic barbershop vibes',
    rating: 4.5,
    reviews: 198,
    distance: '2.0 km',
    price: '1,500',
    tag: 'Trending',
    emoji: '🧔',
    services: ['Shave', 'Fade', 'Beard Trim'],
    coverColor: const Color(0xFF1B5E20),
  ),
  _Salon(
    name: 'Glamour Studio',
    tagline: 'Where glamour meets art',
    rating: 4.6,
    reviews: 275,
    distance: '3.1 km',
    price: '2,000',
    tag: 'Premium',
    emoji: '💅',
    services: ['Nail Art', 'Lashes', 'Brows'],
    coverColor: const Color(0xFF4A148C),
  ),
  _Salon(
    name: 'Royal Cuts',
    tagline: 'Affordable quality cuts',
    rating: 4.3,
    reviews: 143,
    distance: '1.8 km',
    price: '900',
    tag: '',
    emoji: '👑',
    services: ['Haircut', 'Styling', 'Color'],
    coverColor: const Color(0xFF37474F),
  ),
];

const _categories = ['All', 'Hair', 'Makeup', 'Nails', 'Spa', 'Barber'];

// ── Page ───────────────────────────────────────────────────────────────────

class SalonsPage extends StatefulWidget {
  const SalonsPage({super.key});

  @override
  State<SalonsPage> createState() => _SalonsPageState();
}

class _SalonsPageState extends State<SalonsPage> {
  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _sortBy = 'Rating';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_Salon> get _filtered {
    var list = List<_Salon>.from(_allSalons);
    if (_searchQuery.isNotEmpty) {
      list = list
          .where(
            (s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    if (_sortBy == 'Rating') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortBy == 'Distance') {
      list.sort(
        (a, b) => double.parse(
          a.distance.replaceAll(' km', ''),
        ).compareTo(double.parse(b.distance.replaceAll(' km', ''))),
      );
    } else if (_sortBy == 'Price') {
      list.sort(
        (a, b) => int.parse(
          a.price.replaceAll(',', ''),
        ).compareTo(int.parse(b.price.replaceAll(',', ''))),
      );
    }
    return list;
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sort By',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...['Rating', 'Distance', 'Price'].map(
              (opt) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  opt == 'Rating'
                      ? Icons.star_outline
                      : opt == 'Distance'
                      ? Icons.near_me_outlined
                      : Icons.attach_money,
                  color: AppColors.accent,
                ),
                title: Text(opt),
                trailing: _sortBy == opt
                    ? const Icon(Icons.check_circle, color: AppColors.accent)
                    : null,
                onTap: () {
                  setState(() => _sortBy = opt);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5);
    final textColor = Theme.of(context).colorScheme.onSurface;
    final salons = _filtered;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // ── Header ──
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.location_on,
                                color: AppColors.accent,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Colombo, LK',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.accent,
                                size: 16,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Find Your Salon',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _showSortSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.tune_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _sortBy,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search salons, services...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.accent,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                                onPressed: () => setState(() {
                                  _searchCtrl.clear();
                                  _searchQuery = '';
                                }),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Category Chips ──
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _categories.length,
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final selected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.accent
                            : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [
                                const BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                ),
                              ],
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selected
                              ? AppColors.primary
                              : textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Featured Banner ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: _FeaturedBanner(onBook: () => guardAction(context)),
            ),
          ),

          // ── Section Title ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${salons.length} Salons Near You',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'Sorted by $_sortBy',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Salon Cards ──
          salons.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No salons found',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _SalonCard(
                          salon: salons[i],
                          onSave: () => setState(
                            () => salons[i].saved = !salons[i].saved,
                          ),
                          onBook: () => guardAction(context),
                        ),
                      ),
                      childCount: salons.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

// ── Featured Banner ────────────────────────────────────────────────────────

class _FeaturedBanner extends StatelessWidget {
  final VoidCallback onBook;
  const _FeaturedBanner({required this.onBook});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBook,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF2D2D2D), Color(0xFF5C4033)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -30,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.15),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '✨ FEATURED',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Beauty Lounge',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Icon(Icons.star, color: AppColors.star, size: 13),
                            Text(
                              ' 4.9  ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Icon(
                              Icons.location_on,
                              color: AppColors.accent,
                              size: 13,
                            ),
                            Text(
                              ' 0.5 km',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('💄', style: TextStyle(fontSize: 48)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Salon Card ─────────────────────────────────────────────────────────────

class _SalonCard extends StatelessWidget {
  final _Salon salon;
  final VoidCallback onSave;
  final VoidCallback onBook;

  const _SalonCard({
    required this.salon,
    required this.onSave,
    required this.onBook,
  });

  Color get _tagColor {
    switch (salon.tag) {
      case 'Top Rated':
        return const Color(0xFF1B5E20);
      case 'Popular':
        return const Color(0xFF0D47A1);
      case 'Trending':
        return const Color(0xFFE65100);
      case 'Nearest':
        return const Color(0xFF4A148C);
      case 'Premium':
        return const Color(0xFF880E4F);
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF242424) : Colors.white;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subColor = textColor.withValues(alpha: 0.55);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cover ──
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        salon.coverColor,
                        salon.coverColor.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative pattern
                      Positioned(
                        right: -10,
                        top: -10,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.07),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: -20,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          salon.emoji,
                          style: const TextStyle(fontSize: 56),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Tag badge
              if (salon.tag.isNotEmpty)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _tagColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      salon.tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              // Save button
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: onSave,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      salon.saved ? Icons.bookmark : Icons.bookmark_border,
                      color: salon.saved ? AppColors.accent : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Info ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            salon.name,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            salon.tagline,
                            style: TextStyle(fontSize: 12, color: subColor),
                          ),
                        ],
                      ),
                    ),
                    // Rating pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.star.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.star,
                            size: 16,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            salon.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.star,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Stats row
                Row(
                  children: [
                    Flexible(
                      child: _InfoChip(
                        icon: Icons.location_on_outlined,
                        label: salon.distance,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      flex: 2,
                      child: _InfoChip(
                        icon: Icons.chat_bubble_outline,
                        label: '${salon.reviews} reviews',
                        color: subColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: _InfoChip(
                        icon: Icons.access_time_outlined,
                        label: 'Open',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Services chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: salon.services
                      .map(
                        (s) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            s,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),

                // Price + Book row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Starting from',
                            style: TextStyle(fontSize: 11, color: subColor),
                          ),
                          Text(
                            'Rs. ${salon.price}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: onBook,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Chip ──────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
