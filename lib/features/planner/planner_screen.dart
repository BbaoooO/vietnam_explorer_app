import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/explorer_app_bar.dart';
import '../../core/models/planner_model.dart';
import '../../core/repositories/dummy_data_repository.dart';
import 'package:provider/provider.dart';
import '../../core/providers/planner_provider.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  static const Color primaryColor = Color(0xFF0F4C3A);
  static const Color secondaryColor = Color(0xFFF2B705);
  static const Color bgColor = Color(0xFFF7F8FA);

  int _selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Gọi dữ liệu từ DummyDataRepository
    final plannerProvider = context.watch<PlannerProvider>();
    final currentDayData = plannerProvider.itineraries[_selectedDayIndex];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const ExplorerAppBar(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeroBanner(),
          ),
          SliverToBoxAdapter(
            child: _buildDayPicker(),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 16, bottom: 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final item = currentDayData.items[index];
                  final isFirst = index == 0;
                  final isLast = index == currentDayData.items.length - 1;
                  return _buildTimelineItem(item, isFirst, isLast);
                },
                childCount: currentDayData.items.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Mở form thêm lịch trình
        },
        backgroundColor: secondaryColor,
        foregroundColor: primaryColor,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Plan',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Be Vietnam Pro'),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: const DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1555921015-5532091f6026?w=800',
            ),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.85),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Hà Nội - Ninh Bình',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Be Vietnam Pro',
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '12 Oct - 14 Oct • 3 Days',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: secondaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Budget',
                                style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '3.5M',
                                style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayPicker() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // Gọi độ dài danh sách từ DummyDataRepository
        itemCount: DummyDataRepository.itineraries.length,
        itemBuilder: (context, index) {
          final dayData = DummyDataRepository.itineraries[index];
          final isSelected = _selectedDayIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDayIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey.shade300,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Day ${dayData.day}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    dayData.date,
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem(PlannerItem item, bool isFirst, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 70,
            padding: const EdgeInsets.only(left: 16, top: 12),
            alignment: Alignment.topCenter,
            child: Text(
              item.time,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 16,
                  color: isFirst ? Colors.transparent : Colors.grey.shade300,
                ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: item.isCompleted ? primaryColor : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: item.isCompleted ? primaryColor : secondaryColor,
                      width: 4,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(item.icon, color: secondaryColor, size: 20),
                        Text(
                          item.estimatedCost,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}