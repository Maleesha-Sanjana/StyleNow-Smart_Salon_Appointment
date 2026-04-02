import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SubPageScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const SubPageScaffold({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white)),
      ),
      body: body,
    );
  }
}

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  Color _backgroundColor() {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'processing':
        return Colors.orange.shade200;
      case 'completed':
      case 'delivered':
        return Colors.green.shade200;
      case 'cancelled':
        return Colors.red.shade200;
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
