import 'package:flutter/material.dart';

import '../data/tourism_places.dart';

class PlacePhoto extends StatelessWidget {
  const PlacePhoto({super.key, required this.place});

  final TourismPlace place;


  Widget _fallback(String message) => SizedBox(
    height: 210,
    width: double.infinity,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.image_outlined, size: 42, color: Colors.grey),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ColoredBox(
            color: const Color(0xFFF0F2F3),
            child: place.imageUrl.isEmpty
                ? _fallback('Chưa có ảnh địa điểm')
                : Image.network(
                    place.imageUrl,
                    height: 210,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    semanticLabel: 'Ảnh ${place.name}',
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      final total = progress.expectedTotalBytes;
                      return SizedBox(
                        height: 210,
                        width: double.infinity,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: total == null || total == 0
                                ? null
                                : progress.cumulativeBytesLoaded / total,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        _fallback('Chưa tải được ảnh. Kiểm tra kết nối mạng.'),
                  ),
          ),
        ),
        if (place.imageFile.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Ảnh: ${place.imageAuthor} · ${place.imageLicense}',
            style: Theme.of(context).textTheme.bodySmall,
          ),

        ],
      ],
    );
  }
}
