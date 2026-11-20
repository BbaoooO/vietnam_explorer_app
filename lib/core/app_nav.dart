import 'package:flutter/foundation.dart';

import 'models/travel_records.dart';

class AppNav {
  static const int home = 0;
  static const int map = 1;
  static const int planner = 2;
  static const int passport = 3;
  static const int profile = 4;

  final tab = ValueNotifier<int>(home);
  final mapFocus = ValueNotifier<CatalogRef?>(null);
  final plannerDraft = ValueNotifier<PlanDraft?>(null);

  void openMap(CatalogRef target) {
    tab.value = map;
    mapFocus.value = target;
  }

  void openPlanner(PlanDraft draft) {
    tab.value = planner;
    plannerDraft.value = draft;
  }

  void dispose() {
    tab.dispose();
    mapFocus.dispose();
    plannerDraft.dispose();
  }
}
