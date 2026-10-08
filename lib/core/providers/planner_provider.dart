import 'package:flutter/material.dart';
import '../models/planner_model.dart';
import '../repositories/dummy_data_repository.dart';

class PlannerProvider extends ChangeNotifier {
  // 1. Kéo dữ liệu từ kho (Repository) vào Trạm quản lý
  final List<DailyItinerary> _itineraries = DummyDataRepository.itineraries;

  // 2. Cho phép các màn hình khác đọc dữ liệu này
  List<DailyItinerary> get itineraries => _itineraries;

  // 3. Hàm thêm hoạt động mới (Sẽ được gọi khi bấm nút bên màn hình Map)
  void addPlanToDay(int dayIndex, PlannerItem newItem) {
    _itineraries[dayIndex].items.add(newItem);

    // Lệnh quan trọng nhất: Phát loa thông báo cho UI cập nhật lại giao diện
    notifyListeners();
  }
}