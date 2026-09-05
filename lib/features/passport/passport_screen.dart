import 'package:flutter/material.dart';
import 'models/traveler_profile.dart';
import 'widgets/stamp_card.dart';

// TODO: Nếu core/explorer_app_bar.dart đã có sẵn AppBar dùng chung cho cả app
// (Planner, v.v...), cân nhắc thay _buildAppBar() bên dưới bằng widget đó để
// đồng bộ giao diện, ví dụ:
//   import '../../core/explorer_app_bar.dart';
//   appBar: ExplorerAppBar(title: 'Hộ chiếu du lịch số'),

/// Màn hình "Hộ chiếu du lịch số" — hiển thị hồ sơ người dùng,
/// tiến độ khám phá và lưới các con dấu địa danh (đã/chưa ghé thăm).
class PassportScreen extends StatelessWidget {
  final TravelerProfile profile;

  const PassportScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1E8), // nền giấy ngà
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: _buildPassportCard(context)),
          SliverToBoxAdapter(child: _buildProgressSection(context)),
          _buildStampsGrid(context),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  // ---------------- AppBar ----------------
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFF7A2E2E), // đỏ trầm kiểu passport
      expandedHeight: 90,
      flexibleSpace: const FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          'Hộ chiếu du lịch số',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.qr_code_2, color: Colors.white),
          tooltip: 'Mã QR chia sẻ',
          onPressed: () {},
        ),
      ],
    );
  }

  // ---------------- Thẻ passport chính ----------------
  Widget _buildPassportCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7A2E2E), Color(0xFF9C4444)],
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
                backgroundColor: Colors.white,
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
        border: Border.all(color: const Color(0xFFE0DACB)),
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
                    color: Color(0xFF7A2E2E), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: profile.progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFEFE9DA),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFC79A3B)), // vàng đồng
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
