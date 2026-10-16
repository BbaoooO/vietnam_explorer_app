import 'package:flutter/foundation.dart';
//nạp thư viện có Value_Notifier

class AppNav {
  //tạo lớp chứa các giá trị điều hướng dùng chung
  static final ValueNotifier<int> tab = ValueNotifier<int>(0);
  //static final mỗi biến dùng chung ở cấp lớp và không bị gán sang notifer khác
  //ValueNotifier<int> tab giữ chỉ số tab và thông báo cho các thành phần đang lắng nghe khi giá trị thay đổi
  //ValueNotifer<int>(0) giá trị ban đầu là home tương ứng 0
  static final ValueNotifier<String?> mapFocusId = ValueNotifier<String?>(null);
  //ValueNotifier<String?> mapFocusId giữ mã địa điểm cần xem trên bản đồ
  //ValueNotifier<String?>(null) ban đầu chưa có địa điểm được yêu cầu
  static final ValueNotifier<String?> plannerAddId = ValueNotifier<String?>(null);
//plannerAddId giữ mã địa điểm được gửi sang planner
  static const int home = 0;
  static const int map = 1;
  static const int planner = 2;   // Trip Planner
  static const int passport = 3;  // Passport
  static const int profile = 4;
  //đặt tên dễ hiểu cho chỉ số từng tab
}