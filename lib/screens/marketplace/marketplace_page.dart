import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Marketplace'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Marketplace coming soon',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
