import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_nav.dart';
import 'data/tourism_places.dart';
import 'models/place_selection.dart';
import 'services/map_location_service.dart';
import 'services/map_exception.dart';
import 'widgets/map_place_picker.dart';
import 'widgets/place_photo.dart';

class InteractiveMapScreen extends StatefulWidget {
  const InteractiveMapScreen({super.key});
  @override
  State<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen> {
  static const green = Color(0xFF0F4C3A);
  static const _teal = Color(0xFF087F8C);
  static const detailZoom = 12.0;
  static const _savedKey = 'map_saved_place_ids';
  static const _recentKey = 'map_recent_place_ids';
  static final vnBounds = LatLngBounds(
    southwest: const LatLng(8, 102),
    northeast: const LatLng(24, 118),
  );
  static const regions = {
    'All': 'All',
    'North': 'North',
    'Central': 'Central',
    'South': 'South',
  };
  static const _regionIcons = {
    'All': Icons.explore_outlined,
    'North': Icons.landscape_outlined,
    'Central': Icons.temple_buddhist_outlined,
    'South': Icons.wb_sunny_outlined,
  };

  final searchController = TextEditingController();
  final iconCache = <String, BitmapDescriptor>{};
  final _savedIds = <String>{};
  final _recentIds = <String>[];
  GoogleMapController? map;
  Set<Marker> markers = {};
  LatLng center = const LatLng(16, 106);
  double zoom = 5.2;
  String region = 'All';
  int markerVersion = 0;
  TourismPlace? _selectedPlace;
  LatLng? _userPosition;
  bool _locating = false;
  bool _saving = false;
  bool _openingSearch = false;
  double _sheetExtent = .48;

  List<TourismPlace> get _savedPlaces => tourismPlaces
      .where((place) => _savedIds.contains(place.id)).toList();
  List<TourismPlace> get _recentPlaces => [
    for (final id in _recentIds)
      for (final place in tourismPlaces)
        if (place.id == id) place,
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    AppNav.mapFocusId.addListener(_focusFromHome);
  }

  @override
  void dispose() {
    markerVersion++;
    AppNav.mapFocusId.removeListener(_focusFromHome);
    searchController.dispose();
    map?.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _savedIds.addAll(preferences.getStringList(_savedKey) ?? []);
        _recentIds.addAll(preferences.getStringList(_recentKey) ?? []);
      });
    } catch (_) {
      // Map browsing remains available if local preferences are unavailable.
    }
  }

  void message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  void hideKeyboard() => FocusScope.of(context).unfocus();

  Future<void> _remember(TourismPlace place) async {
    _recentIds.remove(place.id);
    _recentIds.insert(0, place.id);
    if (_recentIds.length > 10) _recentIds.removeRange(10, _recentIds.length);
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setStringList(_recentKey, List.of(_recentIds));
    } catch (_) {
      // Keep history available for the current session.
    }
  }

  Future<void> _toggleSaved(TourismPlace place) async {
    if (_saving) return;
    setState(() => _saving = true);
    final next = Set<String>.of(_savedIds);
    final removed = next.remove(place.id);
    if (!removed) next.add(place.id);
    try {
      final preferences = await SharedPreferences.getInstance();
      final success = await preferences.setStringList(_savedKey, next.toList());
      if (!success) throw StateError('Unable to save preferences');
      if (!mounted) return;
      setState(() {
        _savedIds..clear()..addAll(next);
      });
      message(removed ? 'Đã bỏ lưu địa điểm.' : 'Đã lưu địa điểm.');
    } catch (_) {
      message('Chưa lưu được địa điểm. Hãy thử lại.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _focusFromHome() {
    final id = AppNav.mapFocusId.value;
    if (map == null || id == null) return;
    for (final place in tourismPlaces) {
      if (place.id == id) {
        AppNav.mapFocusId.value = null;
        showPlace(place);
        return;
      }
    }
    AppNav.mapFocusId.value = null;
    message('Địa điểm này chưa có trong danh sách bản đồ.');
  }

  List<TourismPlace> get filteredPlaces {
    final keyword = normalizeMapSearch(searchController.text);
    return tourismPlaces.where((place) {
      return (region == 'All' || place.region == region) &&
          normalizeMapSearch('${place.name} ${place.province}').contains(keyword);
    }).toList();
  }

  Future<void> showSearchResults() async {
    if (_openingSearch) return;
    _openingSearch = true;
    final result = await Navigator.push<RouteLocation>(context,
      MaterialPageRoute(builder: (_) => MapPlacePicker(
        title: 'Tìm địa điểm',
        places: tourismPlaces.where((p) => region == 'All' || p.region == region).toList(),
        recent: _recentPlaces.where((p) => region == 'All' || p.region == region).toList(),
        saved: _savedPlaces.where((p) => region == 'All' || p.region == region).toList(),
      )),
    );
    _openingSearch = false;
    if (!mounted) return;
    if (result?.place case final place?) showPlace(place);
  }

  void selectRegion(String value) {
    hideKeyboard();
    final target = switch (value) {
      'North' => const LatLng(21, 105.8),
      'Central' => const LatLng(16, 108),
      'South' => const LatLng(10.8, 106),
      _ => const LatLng(16, 106),
    };
    markerVersion++;
    setState(() {
      region = value;
      center = target;
      zoom = value == 'All' ? 5.2 : 7;
      searchController.clear();
      _selectedPlace = null;
      markers = {};
    });
    map?.animateCamera(CameraUpdate.newLatLngZoom(target, zoom));
    refreshMarkers();
  }

  void showPlace(TourismPlace place) {
    hideKeyboard();
    _remember(place);
    markerVersion++;
    setState(() {
      if (region != 'All' && region != place.region) region = 'All';
      searchController.text = place.name;
      _selectedPlace = place;
      _sheetExtent = .48;
      center = place.position;
      zoom = 15;
      markers = {};
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      map?.animateCamera(CameraUpdate.newLatLngZoom(place.position, 15));
      refreshMarkers();
    });
  }

  void _closePlace() {
    markerVersion++;
    setState(() {
      _selectedPlace = null;
      searchController.clear();
      markers = {};
    });
    refreshMarkers();
  }

  void showPlacesList(List<TourismPlace> places, {required String title}) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * .6,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            ),
            Expanded(child: places.isEmpty
              ? const Center(child: Text('Bạn chưa lưu địa điểm nào.'))
              : ListView.separated(
                itemCount: places.length,
                separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
                itemBuilder: (_, index) {
                  final place = places[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: pinColor(place.category).withValues(alpha: .1),
                      child: Icon(pinIcon(place.category), color: pinColor(place.category)),
                    ),
                    title: Text(place.name),
                    subtitle: Text(place.province),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      showPlace(place);
                    },
                  );
                },
              )),
          ]),
        ),
      ),
    );
  }

  Future<void> _locate() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final point = await getMapLocation();
      if (!mounted) return;
      if (!vnBounds.contains(point)) {
        message('Vị trí hiện tại nằm ngoài khu vực bản đồ Việt Nam.');
        return;
      }
      setState(() => _userPosition = point);
      await map?.animateCamera(CameraUpdate.newLatLngZoom(point, 15));
    } catch (error) {
      message(error is MapRoutesException ? error.message : 'Chưa lấy được vị trí. Hãy thử lại.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }
  Future<void> _openGoogleMaps(TourismPlace place) async {
    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination':
      '${place.position.latitude},${place.position.longitude}',
    });

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) message('Chưa mở được Google Maps.');
    } catch (_) {
      message('Chưa mở được Google Maps.');
    }
  }
  void changeZoom(double delta) => map?.animateCamera(
    CameraUpdate.newLatLngZoom(center, (zoom + delta).clamp(4.0, 19.0).toDouble()),
  );

  // custom pin

  Color pinColor(String type) {
    return switch (type) {
      'culture' => const Color(0xFF8957E5),
      'nature' => const Color(0xFF238636),
      'spiritual' => const Color(0xFFD97706),
      'beach' => const Color(0xFF0284C7),
      'food' => const Color(0xFFDC2626),
      _ => green,
    };
  }

  IconData pinIcon(String type) {
    return switch (type) {
      'culture' => Icons.museum,
      'nature' => Icons.park,
      'spiritual' => Icons.temple_buddhist,
      'beach' => Icons.beach_access,
      'food' => Icons.restaurant,
      _ => Icons.place,
    };
  }

  String categoryLabel(String value) {
    return switch (value) {
      'culture' => 'Văn hóa',
      'nature' => 'Thiên nhiên',
      'spiritual' => 'Tâm linh',
      'beach' => 'Biển đảo',
      'food' => 'Ẩm thực',
      _ => 'Địa điểm du lịch',
    };
  }

  Future<BitmapDescriptor> bitmap({
    required String key,
    required Color color,
    IconData? icon,
    String? text,
  }) async {
    final cached = iconCache[key];
    if (cached != null) return cached;

    final isCluster = text != null;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = color;

    if (isCluster) {
      canvas.drawCircle(
        const Offset(48, 48),
        42,
        paint,
      );

      canvas.drawCircle(
        const Offset(48, 48),
        42,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
      );
    } else {
      final path = Path()
        ..moveTo(48, 93)
        ..cubicTo(39, 80, 13, 59, 13, 38)
        ..cubicTo(13, 19, 28, 4, 48, 4)
        ..cubicTo(68, 4, 83, 19, 83, 38)
        ..cubicTo(83, 59, 57, 80, 48, 93)
        ..close();

      canvas.drawPath(path, paint);

      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }

    final painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: text ?? String.fromCharCode(icon!.codePoint),
        style: TextStyle(
          color: Colors.white,
          fontSize: isCluster ? 30 : 34,
          fontWeight: FontWeight.bold,
          fontFamily: isCluster ? null : icon!.fontFamily,
          package: isCluster ? null : icon!.fontPackage,
        ),
      ),
    )..layout();

    final iconCenterY = isCluster ? 48.0 : 38.0;

    painter.paint(
      canvas,
      Offset(
        48 - painter.width / 2,
        iconCenterY - painter.height / 2,
      ),
    );

    final picture = recorder.endRecording();

    try {
      final image = await picture.toImage(96, 96);

      try {
        final bytes = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );

        if (bytes == null) {
          throw StateError('Không tạo được ảnh pin.');
        }

        final descriptor = BitmapDescriptor.bytes(
          bytes.buffer.asUint8List(
            bytes.offsetInBytes,
            bytes.lengthInBytes,
          ),
          width: 44,
          height: 44,
        );

        if (mounted) {
          iconCache[key] = descriptor;

          while (iconCache.length > 64) {
            iconCache.remove(iconCache.keys.first);
          }
        }

        return descriptor;
      } finally {
        image.dispose();
      }
    } finally {
      picture.dispose();
    }
  }

  // xử lý gom cụm và zoom in / out

  Future<void> refreshMarkers() async {
    if (map == null || !mounted) return;

    final version = ++markerVersion;
    final currentZoom = zoom;
    final places = filteredPlaces;
    final next = <Marker>{};

    try {
      if (currentZoom < detailZoom) {
        // xu ly zoom out
        final groups = <String, List<TourismPlace>>{};

        for (final place in places) {
          groups
              .putIfAbsent(
            place.province,
                () => <TourismPlace>[],
          )
              .add(place);
        }

        for (final entry in groups.entries) {
          final group = entry.value;

          final point = LatLng(
            group.fold<double>(
              0,
                  (sum, place) => sum + place.position.latitude,
            ) /
                group.length,
            group.fold<double>(
              0,
                  (sum, place) => sum + place.position.longitude,
            ) /
                group.length,
          );

          final icon = await bitmap(
            key: 'cluster:${group.length}',
            color: green,
            text: '${group.length}',
          );

          if (!mounted || version != markerVersion) return;

          next.add(
            Marker(
              markerId: MarkerId('cluster:${entry.key}'),
              position: point,
              anchor: const Offset(.5, .5),
              icon: icon,
              infoWindow: InfoWindow(
                title: entry.key,
                snippet: '${group.length} địa điểm',
              ),
              onTap: () {
                hideKeyboard();

                map?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    point,
                    detailZoom,
                  ),
                );
              },
            ),
          );
        }
      } else {
        // hàm xu ly zoom in
        for (final place in places) {
          final icon = await bitmap(
            key: 'pin:${place.category}',
            color: pinColor(place.category),
            icon: pinIcon(place.category),
          );

          if (!mounted || version != markerVersion) return;

          next.add(
            Marker(
              markerId: MarkerId(place.id),
              position: place.position,
              icon: icon,
              anchor: const Offset(.5, 1),
              onTap: () {
                hideKeyboard();
                showPlace(place);
              },
            ),
          );
        }
      }

      if (mounted && version == markerVersion) {
        setState(() => markers = next);
      }
    } catch (_) {
      if (mounted && version == markerVersion) {
        message('Chưa tạo được pin. Thử zoom lại.');
      }
    }
  }



  Widget _roundButton({required String tooltip, required IconData icon, required VoidCallback onPressed, bool primary = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Material(
        elevation: 3,
        shadowColor: Colors.black26,
        color: primary ? _teal : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(primary ? 18 : 26)),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          constraints: BoxConstraints.tightFor(width: primary ? 56 : 46, height: primary ? 56 : 46),
          icon: Icon(icon, color: primary ? Colors.white : green, size: primary ? 28 : 23),
        ),
      ),
    );
  }

  Widget _topPanel() => SafeArea(
    bottom: false,
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Material(
        elevation: 4,
        shadowColor: Colors.black26,
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: showSearchResults,
          borderRadius: BorderRadius.circular(30),
          child: SizedBox(
            height: 56,
            child: Row(children: [
              const SizedBox(width: 18),
              Icon(_selectedPlace == null ? Icons.search : Icons.place, color: green, size: 27),
              const SizedBox(width: 12),
              Expanded(child: Text(
                _selectedPlace?.name ?? 'Tìm địa điểm ở Việt Nam',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, color: _selectedPlace == null ? Colors.black54 : Colors.black87),
              )),
              if (_selectedPlace != null)
                IconButton(tooltip: 'Đóng địa điểm', onPressed: _closePlace, icon: const Icon(Icons.close))
              else
                IconButton(
                  tooltip: 'Địa điểm đã lưu',
                  onPressed: () => showPlacesList(_savedPlaces, title: 'Địa điểm đã lưu'),
                  icon: const Icon(Icons.bookmark_outline, color: green),
                ),
              const SizedBox(width: 6),
            ]),
          ),
        ),
      ),
      if (_selectedPlace == null) ...[
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (final entry in regions.entries)
              Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 6),
                child: Material(
                  elevation: 2,
                  shadowColor: Colors.black26,
                  color: entry.key == region ? const Color(0xFFDDF1E8) : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => selectRegion(entry.key),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(_regionIcons[entry.key], size: 18, color: green),
                        const SizedBox(width: 7),
                        Text(entry.value, style: const TextStyle(color: green, fontWeight: FontWeight.w600, fontSize: 13)),
                      ]),
                    ),
                  ),
                ),
              ),
          ]),
        ),
      ],
    ]),
  );

  Widget _placeDetails(TourismPlace place, ScrollController controller) {
    final saved = _savedIds.contains(place.id);
    final nearby = tourismPlaces.where((p) => p.id != place.id && p.province == place.province).take(5).toList();
    return Material(
      color: Colors.white,
      elevation: 8,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      clipBehavior: Clip.antiAlias,
      child: ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Center(child: Container(
            width: 36, height: 4,
            decoration: BoxDecoration(color: const Color(0xFFCFD5D4), borderRadius: BorderRadius.circular(4)),
          )),
          const SizedBox(height: 16),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Text(place.name, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700))),
            IconButton(
              tooltip: saved ? 'Bỏ lưu' : 'Lưu địa điểm',
              onPressed: _saving ? null : () => _toggleSaved(place),
              icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border, color: green),
            ),
            IconButton(tooltip: 'Đóng', onPressed: _closePlace, icon: const Icon(Icons.close)),
          ]),
          Text(place.province, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          const SizedBox(height: 6),
          Row(children: [
            Icon(pinIcon(place.category), size: 16, color: pinColor(place.category)),
            const SizedBox(width: 6),
            Text(categoryLabel(place.category), style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ]),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _teal, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
              onPressed: () => _openGoogleMaps(place),
              icon: const Icon(Icons.directions, size: 20),
              label: const Text('Đường đi'),

            ),
            OutlinedButton.icon(
              onPressed: _saving ? null : () => _toggleSaved(place),
              icon: Icon(saved ? Icons.bookmark : Icons.bookmark_outline, size: 18),
              label: Text(saved ? 'Đã lưu' : 'Lưu'),
            ),
          ]),
          const SizedBox(height: 18),
          PlacePhoto(place: place),
          if (nearby.isNotEmpty) ...[
            const SizedBox(height: 22),
            const Text('Khám phá cùng tỉnh / thành', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            SizedBox(height: 94, child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: nearby.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                final other = nearby[index];
                return SizedBox(width: 220, child: Card(
                  color: const Color(0xFFF1F6F3),
                  elevation: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => showPlace(other),
                    child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
                      Icon(pinIcon(other.category), color: green),
                      const SizedBox(width: 10),
                      Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(other.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(other.province, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ])),
                    ])),
                  ),
                ));
              },
            )),
          ],
        ],
      ),
    );
  }

  Widget _discoveryPanel() => Material(
    color: Colors.white,
    elevation: 8,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    child: InkWell(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      onTap: () => showPlacesList(filteredPlaces, title: 'Khám phá ${regions[region]!.toLowerCase()}'),
      child: SafeArea(top: false, child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 34, height: 4, decoration: BoxDecoration(color: const Color(0xFFCFD5D4), borderRadius: BorderRadius.circular(4)))),
          const SizedBox(height: 14),
          Row(children: [
            const Icon(Icons.explore_outlined, color: green, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Khám phá Việt Nam', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('${filteredPlaces.length} địa điểm · ${regions[region]}', style: const TextStyle(color: Colors.black54)),
            ])),
            const Icon(Icons.keyboard_arrow_up, color: green),
          ]),
        ]),
      )),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(builder: (context, constraints) {
      final place = _selectedPlace;
      final bottomPanel = place == null ? 124.0 : constraints.maxHeight * _sheetExtent;
      final showZoomButtons = constraints.maxHeight - bottomPanel > 400;
      return Stack(children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(target: LatLng(16, 106), zoom: 5.2),
          cameraTargetBounds: CameraTargetBounds(vnBounds),
          minMaxZoomPreference: const MinMaxZoomPreference(4, 19),
          mapType: MapType.normal,
          markers: {
            ...markers,
            if (_userPosition != null) Marker(
              markerId: const MarkerId('user:position'),
              position: _userPosition!,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              infoWindow: const InfoWindow(title: 'Vị trí của bạn'),
            ),
          },
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          compassEnabled: true,
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + (place == null ? 128 : 76),
            bottom: bottomPanel,
            right: 12,
          ),
          onMapCreated: (controller) {
            map = controller;
            refreshMarkers();
            _focusFromHome();
          },
          onCameraMove: (position) {
            center = position.target;
            zoom = position.zoom;
            markerVersion++;
          },
          onCameraIdle: refreshMarkers,
          onTap: (_) => hideKeyboard(),
        ),
        Positioned(top: 12, left: 14, right: 14, child: _topPanel()),
        if (place == null || _sheetExtent < .58)
          Positioned(
            right: 16,
            bottom: bottomPanel + 16,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (showZoomButtons) ...[
                _roundButton(tooltip: 'Phóng to', icon: Icons.add, onPressed: () => changeZoom(1)),
                _roundButton(tooltip: 'Thu nhỏ', icon: Icons.remove, onPressed: () => changeZoom(-1)),
              ],
              _roundButton(tooltip: _locating ? 'Đang lấy vị trí…' : 'Vị trí của bạn', icon: _locating ? Icons.hourglass_top : Icons.my_location, onPressed: _locate),
            ]),
          ),
        if (place == null)
          Positioned(left: 0, right: 0, bottom: 0, child: _discoveryPanel())
        else
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              if ((_sheetExtent - notification.extent).abs() > .015) {
                setState(() => _sheetExtent = notification.extent);
              }
              return false;
            },
            child: DraggableScrollableSheet(
              key: ValueKey(place.id),
              initialChildSize: .48,
              minChildSize: .18,
              maxChildSize: .9,
              snap: true,
              snapSizes: const [.18, .48, .9],
              builder: (_, controller) => _placeDetails(place, controller),
            ),
          ),
      ]);
    }),
  );
}
