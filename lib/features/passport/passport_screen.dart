import '../../core/explorer_app_bar.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../core/providers/travel_data.dart';
import 'models/province_stamp.dart';
import 'models/traveler_profile.dart';
import 'models/passport_stamp.dart';
import 'widgets/province_badge_card.dart';
import 'widgets/stamp_card.dart';

class PassportScreen extends StatelessWidget {
  const PassportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TravelData>();
    final visitCount = data.visits.length;
    final level = visitCount ~/ 5 + 1;
    final allAreas = data.places.map((place) => place.province).toSet();
    final visitedAreas = data.visitedAreas.toList()..sort();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final name = user?.displayName?.trim();
        return _PassportView(
          profile: TravelerProfile(
            fullName: name == null || name.isEmpty
                ? user?.email ?? 'Explorer'
                : name,
            avatarUrl: user?.photoURL ?? '',
            passportId: data.uid.substring(0, data.uid.length < 8 ? data.uid.length : 8).toUpperCase(),
            issueDate: user?.metadata.creationTime?.toLocal(),
            totalDestinations: data.places.length,
            levelNumber: level,
            levelTitle: level == 1 ? 'New Explorer' : 'Explorer',
            currentXP: visitCount * 100,
            xpToNextLevel: level * 500,
            stamps: [
              for (final place in data.places)
                PassportStamp(
                  placeName: place.name,
                  province: place.province,
                  imageUrl: place.imageUrl,
                  visitedDate: data.visits[place.id],
                  isUnlocked: data.visits.containsKey(place.id),
                ),
            ],
          ),
          collection: [
            for (final area in visitedAreas)
              ProvinceStamp(name: area, tagline: 'Explored'),
          ],
          totalAreas: allAreas.length,
        );
      },
    );
  }
}

class _PassportView extends StatefulWidget {
  const _PassportView({
    required this.profile,
    required this.collection,
    required this.totalAreas,
  });

  final TravelerProfile profile;
  final List<ProvinceStamp> collection;
  final int totalAreas;

  @override
  State<_PassportView> createState() => _PassportViewState();
}

class _PassportViewState extends State<_PassportView> {
  // Trạng thái bộ lọc hiện tại
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildAppBar(context)),
          SliverToBoxAdapter(child: _buildPassportCard(context)),
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildLevelCard(context)),
          SliverToBoxAdapter(child: _buildCollectionBookHeader(context)),
          _buildCollectionBookGrid(context),
          SliverToBoxAdapter(child: _buildProgressSection(context)),
          SliverToBoxAdapter(child: _buildVisitedSectionHeader(context)),

          // Thêm thanh bộ lọc vào đây
          SliverToBoxAdapter(child: _buildFilterBar()),

          _buildStampsGrid(context),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return const ExplorerAppBar();
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Digital Passport',
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

  // --- Cập nhật Gamification: Thêm nút Share ---
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
                backgroundImage: widget.profile.avatarUrl.isEmpty
                    ? null
                    : NetworkImage(widget.profile.avatarUrl),
                child: widget.profile.avatarUrl.isEmpty ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.profile.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Passport ID: ${widget.profile.passportId}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Nút Share
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preparing your achievement to share…')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white30, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.profile.issueDate case final date?)
                _cardInfo('Passport issue date', '${date.day}/${date.month}/${date.year}'),
              _cardInfo('Visited', '${widget.profile.visitedCount} location(s)'),
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
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // --- Cập nhật Gamification: Hiệu ứng thanh XP ---
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
                'L${widget.profile.levelNumber}',
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
                      widget.profile.levelTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level ${widget.profile.levelNumber} Explorer',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${widget.profile.currentXP} / ${widget.profile.xpToNextLevel}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text('XP', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Sử dụng TweenAnimationBuilder để tạo animation chạy thanh XP
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: widget.profile.xpProgress),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
              ),
            ),
          ),

          if (widget.profile.nextBadgeName.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              "Unlock the '${widget.profile.nextBadgeName}' badge at Level ${widget.profile.nextBadgeLevel}.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCollectionBookHeader(BuildContext context) {
    final unlockedCount = widget.collection.length;
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
                'Collection Book',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, height: 1.15),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$unlockedCount / ${widget.totalAreas}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text('Areas', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionBookGrid(BuildContext context) {
    final lockedPreviewCount = widget.collection.length < widget.totalAreas ? 1 : 0;
    final itemCount = widget.collection.length + lockedPreviewCount;

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
            if (index < widget.collection.length) {
              return ProvinceBadgeCard(province: widget.collection[index]);
            }
            return const ProvinceBadgeCard();
          },
          childCount: itemCount,
        ),
      ),
    );
  }

  // --- Cập nhật Gamification: Hiệu ứng thanh tiến độ khám phá ---
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
                'Progress in exploring VietNam',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                '${widget.profile.visitedCount}/${widget.profile.totalDestinations}',
                style: const TextStyle(
                    color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),

          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: widget.profile.progress),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: const Color(0xFFF0F1F3),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitedSectionHeader(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 4),
      child: Text(
        'Visited Destinations',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor),
      ),
    );
  }

  // --- Chức năng lọc: Thanh UI để chọn bộ lọc ---
  Widget _buildFilterBar() {
    final filters = ['All', 'Visited', 'Not visited'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              selectedColor: AppTheme.secondaryColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- Chức năng lọc: Áp dụng dữ liệu lọc vào Grid ---
  Widget _buildStampsGrid(BuildContext context) {
    // Lọc danh sách stamps dựa vào biến trạng thái
    List<PassportStamp> filteredStamps = widget.profile.stamps.where((stamp) {
      if (_selectedFilter == 'Visited') return stamp.isUnlocked;
      if (_selectedFilter == 'Not visited') return !stamp.isUnlocked;
      return true; // "Tất cả"
    }).toList();

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
              (context, index) => StampCard(stamp: filteredStamps[index]),
          childCount: filteredStamps.length,
        ),
      ),
    );
  }
}