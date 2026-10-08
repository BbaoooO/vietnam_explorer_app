import 'package:shared_preferences/shared_preferences.dart';

/// Lưu & đọc tiến độ Passport thật trên máy người dùng,
/// thay cho dữ liệu hard-code trong sample_passport_data.dart.
class PassportStorageService {
  static const _keyLevel = 'passport_level';
  static const _keyXp = 'passport_xp';
  static const _keyUnlockedProvinces = 'passport_unlocked_provinces';

  /// Đọc cấp độ hiện tại, mặc định = 1 nếu chưa có dữ liệu.
  Future<int> readLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLevel) ?? 1;
  }

  /// Đọc XP hiện tại, mặc định = 0.
  Future<int> readXp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyXp) ?? 0;
  }

  /// Đọc danh sách tên tỉnh/thành đã mở khoá.
  Future<List<String>> readUnlockedProvinces() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyUnlockedProvinces) ?? const [];
  }

  /// Lưu lại Level + XP mới (gọi khi người dùng check-in, hoàn thành nhiệm vụ...).
  Future<void> saveProgress({required int level, required int xp}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLevel, level);
    await prefs.setInt(_keyXp, xp);
  }

  /// Thêm 1 tỉnh/thành vào danh sách đã mở khoá (không trùng lặp).
  Future<void> unlockProvince(String provinceName) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_keyUnlockedProvinces) ?? [];
    if (!current.contains(provinceName)) {
      current.add(provinceName);
      await prefs.setStringList(_keyUnlockedProvinces, current);
    }
  }
}
