import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/models/destination_model.dart';
import '../../core/repositories/dummy_data_repository.dart';
import 'package:provider/provider.dart';
import '../../core/models/planner_model.dart';
import '../../core/providers/planner_provider.dart';

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

  static const Color primaryColor = Color(0xFF003426);
  static const Color secondaryFixed = Color(0xFFFFDF9D);
  static const Color secondaryContainer = Color(0xFFFCC019);

  // Lấy dữ liệu trực tiếp từ Repository thay vì hardcode
  List<Destination> get _filteredDestinations {
    if (_selectedRegion == 'All') return DummyDataRepository.destinations;
    return DummyDataRepository.destinations.where((d) => d.region == _selectedRegion).toList();
  }

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

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

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
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
            color: const Color(0xB3FFFFFF),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0x4DFFFFFF)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 8),
              const Expanded(
                child: TextField(
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
                color: selected ? primaryColor : const Color(0x66003426),
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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            decoration: const BoxDecoration(
              color: Color(0xD9FFFFFF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                              color: const Color(0x1A003426),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              dest.category,
                              style: const TextStyle(
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
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            dest.subtitle,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => setState(() => _selectedDestination = null),
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
                          color: const Color(0xD9FFFFFF),
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
                    onPressed: () {
                      _showAddToItineraryDialog(context, dest);
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add to Itinerary'),
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
        color: const Color(0x80FFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x66FFFFFF)),
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  void _showAddToItineraryDialog(BuildContext context, Destination dest) {
    int selectedDay = 0; // Mặc định chọn Ngày 1 (Index 0)

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final plannerProvider = Provider.of<PlannerProvider>(context, listen: false);

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thêm "${dest.name}" vào lịch trình',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Chọn ngày bạn muốn ghé thăm:'),
                  const SizedBox(height: 16),

                  // Danh sách chọn Ngày
                  Row(
                    children: List.generate(
                      plannerProvider.itineraries.length,
                          (index) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text('Day ${index + 1}'),
                          selected: selectedDay == index,
                          selectedColor: primaryColor,
                          labelStyle: TextStyle(
                            color: selectedDay == index ? Colors.white : primaryColor,
                          ),
                          onSelected: (bool selected) {

                            setModalState(() {
                              selectedDay = index;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nút Xác nhận
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // 1. Tạo một PlannerItem mới từ Destination
                        final newItem = PlannerItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          time: '14:00\nPM', // Giờ mặc định
                          title: dest.name,
                          description: dest.subtitle,
                          icon: dest.icon,
                          estimatedCost: dest.entryFee,
                          isCompleted: false,
                        );

                        // 2. Bắn dữ liệu sang Provider
                        plannerProvider.addPlanToDay(selectedDay, newItem);

                        // 3. Đóng BottomSheet và thông báo thành công
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã thêm ${dest.name} vào Day ${selectedDay + 1}!'),
                            backgroundColor: primaryColor,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text(
                        'Xác nhận thêm',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}