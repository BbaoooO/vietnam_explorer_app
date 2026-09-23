
import '../../core/explorer_app_bar.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'data/collection_book_data.dart';
import 'models/traveler_profile.dart';
import 'widgets/province_badge_card.dart';
import 'widgets/stamp_card.dart';

/// Màn hình "Hộ chiếu du lịch số" — hiển thị hồ sơ người dùng,
/// tiến độ khám phá và lưới các con dấu địa danh (đã/chưa ghé thăm).
class PassportScreen extends StatelessWidget {
  final TravelerProfile profile;

  const PassportScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor, // đồng bộ nền chung của app
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildAppBar(context)),
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildLevelCard(context)),
          SliverToBoxAdapter(child: _buildCollectionBookHeader(context)),
          _buildCollectionBookGrid(context),
          SliverToBoxAdapter(child: _buildPassportCard(context)),
          SliverToBoxAdapter(child: _buildProgressSection(context)),
          SliverToBoxAdapter(child: _buildVisitedSectionHeader(context)),
          _buildStampsGrid(context),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  // ---------------- AppBar dùng chung toàn app ----------------
  Widget _buildAppBar(BuildContext context) {
    return const ExplorerAppBar();
  }

  // ---------------- Tiêu đề "Digital Passport" ----------------
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Digital\nPassport',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 32,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Track your journey across Vietnam. Collect stamps from "
            "provinces you've visited and unlock exclusive achievements.",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ---------------- Card cấp độ & XP (Task 3.1) ----------------
  Widget _buildLevelCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                'L${profile.levelNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.levelTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level ${profile.levelNumber} Explorer',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${profile.currentXP} / ${profile.xpToNextLevel}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text('XP', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: profile.xpProgress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
            ),
          ),
          if (profile.nextBadgeName.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              "Unlock the '${profile.nextBadgeName}' badge at Level ${profile.nextBadgeLevel}.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------- Tiêu đề "Collection Book" ----------------
  Widget _buildCollectionBookHeader(BuildContext context) {
    final unlockedCount = sampleCollectionBook.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.bookmark_border, color: AppTheme.primaryColor, size: 22),
              ),
              const SizedBox(width: 8),
              const Text(
                'Collection\nBook',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, height: 1.15),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$unlockedCount / $totalVietnamProvinces',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text('Provinces', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- Lưới huy hiệu tỉnh/thành ----------------
  Widget _buildCollectionBookGrid(BuildContext context) {
    // Số ô "Locked" hiển thị thêm sau các tỉnh đã mở khoá (demo).
    const lockedPreviewCount = 1;
    final itemCount = sampleCollectionBook.length + lockedPreviewCount;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index < sampleCollectionBook.length) {
              return ProvinceBadgeCard(province: sampleCollectionBook[index]);
            }
            return const ProvinceBadgeCard(); // ô khoá
          },
          childCount: itemCount,
        ),
      ),
    );
  }

  // ---------------- Tiêu đề mục địa danh đã ghé ----------------
  Widget _buildVisitedSectionHeader(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 4),
      child: Text(
        'Visited Destinations',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor),
      ),
    );
  }

  // ---------------- Thẻ passport chính ----------------
  Widget _buildPassportCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF15694F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppTheme.secondaryColor,
                backgroundImage: NetworkImage(profile.avatarUrl),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mã số: ${profile.passportId}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.flight_takeoff,
                  color: Colors.white70, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white30, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _cardInfo('Ngày cấp',
                  '${profile.issueDate.day}/${profile.issueDate.month}/${profile.issueDate.year}'),
              _cardInfo('Đã ghé thăm', '${profile.visitedCount} địa danh'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
            TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ---------------- Thanh tiến độ khám phá ----------------
  Widget _buildProgressSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tiến độ khám phá Việt Nam',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                '${profile.visitedCount}/${profile.totalDestinations}',
                style: const TextStyle(
                    color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: profile.progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFF0F1F3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.secondaryColor), // vàng theme chung
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Lưới các con dấu địa danh ----------------
  Widget _buildStampsGrid(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) => StampCard(stamp: profile.stamps[index]),
          childCount: profile.stamps.length,
        ),
      ),
    );
  }
}