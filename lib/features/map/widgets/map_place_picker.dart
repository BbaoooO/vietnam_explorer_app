import 'package:flutter/material.dart';

import '../data/tourism_places.dart';
import '../models/place_selection.dart';

String normalizeMapSearch(String value) {
  const groups = {
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
      result = result.replaceAll(String.fromCharCode(rune), entry.key);
    }
  }
  return result
      .replaceAll(RegExp(r'[\u0300-\u036f]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

class MapPlacePicker extends StatefulWidget {
  const MapPlacePicker({
    super.key,
    required this.title,
    this.places = tourismPlaces,
    this.recent = const [],
    this.saved = const [],
  });

  final String title;
  final List<TourismPlace> places;
  final List<TourismPlace> recent;
  final List<TourismPlace> saved;


  @override
  State<MapPlacePicker> createState() => _MapPlacePickerState();
}

class _MapPlacePickerState extends State<MapPlacePicker> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _place(TourismPlace place, {bool recent = false}) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF0F4F3),
          child: Icon(
            recent ? Icons.history : Icons.place_outlined,
            color: const Color(0xFF0F4C3A),
          ),
        ),
        title: Text(place.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(place.province),
        trailing: const Icon(Icons.north_west, size: 18),
        onTap: () => Navigator.pop(context, RouteLocation.fromPlace(place)),
      );

  @override
  Widget build(BuildContext context) {
    final query = normalizeMapSearch(_controller.text);
    final results = widget.places
        .where((place) => normalizeMapSearch('${place.name} ${place.province}')
            .contains(query))
        .toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              autofocus: true,
              controller: _controller,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) {
                if (results.length == 1) {
                  Navigator.pop(context, RouteLocation.fromPlace(results.single));
                } else {
                  FocusScope.of(context).unfocus();
                }
              },
              decoration: InputDecoration(
                hintText: 'Tên địa điểm du lịch, tỉnh/thành…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Xóa từ khóa',
                        onPressed: () => setState(_controller.clear),
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: const Color(0xFFF2F5F4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [

                if (query.isEmpty && widget.saved.isNotEmpty) ...[
                  const _SectionLabel('Đã lưu'),
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: widget.saved.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, index) => ActionChip(
                        avatar: const Icon(Icons.bookmark_outline, size: 18),
                        label: Text(widget.saved[index].name),
                        onPressed: () => Navigator.pop(context,
                            RouteLocation.fromPlace(widget.saved[index])),
                      ),
                    ),
                  ),
                ],
                if (query.isEmpty && widget.recent.isNotEmpty) ...[
                  const _SectionLabel('Gần đây'),
                  for (final place in widget.recent) _place(place, recent: true),
                  const Divider(height: 24),
                ],
                _SectionLabel(query.isEmpty
                    ? 'Gợi ý khám phá'
                    : '${results.length} địa điểm phù hợp'),
                if (results.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(28),
                    child: Text(
                      'Chưa tìm thấy trong danh sách du lịch của ứng dụng. '
                      'Thử tên địa danh hoặc tỉnh/thành khác.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                for (final place in results) _place(place),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
      );
}
