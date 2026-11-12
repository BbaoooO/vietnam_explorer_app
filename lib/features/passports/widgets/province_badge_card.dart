import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/province_stamp.dart';

/// Ô huy hiệu (con dấu) tỉnh/thành trong "Collection Book".
class ProvinceBadgeCard extends StatelessWidget {
  final ProvinceStamp? province;

  const ProvinceBadgeCard({super.key, this.province});

  @override
  Widget build(BuildContext context) {
    final unlocked = province != null;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      // --- Thêm tương tác OnTap ---
      onTap: () {
        if (unlocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Huy hiệu ${province!.name}: Bạn đã mở khóa khu vực này!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hãy đi du lịch thêm để mở khóa huy hiệu bí ẩn này nhé!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: unlocked ? Colors.white : const Color(0xFFEFF1F3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unlocked ? const Color(0xFFE5E7EB) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSeal(unlocked),
                  const SizedBox(height: 10),
                  Text(
                    unlocked ? province!.name : 'Locked',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: unlocked ? Colors.black87 : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    unlocked ? province!.tagline : 'Discover more',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: unlocked ? Colors.grey.shade600 : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            if (unlocked)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppTheme.secondaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 13, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeal(bool unlocked) {
    return Container(
      width: 68,
      height: 68,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: unlocked
            ? AppTheme.primaryColor.withOpacity(0.08)
            : const Color(0xFFE5E7EB),
        border: Border.all(
          color: unlocked
              ? AppTheme.primaryColor.withOpacity(0.5)
              : Colors.grey.shade400,
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Icon(
        unlocked ? Icons.account_balance : Icons.lock_outline,
        size: 28,
        color: unlocked ? AppTheme.primaryColor : Colors.grey.shade400,
      ),
    );
  }
}