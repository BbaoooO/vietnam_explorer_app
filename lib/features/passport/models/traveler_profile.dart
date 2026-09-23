import 'passport_stamp.dart';

/// Thông tin chủ sở hữu passport
class TravelerProfile {
  final String fullName;
  final String avatarUrl;
  final String passportId; // Mã số passport, VD: "VN-TRAVELER-000123"
  final DateTime issueDate;
  final int totalDestinations; // Tổng số địa danh trong hệ thống
  final List<PassportStamp> stamps; // Các địa danh đã/chưa ghé thăm

  // ---- Cấp độ & XP (Task 3.1: header "Wandering Scholar - Level 3") ----
  final int levelNumber; // VD: 3
  final String levelTitle; // VD: "Wandering Scholar"
  final int currentXP; // VD: 1450
  final int xpToNextLevel; // VD: 2000
  final String nextBadgeName; // VD: "Mekong Navigator"
  final int nextBadgeLevel; // VD: 4

  const TravelerProfile({
    required this.fullName,
    required this.avatarUrl,
    required this.passportId,
    required this.issueDate,
    required this.totalDestinations,
    required this.stamps,
    this.levelNumber = 1,
    this.levelTitle = 'New Explorer',
    this.currentXP = 0,
    this.xpToNextLevel = 1000,
    this.nextBadgeName = '',
    this.nextBadgeLevel = 0,
  });

  int get visitedCount => stamps.where((s) => s.isUnlocked).length;

  double get progress =>
      totalDestinations == 0 ? 0 : visitedCount / totalDestinations;

  double get xpProgress =>
      xpToNextLevel == 0 ? 0 : currentXP / xpToNextLevel;
}

