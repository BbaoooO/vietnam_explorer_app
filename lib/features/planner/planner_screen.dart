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

  // Form Bottom Sheet to Add New Plan
  void _showAddPlanBottomSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final costController = TextEditingController();
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
    IconData selectedIcon = Icons.location_on;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add New Plan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                            fontFamily: 'Be Vietnam Pro',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Activity Title',
                        hintText: 'e.g., Visit Hoan Kiem Lake',
                        prefixIcon: const Icon(Icons.title, color: primaryColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'e.g., Take photos and enjoy egg coffee',
                        prefixIcon: const Icon(Icons.description, color: primaryColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                              );
                              if (time != null) {
                                setModalState(() {
                                  selectedTime = time;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Time',
                                prefixIcon: const Icon(Icons.access_time, color: primaryColor),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text(selectedTime.format(context)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: costController,
                            decoration: InputDecoration(
                              labelText: 'Cost',
                              hintText: 'e.g., 50,000 VND',
                              prefixIcon: const Icon(Icons.payments_outlined, color: primaryColor),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Icon Category',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildIconOption(Icons.location_on, selectedIcon, (icon) => setModalState(() => selectedIcon = icon)),
                        _buildIconOption(Icons.restaurant, selectedIcon, (icon) => setModalState(() => selectedIcon = icon)),
                        _buildIconOption(Icons.flight, selectedIcon, (icon) => setModalState(() => selectedIcon = icon)),
                        _buildIconOption(Icons.hotel, selectedIcon, (icon) => setModalState(() => selectedIcon = icon)),
                        _buildIconOption(Icons.local_activity, selectedIcon, (icon) => setModalState(() => selectedIcon = icon)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          if (titleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter an activity title'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          final newItem = PlannerItem(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            time: selectedTime.format(context),
                            estimatedCost: costController.text.trim().isEmpty
                                ? 'Free'
                                : costController.text.trim(),
                            isCompleted: false,
                            icon: selectedIcon,
                          );

                          // Thêm vào Provider theo Day được chọn
                          context.read<PlannerProvider>().addPlanToDay(_selectedDayIndex, newItem);
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Plan added to Day ${_selectedDayIndex + 1}!'),
                              backgroundColor: primaryColor,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          foregroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Save Plan',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIconOption(IconData icon, IconData currentSelected, Function(IconData) onSelect) {
    final isSelected = icon == currentSelected;
    return GestureDetector(
      onTap: () => onSelect(icon),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? secondaryColor : Colors.grey.shade100,
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? primaryColor : Colors.transparent),
        ),
        child: Icon(icon, color: primaryColor, size: 22),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        onPressed: () => _showAddPlanBottomSheet(context),
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
                              'Hanoi - Ninh Binh',
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