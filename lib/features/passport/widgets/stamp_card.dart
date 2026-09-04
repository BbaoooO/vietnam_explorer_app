import 'package:flutter/material.dart';
import '../models/passport_stamp.dart';

class StampCard extends StatelessWidget {
  final PassportStamp stamp;

  const StampCard({super.key, required this.stamp});

  @override
  Widget build(BuildContext context) {
    final locked = !stamp.isUnlocked;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: locked ? const Color(0xFFE0DACB) : const Color(0xFFC79A3B),
          width: locked ? 1 : 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ảnh nền địa danh
            ColorFiltered(
              colorFilter: locked
                  ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                  : const ColorFilter.mode(
                      Colors.transparent, BlendMode.multiply),
              child: Image.network(stamp.imageUrl, fit: BoxFit.cover),
            ),
            // Lớp phủ gradient để chữ dễ đọc
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.75),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            // Icon khóa nếu chưa mở
            if (locked)
              const Center(
                child:
                    Icon(Icons.lock_outline, color: Colors.white70, size: 32),
              ),
            // Thông tin địa danh
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stamp.placeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                  Text(
                    stamp.province,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 11),
                  ),
                  if (!locked) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Color(0xFFC79A3B), size: 13),
                        const SizedBox(width: 4),
                        Text(
                          '${stamp.visitedDate.day}/${stamp.visitedDate.month}/${stamp.visitedDate.year}',
                          style: const TextStyle(
                              color: Color(0xFFE8D9A8), fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
