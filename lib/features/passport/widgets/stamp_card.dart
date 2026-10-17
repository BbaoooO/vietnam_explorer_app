import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/passport_stamp.dart';

class StampCard extends StatelessWidget {
  final PassportStamp stamp;

  const StampCard({super.key, required this.stamp});

  @override
  Widget build(BuildContext context) {
    final locked = !stamp.isUnlocked;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      // --- Thêm tương tác OnTap ---
      onTap: () {
        if (locked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bạn cần đến thăm ${stamp.placeName} để mở khóa!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(stamp.placeName),
              content: Text('Kỷ niệm tuyệt vời của bạn tại ${stamp.province} vào ngày ${stamp.visitedDate.day}/${stamp.visitedDate.month}/${stamp.visitedDate.year}.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                )
              ],
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: locked ? const Color(0xFFE5E7EB) : AppTheme.secondaryColor,
            width: locked ? 1 : 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColorFiltered(
                colorFilter: locked
                    ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                    : const ColorFilter.mode(
                    Colors.transparent, BlendMode.multiply),
                child: Image.network(stamp.imageUrl, fit: BoxFit.cover),
              ),
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
              if (locked)
                const Center(
                  child:
                  Icon(Icons.lock_outline, color: Colors.white70, size: 32),
                ),
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
                              color: AppTheme.secondaryColor, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            '${stamp.visitedDate.day}/${stamp.visitedDate.month}/${stamp.visitedDate.year}',
                            style: const TextStyle(
                                color: Color(0xFFFCE9A8), fontSize: 10),
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
      ),
    );
  }
}