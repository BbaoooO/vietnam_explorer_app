import 'package:flutter/foundation.dart';

class AppNav {
  static final ValueNotifier<int> tab = ValueNotifier<int>(0);
  static final ValueNotifier<String?> mapFocusId = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> plannerAddId = ValueNotifier<String?>(null);

  static const int home = 0;
  static const int map = 1;
  static const int planner = 2;   // Trip Planner
  static const int passport = 3;  // Passport
  static const int profile = 4;
}