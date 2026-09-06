import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Model lưu trữ thông tin điểm đến
class Destination {
  final String id;
  final String name;
  final String subtitle;
  final String category;
  final String imageUrl;
  final String entryFee;
  final String bestTime;
  final double rating;
  final int reviewCount;
  final LatLng position;
  final IconData icon;
  final String region;

  Destination({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.category,
    required this.imageUrl,
    required this.entryFee,
    required this.bestTime,
    required this.rating,
    required this.reviewCount,
    required this.position,
    required this.icon,
    required this.region,
  });
}

class InteractiveMapScreen extends StatefulWidget {
  const InteractiveMapScreen({super.key});

  @override
  State<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen> {
  GoogleMapController? _mapController;
  Destination? _selectedDestination;
  String _selectedRegion = 'All';
  final Set<Marker> _markers = {};

  // Color Palette theo Design System Modern Heritage
  static const Color primaryColor = Color(0xFF003426);
  static const Color secondaryFixed = Color(0xFFFFDF9D);
  static const Color secondaryContainer = Color(0xFFFCC019);

  // Data mẫu
  final List<Destination> _destinations = [
    Destination(
      id: '1',
      name: 'Tran Quoc Pagoda',
      subtitle: 'Hanoi, Northern Vietnam',
      category: 'Heritage Site',
      imageUrl:
      'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=600',
      entryFee: 'Free',
      bestTime: 'Late Afternoon',
      rating: 4.8,
      reviewCount: 2100,
      position: const LatLng(21.0469, 105.8189),
      icon: Icons.temple_buddhist,
      region: 'North',
    ),
    Destination(
      id: '2',
      name: 'My Khe Beach',
      subtitle: 'Da Nang, Central Vietnam',
      category: 'Beach',
      imageUrl:
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600',
      entryFee: 'Free',
      bestTime: 'Sunrise',
      rating: 4.6,
      reviewCount: 1500,
      position: const LatLng(16.0544, 108.2469),
      icon: Icons.beach_access,
      region: 'Central',
    ),
    Destination(
      id: '3',
      name: 'Sapa Terraces',
      subtitle: 'Lao Cai, Northern Vietnam',
      category: 'Mountain',
      imageUrl:
      'https://images.unsplash.com/photo-1528127269322-539801943592?w=600',
      entryFee: '50,000 VND',
      bestTime: 'Morning',
      rating: 4.9,
      reviewCount: 980,
      position: const LatLng(22.3364, 103.8438),
      icon: Icons.landscape,
      region: 'North',
    ),
    Destination(
      id: '4',
      name: 'Mekong Delta',
      subtitle: 'Can Tho, Southern Vietnam',
      category: 'Nature',
      imageUrl:
      'https://images.unsplash.com/photo-1528127269322-539801943592?w=600',
      entryFee: '30,000 VND',
      bestTime: 'Early Morning',
      rating: 4.7,
      reviewCount: 760,
      position: const LatLng(10.0452, 105.7469),
      icon: Icons.water,
      region: 'South',
    ),
  ];

  List<Destination> get _filteredDestinations {
    if (_selectedRegion == 'All') return _destinations;
    return _destinations.where((d) => d.region == _selectedRegion).toList();
  }

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  /// Vẽ 1 pin hình giọt nước (teardrop) có icon bên trong bằng Canvas,
  /// sau đó chuyển thành ảnh (BitmapDescriptor) để Google Maps hiển thị được.
  Future<BitmapDescriptor> _createCustomMarker(
      IconData icon, {
        bool active = false,
      }) async {
    final double width = active ? 56 : 40;
    final double height = active ? 64 : 48;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final pinPath = Path()
      ..moveTo(width / 2, 0)
      ..cubicTo(width * 0.22, 0, 0, width * 0.22, 0, width / 2)
      ..cubicTo(0, height * 0.73, width / 2, height, width / 2, height)
      ..cubicTo(width / 2, height, width, height * 0.73, width, width / 2)
      ..cubicTo(width, width * 0.22, width * 0.78, 0, width / 2, 0)
      ..close();

    canvas.drawPath(pinPath, Paint()..color = primaryColor);
    canvas.drawPath(
      pinPath,
      Paint()
        ..color = secondaryFixed
        ..style = PaintingStyle.stroke
        ..strokeWidth = active ? 3 : 2,
    );

    final iconColor = active ? secondaryFixed : Colors.white;
    final textPainter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: active ? 26 : 18,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: iconColor,
        ),
      )
      ..layout();
    textPainter.paint(
      canvas,
      Offset(
        width / 2 - textPainter.width / 2,
        width / 2 - textPainter.height / 2 - 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  Future<void> _createMarkers() async {
    final Set<Marker> newMarkers = {};
    for (final dest in _filteredDestinations) {
      final isActive = _selectedDestination?.id == dest.id;
      final icon = await _createCustomMarker(dest.icon, active: isActive);
      newMarkers.add(
        Marker(
          markerId: MarkerId(dest.id),
          position: dest.position,
          icon: icon,
          anchor: const Offset(0.5, 1.0),
          onTap: () {
            setState(() => _selectedDestination = dest);
            _createMarkers();
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(dest.position),
            );
          },
        ),
      );
    }
    if (!mounted) return;
    setState(() {
      _markers
        ..clear()
        ..addAll(newMarkers);
    });
  }

  void _onRegionSelected(String region) {
    setState(() {
      _selectedRegion = region;
      _selectedDestination = null;
    });
    _createMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(16.0, 106.0),
              zoom: 5.2,
            ),
            markers: _markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) => _mapController = controller,
            onTap: (_) => setState(() => _selectedDestination = null),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 8),
                _buildRegionChips(),
              ],
            ),
          ),
          if (_selectedDestination != null)
            _buildDetailSheet(_selectedDestination!),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 8),
              const Expanded(
                child: TextField(
                  style: TextStyle(fontFamily: 'Be Vietnam Pro'),
                  decoration: InputDecoration(
                    hintText: 'Search landmarks, cities...',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              Container(width: 1, height: 24, color: Colors.grey.shade300),
              const SizedBox(width: 8),
              const Icon(Icons.mic, color: primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegionChips() {
    final regions = ['All', 'North', 'Central', 'South'];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: regions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final region = regions[index];
          final selected = region == _selectedRegion;
          return ChoiceChip(
            label: Text(
              region,
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                color: selected ? Colors.white : primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            selected: selected,
            onSelected: (_) => _onRegionSelected(region),
            selectedColor: primaryColor,
            backgroundColor: Colors.white,
            shape: StadiumBorder(
              side: BorderSide(
                color: selected ? primaryColor : primaryColor.withOpacity(0.4),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSheet(Destination dest) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            // Tăng bottom padding lên 110 để tránh bị thanh navigation bar nổi che mất nút bấm bên dưới
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              dest.category,
                              style: const TextStyle(
                                fontFamily: 'Be Vietnam Pro',
                                color: primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dest.name,
                            style: const TextStyle(
                              fontFamily: 'Be Vietnam Pro',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            dest.subtitle,
                            style: TextStyle(
                              fontFamily: 'Be Vietnam Pro',
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_border,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        dest.imageUrl,
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 130,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.threesixty, color: primaryColor, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'View 360°',
                              style: TextStyle(
                                fontFamily: 'Be Vietnam Pro',
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        Icons.payments,
                        'Entry Fee',
                        dest.entryFee,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        Icons.schedule,
                        'Best Time',
                        dest.bestTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text(
                      'Add to Itinerary',
                      style: TextStyle(fontFamily: 'Be Vietnam Pro'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryContainer,
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}