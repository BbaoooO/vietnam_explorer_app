import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/favorite_place_store.dart';
import 'data/tourism_places.dart';
import 'widgets/place_photo.dart';
import 'widgets/place_visit_panel.dart';

class InteractiveMapScreen extends StatefulWidget {
  const InteractiveMapScreen({super.key});

  @override
  State<InteractiveMapScreen> createState() =>
      _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen> {
  static const green = Color(0xFF0F4C3A);
  static const mapsBlue = Color(0xFF1A73E8);
  static const detailZoom = 12.0;
  static final vnBounds = LatLngBounds(
    southwest: const LatLng(8, 102),
    northeast: const LatLng(24, 118),
  );

  static const regions = <String, String>{
    'All': 'All',
    'North': 'North',
    'Central': 'Central',
    'South': 'South',
  };

  final searchController = TextEditingController();
  final store = FavoritePlaceStore.instance;
  final saved = <String>{};
  final saving = <String>{};
  final favoriteRevision = ValueNotifier<int>(0);
  final iconCache = <String, BitmapDescriptor>{};

  GoogleMapController? map;
  Set<Marker> markers = {};

  LatLng center = const LatLng(16, 106);
  double zoom = 5.2;
  String region = 'All';

  bool savedReady = false;
  bool loadingSaved = false;
  int markerVersion = 0;

  @override
  void initState() {
    super.initState();
    loadSaved();
  }

  @override
  void dispose() {
    markerVersion++;
    searchController.dispose();
    favoriteRevision.dispose();
    map?.dispose();
    super.dispose();
  }

  void message(String value) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(value)),
      );
  }

  void hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  // tim kiem

  String normalize(String value) {
    const groups = <String, String>{
      'a': 'àáạảãâầấậẩẫăằắặẳẵ',
      'e': 'èéẹẻẽêềếệểễ',
      'i': 'ìíịỉĩ',
      'o': 'òóọỏõôồốộổỗơờớợởỡ',
      'u': 'ùúụủũưừứựửữ',
      'y': 'ỳýỵỷỹ',
      'd': 'đ',
    };

    var result = value.toLowerCase();

    for (final entry in groups.entries) {
      for (final rune in entry.value.runes) {
        result = result.replaceAll(
          String.fromCharCode(rune),
          entry.key,
        );
      }
    }

    return result
        .replaceAll(RegExp(r'[\u0300-\u036f]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<TourismPlace> get filteredPlaces {
    final keyword = normalize(searchController.text);

    return tourismPlaces.where((place) {
      final matchesRegion =
          region == 'All' || place.region == region;

      final matchesSearch =
      normalize('${place.name} ${place.province}')
          .contains(keyword);

      return matchesRegion && matchesSearch;
    }).toList();
  }

  void updateSearch() {
    markerVersion++;

    setState(() {
      markers = {};
    });

    refreshMarkers();
  }

  void showSearchResults() {
    hideKeyboard();

    final results = filteredPlaces;

    if (results.isEmpty) {
      message('Không có địa điểm phù hợp trong vùng đang chọn.');
      return;
    }

    showPlacesList(
      results,
      title: '${results.length} địa điểm phù hợp',
    );
  }

  // chon vùng

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
      markers = {};
    });

    map?.animateCamera(
      CameraUpdate.newLatLngZoom(target, zoom),
    );

    refreshMarkers();
  }

  // lưu yêu thích

  Future<void> loadSaved() async {
    if (loadingSaved) return;

    setState(() => loadingSaved = true);

    try {
      await store.database;
      try {
        final prefs = await SharedPreferences.getInstance();

        final oldIds = (
            prefs.getStringList('raw_map_saved') ?? <String>[]
        ).toSet();

        await store.migrateLegacyPlaces(
          tourismPlaces
              .where((place) => oldIds.contains(place.id))
              .toList(),
        );
      } catch (_) {
        message(
          'Chưa chuyển được yêu thích cũ. '
              'Thử mở lại ứng dụng sau.',
        );
      }

      final ids = await store.readIds();

      if (!mounted) return;

      setState(() {
        saved
          ..clear()
          ..addAll(ids);

        savedReady = true;
      });
    } catch (_) {
      message(
        'Chưa mở được SQLite. Bấm nút thử lại ở thanh phía trên.',
      );
    } finally {
      if (mounted) {
        setState(() => loadingSaved = false);
        favoriteRevision.value++;
      }
    }
  }

  Future<void> toggleSaved(TourismPlace place) async {
    if (!savedReady || saving.contains(place.id)) return;

    final wasSaved = saved.contains(place.id);

    setState(() => saving.add(place.id));
    favoriteRevision.value++;

    try {
      if (wasSaved) {
        await store.remove(place.id);
      } else {
        await store.save(place);
      }

      if (!mounted) return;

      // đổi trạng thái khi luư vào sql lite
      setState(() {
        if (wasSaved) {
          saved.remove(place.id);
        } else {
          saved.add(place.id);
        }
      });

      message(
        wasSaved
            ? 'Đã bỏ địa điểm khỏi danh sách đã lưu.'
            : 'Đã lưu địa điểm.',
      );
    } catch (_) {
      message('Chưa lưu được thay đổi. Hãy thử lại.');
    } finally {
      if (mounted) {
        setState(() => saving.remove(place.id));
        favoriteRevision.value++;
      }
    }
  }

  void showFavorites() {
    hideKeyboard();

    if (!savedReady) {
      message(
        'Danh sách đã lưu chưa sẵn sàng. '
            'Bấm thử lại ở thanh phía trên.',
      );
      return;
    }

    final places = tourismPlaces
        .where((place) => saved.contains(place.id))
        .toList();

    showPlacesList(
      places,
      title: 'Địa điểm đã lưu',
      fromFavorites: true,
    );
  }

  // Dùng cho kết quả tìm kiếm và danh sách đã lưu.
  void showPlacesList(
      List<TourismPlace> places, {
        required String title,
        bool fromFavorites = false,
      }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: places.isEmpty
                  ? const Center(
                child: Text('Chưa lưu địa điểm nào.'),
              )
                  : ListView.builder(
                itemCount: places.length,
                itemBuilder: (_, index) {
                  final place = places[index];

                  return ListTile(
                    leading: Icon(
                      pinIcon(place.category),
                      color: pinColor(place.category),
                    ),
                    title: Text(place.name),
                    subtitle: Text(place.province),
                    trailing: const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: () async {
                      Navigator.pop(sheetContext);

                      if (fromFavorites) {
                        markerVersion++;

                        setState(() {
                          searchController.clear();
                          region = place.region;
                          markers = {};
                        });
                      }

                      await map?.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          place.position,
                          15,
                        ),
                      );

                      if (!mounted) return;

                      refreshMarkers();
                      showPlace(place);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  // thông tin dia diem

  void showPlace(TourismPlace place) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => ValueListenableBuilder<int>(
        valueListenable: favoriteRevision,
        builder: (sheetContext, revision, child) {
          final isSaved = saved.contains(place.id);
          final isSaving = saving.contains(place.id);

          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(sheetContext).size.height * .8,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PlacePhoto(place: place),
                    const SizedBox(height: 12),
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${place.province} · '
                          '${categoryLabel(place.category)}',
                    ),
                    const SizedBox(height: 8),
                    Text(place.description),
                    const SizedBox(height: 14),

                    // nút lưu yêu thích
                    OutlinedButton.icon(
                      onPressed: !savedReady || isSaving
                          ? null
                          : () => toggleSaved(place),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: mapsBlue,
                        side: const BorderSide(
                          color: mapsBlue,
                        ),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      icon: Icon(
                        isSaved
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        size: 20,
                      ),
                      label: Text(
                        !savedReady
                            ? 'Đang tải…'
                            : isSaving
                            ? 'Đang lưu…'
                            : isSaved
                            ? 'Đã lưu'
                            : 'Lưu',
                      ),
                    ),

                    const SizedBox(height: 16),
                    PlaceVisitPanel(placeId: place.id),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // zoom in zoom out

  void changeZoom(double delta) {
    hideKeyboard();

    map?.animateCamera(
      CameraUpdate.newLatLngZoom(
        center,
        (zoom + delta).clamp(4.0, 19.0).toDouble(),
      ),
    );
  }

  Widget mapButton({
    required String tag,
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
    Color color = green,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FloatingActionButton.small(
        heroTag: tag,
        tooltip: tooltip,
        backgroundColor: Colors.white,
        foregroundColor: color,
        onPressed: onPressed,
        child: Icon(icon, size: 22),
      ),
    );
  }

  // tìm kiếm, phân vùng

  Widget topPanel() {
    return SafeArea(
      bottom: false,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchController,
                textInputAction: TextInputAction.search,
                onChanged: (_) => updateSearch(),
                onSubmitted: (_) => showSearchResults(),
                decoration: InputDecoration(
                  hintText: 'Tìm địa điểm hoặc tỉnh/thành...',
                  prefixIcon: IconButton(
                    tooltip: 'Tìm kiếm',
                    icon: const Icon(
                      Icons.search,
                      color: green,
                    ),
                    onPressed: showSearchResults,
                  ),
                  suffixIcon: IconButton(
                    tooltip: 'Xóa từ khóa',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      searchController.clear();
                      updateSearch();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${regions[region]} · '
                          '${filteredPlaces.length} địa điểm',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!savedReady)
                    IconButton(
                      tooltip: 'Thử tải danh sách đã lưu',
                      onPressed: loadingSaved ? null : loadSaved,
                      icon: Icon(
                        loadingSaved
                            ? Icons.hourglass_top
                            : Icons.refresh,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final entry in regions.entries)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(entry.value),
                          selected: region == entry.key,
                          selectedColor: green,
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            color: region == entry.key
                                ? Colors.white
                                : green,
                          ),
                          onSelected: (_) =>
                              selectRegion(entry.key),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen =
        MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(16, 106),
              zoom: 5.2,
            ),
            cameraTargetBounds: CameraTargetBounds(vnBounds),
            minMaxZoomPreference:
            const MinMaxZoomPreference(4, 19),
            markers: markers,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            padding: EdgeInsets.only(
              top: 195,
              bottom: keyboardOpen
                  ? 16
                  : MediaQuery.of(context).padding.bottom + 24,
              right: keyboardOpen ? 0 : 60,
            ),
            onMapCreated: (controller) {
              map = controller;
              refreshMarkers();
            },
            onCameraMove: (position) {
              center = position.target;
              zoom = position.zoom;
              markerVersion++;
            },
            onCameraIdle: refreshMarkers,
            onTap: (_) => hideKeyboard(),
          ),
          Positioned(
            top: 0,
            left: 12,
            right: 12,
            child: topPanel(),
          ),
          if (!keyboardOpen)
            Positioned(
              right: 12,
              bottom: 24,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Danh sách đã lưu
                    mapButton(
                      tag: 'map:saved',
                      tooltip: 'Địa điểm đã lưu',
                      icon: Icons.bookmark,
                      color: mapsBlue,
                      onPressed: showFavorites,
                    ),
                    mapButton(
                      tag: 'map:zoomIn',
                      tooltip: 'Phóng to',
                      icon: Icons.add,
                      onPressed: () => changeZoom(1),
                    ),
                    mapButton(
                      tag: 'map:zoomOut',
                      tooltip: 'Thu nhỏ',
                      icon: Icons.remove,
                      onPressed: () => changeZoom(-1),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}