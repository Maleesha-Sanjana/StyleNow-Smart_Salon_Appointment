import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'profile_sub_page_helpers.dart';
import '../../theme/app_theme.dart';

class SavedLocationsPage extends StatelessWidget {
  const SavedLocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return SubPageScaffold(
      title: 'Saved Locations',
      body: _SavedLocationsBody(uid: uid),
    );
  }
}

class _SavedLocationsBody extends StatelessWidget {
  final String uid;
  const _SavedLocationsBody({required this.uid});

  CollectionReference get _col =>
      FirebaseFirestore.instance.collection('saved_locations');

  Future<void> _addLocation(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddLocationSheet(uid: uid),
    );
  }

  Future<void> _deleteLocation(
    BuildContext context,
    String docId,
    String label,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Remove Location',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Remove "$label" from saved locations?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _col.doc(docId).delete();
    }
  }

  Future<void> _setDefault(String docId) async {
    // Unset all, then set this one
    final all = await _col
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (final d in all.docs) {
      batch.update(d.reference, {'isDefault': d.id == docId});
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _col
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        return Stack(
          children: [
            docs.isEmpty
                ? _EmptyLocations(onAdd: () => _addLocation(context))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      return _LocationCard(
                        docId: docs[i].id,
                        data: data,
                        onDelete: () => _deleteLocation(
                          context,
                          docs[i].id,
                          (data['label'] ?? 'Location').toString(),
                        ),
                        onSetDefault: () => _setDefault(docs[i].id),
                        onEdit: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) =>
                              _AddLocationSheet(uid: uid, existing: docs[i]),
                        ),
                      );
                    },
                  ),
            // FAB
            Positioned(
              bottom: 24,
              right: 20,
              child: FloatingActionButton.extended(
                onPressed: () => _addLocation(context),
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.primary,
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text(
                  'Add Location',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Location Card ──────────────────────────────────────────────────────────

class _LocationCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;

  const _LocationCard({
    required this.docId,
    required this.data,
    required this.onDelete,
    required this.onSetDefault,
    required this.onEdit,
  });

  IconData get _typeIcon {
    switch ((data['type'] ?? '').toString().toLowerCase()) {
      case 'home':
        return Icons.home_outlined;
      case 'work':
        return Icons.work_outline;
      default:
        return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = (data['label'] ?? 'Location').toString();
    final address = (data['address'] ?? '').toString();
    final isDefault = data['isDefault'] == true;
    final lat = (data['lat'] as num?)?.toDouble();
    final lng = (data['lng'] as num?)?.toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDefault
            ? Border.all(color: AppColors.accent, width: 1.5)
            : null,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Top bar for default
          if (isDefault)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star, size: 13, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text(
                    'Default Location',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_typeIcon, color: AppColors.accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.isNotEmpty ? address : 'No address saved',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (lat != null && lng != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (v) {
                    if (v == 'default') onSetDefault();
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    if (!isDefault)
                      const PopupMenuItem(
                        value: 'default',
                        child: Row(
                          children: [
                            Icon(Icons.star_outline, size: 18),
                            SizedBox(width: 8),
                            Text('Set as Default'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text('Remove', style: TextStyle(color: Colors.red)),
                        ],
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

// ── Add / Edit Location Sheet ──────────────────────────────────────────────

class _AddLocationSheet extends StatefulWidget {
  final String uid;
  final QueryDocumentSnapshot? existing;

  const _AddLocationSheet({required this.uid, this.existing});

  @override
  State<_AddLocationSheet> createState() => _AddLocationSheetState();
}

class _AddLocationSheetState extends State<_AddLocationSheet> {
  final _labelCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _type = 'other';
  double? _lat;
  double? _lng;
  bool _loading = false;
  bool _fetchingGps = false;

  final _types = ['home', 'work', 'other'];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final d = widget.existing!.data() as Map<String, dynamic>;
      _labelCtrl.text = (d['label'] ?? '').toString();
      _addressCtrl.text = (d['address'] ?? '').toString();
      _type = (d['type'] ?? 'other').toString();
      _lat = (d['lat'] as num?)?.toDouble();
      _lng = (d['lng'] as num?)?.toDouble();
    }
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _fetchingGps = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack('Location services are disabled');
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          _showSnack('Location permission denied');
          return;
        }
      }
      if (perm == LocationPermission.deniedForever) {
        _showSnack('Location permission permanently denied');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        if (_addressCtrl.text.isEmpty) {
          _addressCtrl.text =
              '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
        }
      });
    } catch (e) {
      _showSnack('Could not get location');
    } finally {
      if (mounted) setState(() => _fetchingGps = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _save() async {
    final label = _labelCtrl.text.trim();
    if (label.isEmpty) {
      _showSnack('Please enter a label');
      return;
    }
    setState(() => _loading = true);
    try {
      final col = FirebaseFirestore.instance.collection('saved_locations');
      final payload = {
        'userId': widget.uid,
        'label': label,
        'address': _addressCtrl.text.trim(),
        'type': _type,
        'lat': _lat,
        'lng': _lng,
        'isDefault': false,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (widget.existing != null) {
        await col.doc(widget.existing!.id).update(payload);
      } else {
        payload['createdAt'] = FieldValue.serverTimestamp();
        await col.add(payload);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnack('Failed to save location');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
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
            const SizedBox(height: 20),
            Text(
              isEdit ? 'Edit Location' : 'Add Location',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Type selector
            const Text(
              'Type',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: _types.map((t) {
                final selected = _type == t;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _type = t),
                    child: Container(
                      margin: EdgeInsets.only(right: t != _types.last ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.accent
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: selected
                            ? null
                            : Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            t == 'home'
                                ? Icons.home_outlined
                                : t == 'work'
                                ? Icons.work_outline
                                : Icons.location_on_outlined,
                            size: 20,
                            color: selected ? AppColors.primary : Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t[0].toUpperCase() + t.substring(1),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected ? AppColors.primary : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Label
            TextField(
              controller: _labelCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Label (e.g. Home, Office)',
                prefixIcon: const Icon(Icons.label_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 12),

            // Address
            TextField(
              controller: _addressCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Address',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 12),

            // Use current location button
            OutlinedButton.icon(
              onPressed: _fetchingGps ? null : _useCurrentLocation,
              icon: _fetchingGps
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    )
                  : const Icon(Icons.my_location, color: AppColors.accent),
              label: Text(
                _fetchingGps ? 'Getting location...' : 'Use Current Location',
                style: const TextStyle(color: AppColors.accent),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.accent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(double.infinity, 44),
              ),
            ),

            // Coords preview
            if (_lat != null && _lng != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 14, color: Colors.green),
                  const SizedBox(width: 6),
                  Text(
                    'GPS: ${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Text(
                        isEdit ? 'Update' : 'Save Location',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────

class _EmptyLocations extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyLocations({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 72,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'No saved locations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add your home, work or favourite spots',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Add Location'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
