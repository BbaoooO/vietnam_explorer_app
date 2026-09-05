import 'passport_stamp.dart';

/// Thông tin chủ sở hữu passport
class TravelerProfile {
  final String fullName;
  final String avatarUrl;
  final String passportId; // Mã số passport, VD: "VN-TRAVELER-000123"
  final DateTime issueDate;
  final int totalDestinations; // Tổng số địa danh trong hệ thống
  final List<PassportStamp> stamps; // Các địa danh đã/chưa ghé thăm

  const TravelerProfile({
    required this.fullName,
    required this.avatarUrl,
    required this.passportId,
    required this.issueDate,
    required this.totalDestinations,
    required this.stamps,
  });

  int get visitedCount => stamps.where((s) => s.isUnlocked).length;

  double get progress =>
      totalDestinations == 0 ? 0 : visitedCount / totalDestinations;
}
