import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/app_theme.dart';
import '../../main.dart';
import '../../state/auth_state.dart';
import '../categories/haircut_page.dart';
import '../categories/beard_page.dart';
import '../categories/facial_page.dart';
import '../categories/nails_page.dart';
import '../categories/hair_color_page.dart';
import '../categories/makeup_page.dart';
import '../categories/shave_page.dart';
import '../categories/grooming_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  LatLng? _userLocation;
  final MapController _mapController = MapController();

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchLocation();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  Future<void> _fetchLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission permanently denied');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (mounted) {
        setState(() {
          _userLocation = LatLng(pos.latitude, pos.longitude);
        });
        _mapController.move(_userLocation!, 14);
      }
    } catch (e) {
      debugPrint('Location error: $e');
      // Try last known position as fallback
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null && mounted) {
          setState(() {
            _userLocation = LatLng(last.latitude, last.longitude);
          });
          _mapController.move(_userLocation!, 14);
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;
    // Header fully collapses after scrolling 100px
    final collapseProgress = (_scrollOffset / 100).clamp(0.0, 1.0);
    final headerOpacity = 1.0 - collapseProgress;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Space for the header
                SizedBox(height: topPadding + 100),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    'Hello, Guest 👋',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                _buildSearchBar(context),
                _buildMapWidget(context),
                _buildCategories(context),
                _buildPopularSalons(context),
                _buildNearbySalons(context),
                _buildStyleTips(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Header that fades out on scroll
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(headerOpacity),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28 * headerOpacity),
                  bottomRight: Radius.circular(28 * headerOpacity),
                ),
              ),
              padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Full header content — fades out
                  Opacity(
                    opacity: headerOpacity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(
                              Icons.my_location,
                              color: AppColors.accent,
                              size: 28,
                            ),
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Style',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Now',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accent,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isDark
                                        ? Icons.light_mode_outlined
                                        : Icons.dark_mode_outlined,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    themeNotifier.value = isDark
                                        ? ThemeMode.light
                                        : ThemeMode.dark;
                                  },
                                ),
                                Stack(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.notifications_outlined,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                                      onPressed: () {},
                                    ),
                                    Positioned(
                                      right: 10,
                                      top: 10,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.accent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  // Watermark — fades IN as header fades out
                  Opacity(
                    opacity: collapseProgress,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Style',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.3),
                                letterSpacing: 1,
                              ),
                            ),
                            TextSpan(
                              text: 'Now',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent.withOpacity(0.3),
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final hintColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.5);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Search salons, services, or stylists...',
            hintStyle: TextStyle(color: hintColor, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: AppColors.accent),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildMapWidget(BuildContext context) {
    final center = _userLocation ?? const LatLng(6.9271, 79.8612);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🗺️ Salons Near You',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 220,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(initialCenter: center, initialZoom: 14),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.style_now',
                      ),
                      MarkerLayer(markers: _buildMarkers()),
                    ],
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => _openFullScreenMap(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _fetchLocation,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers() {
    return [
      if (_userLocation != null)
        Marker(
          point: _userLocation!,
          width: 48,
          height: 48,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 6),
              ],
            ),
            child: const Icon(
              Icons.person_pin_circle,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ..._salonMarkers.map(
        (s) => Marker(
          point: s['point'] as LatLng,
          width: 120,
          height: 48,
          child: Column(
            children: [
              const Icon(Icons.content_cut, color: AppColors.accent, size: 22),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  s['name'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  void _openFullScreenMap(BuildContext context) {
    final center = _userLocation ?? const LatLng(6.9271, 79.8612);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Stack(
            children: [
              FlutterMap(
                options: MapOptions(initialCenter: center, initialZoom: 14),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.style_now',
                  ),
                  MarkerLayer(markers: _buildMarkers()),
                ],
              ),
              Positioned(
                top: 0,
                left: 16,
                child: SafeArea(
                  child: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final categories = [
      {'icon': '✂️', 'label': 'Haircut', 'page': const HaircutPage()},
      {'icon': '🧔', 'label': 'Beard', 'page': const BeardPage()},
      {'icon': '💆', 'label': 'Facial', 'page': const FacialPage()},
      {'icon': '💅', 'label': 'Nails', 'page': const NailsPage()},
      {'icon': '🎨', 'label': 'Hair Color', 'page': const HairColorPage()},
      {'icon': '💄', 'label': 'Makeup', 'page': const MakeupPage()},
      {'icon': '🪒', 'label': 'Shave', 'page': const ShavePage()},
      {'icon': '💪', 'label': 'Grooming', 'page': const GroomingPage()},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 90,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final cat = categories[index];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => cat['page'] as Widget),
              ),
              child: Column(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        cat['icon'] as String,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cat['label'] as String,
                    style: TextStyle(fontSize: 11, color: textColor),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPopularSalons(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '⭐ Popular Salons Near You',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _salonData.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                _buildSalonCard(context, _salonData[index], horizontal: true),
          ),
        ),
      ],
    );
  }

  Widget _buildNearbySalons(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '📍 Nearby Salons',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _salonData.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              _buildSalonCard(context, _salonData[index], horizontal: false),
        ),
      ],
    );
  }

  Widget _buildSalonCard(
    BuildContext context,
    Map<String, dynamic> salon, {
    required bool horizontal,
  }) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    return Container(
      width: horizontal ? 180 : double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: horizontal
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: Container(
                    height: 100,
                    color: salon['color'] as Color,
                    child: const Center(
                      child: Icon(
                        Icons.content_cut,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: _salonCardContent(salon, textColor, subColor),
                ),
              ],
            )
          : Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(14),
                  ),
                  child: Container(
                    width: 90,
                    height: 90,
                    color: salon['color'] as Color,
                    child: const Center(
                      child: Icon(
                        Icons.content_cut,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: _salonCardContent(salon, textColor, subColor),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _salonCardContent(
    Map<String, dynamic> salon,
    Color textColor,
    Color subColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          salon['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.star, color: AppColors.star, size: 14),
            Text(
              ' ${salon['rating']}',
              style: TextStyle(fontSize: 12, color: textColor),
            ),
            const SizedBox(width: 8),
            Icon(Icons.location_on, color: subColor, size: 14),
            Text(
              ' ${salon['distance']}',
              style: TextStyle(fontSize: 12, color: subColor),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'From Rs. ${salon['price']}',
          style: TextStyle(fontSize: 12, color: subColor),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 28,
          child: ElevatedButton(
            onPressed: () => guardAction(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Book Now',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyleTips(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    final tips = [
      {
        'title': '5 Tips for Healthy Hair',
        'subtitle': 'Keep your hair strong and shiny',
      },
      {
        'title': 'Best Beard Styles 2025',
        'subtitle': 'Find the style that suits your face',
      },
      {
        'title': 'Skin Care for Everyone',
        'subtitle': 'Simple routines for all skin types',
      },
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '💡 Style Tips',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: tips.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tips[index]['title']!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: textColor,
                          ),
                        ),
                        Text(
                          tips[index]['subtitle']!,
                          style: TextStyle(fontSize: 12, color: subColor),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 14, color: subColor),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

final List<Map<String, dynamic>> _salonMarkers = [
  {'name': 'Golden Scissors', 'point': LatLng(6.9310, 79.8580)},
  {'name': 'The Barber Co.', 'point': LatLng(6.9250, 79.8650)},
  {'name': 'Style Hub', 'point': LatLng(6.9290, 79.8700)},
];

final List<Map<String, dynamic>> _salonData = [
  {
    'name': 'Golden Scissors',
    'rating': '4.7',
    'distance': '1.2 km',
    'price': '1200',
    'color': AppColors.primary,
  },
  {
    'name': 'The Barber Co.',
    'rating': '4.5',
    'distance': '2.0 km',
    'price': '1500',
    'color': AppColors.secondary,
  },
  {
    'name': 'Style Hub',
    'rating': '4.8',
    'distance': '0.8 km',
    'price': '1000',
    'color': AppColors.accent,
  },
];
